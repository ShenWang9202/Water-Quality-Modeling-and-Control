% Main Program to do MPC control considering Unknown, Demand, Parameter
% Uncertainties

% System: only on Windows
% Author: Shen Wang
% Date: 3/7/2020

% In order to do LDE without input u, just (1) uncomment x_estimated = A *
% x_estimated + B * U;  and make it as x_estimated = A * x_estimated; in
% EstimateState_XX.m source file.
% (2) don't apply control action to epanet (3) remove all uncertainty
% A easy way to do this: set the flag COMPARE = 1;


clear all
clc
close all
%% Load EPANET MATLAB TOOLKIT
start_toolkit;

% check this example Toolkit_EX3_Minimum_chlorine_residual.m
%% run EPANET MATLAB TOOLKIT to obtain data

% Demand uncertainty on or off
DEMAND_UNCERTAINTY = 0;
Demand_Unc = 0.1;
% Unknown uncertainty on or off
UNKNOW_UNCERTAINTY = 0;
% Parameter uncertainty on or off

PARAMETER_UNCERTAINTY = 0;
Kb_uncertainty = 0.1;
Kw_uncertainty = 0.1;

COMPARE = Constants4Concentration.ONLY_COMPARE;
if(COMPARE == 1) % when compare LDE with EPANET, We have to make all uncertainty disappear
    PARAMETER_UNCERTAINTY = 0;
    UNKNOW_UNCERTAINTY = 0;
    DEMAND_UNCERTAINTY = 0;
end

Network = Constants4Concentration.Network;
switch Network
    case 1
        % Quality Timestep = 1 min, and  Global Bulk = -0.3, Global Wall= -0.0
        % NetworkName = 'Threenode-cl-2-paper.inp'; pipe flow direction
        % never changed, and the result is perfectly matched with EPANET
        %NetworkName = 'Threenode-cl-3-paper.inp'; % Pipe flow direction changes
        NetworkName = 'Threenode-cl-2-paper.inp'; % topogy changes
        Unknown_Happen_Time = 200;
        PipeID_Cell = {'P1'};
        JunctionID_Cell = {'J2'};
        Sudden_Concertration = 1.0; % Suddenly the concentration jumps to this value for no reason
        filename = 'Three-node_1day.mat';
    case 2
        % Don't not use one: Quality Timestep = 5 min, and  Global Bulk = -0.3, Global Wall=
        % -1.0
        NetworkName = 'tutorial8node.inp';
    case 3
        % Quality Timestep = 1 min, and  Global Bulk = -0.3, Global Wall= -0.0
        NetworkName = 'tutorial8nodeTimeScale.inp';
    case 4
        % Quality Timestep = 1 min, and  Global Bulk = -0.3, Global Wall=
        % -0.0; initial value: J2 = 0.5 mg/L, J6 = 1.2 mg/L, R1 = 0.8 mg/L;
        % segment = 1000;
        NetworkName = 'tutorial8node1inital.inp';
        %         NetworkName = 'tutorial8node1inital2.inp';
        filename = '8node_1day.mat';
    case 5
        % Quality Timestep = 1 min, and  Global Bulk = -0.5, Global Wall=
        % -0.0;
        NetworkName = 'Net1-1min.inp';
    case 6
        % The initial value is slightly different
        NetworkName = 'Net1-1mininitial.inp';
    case 7
        % Quality Timestep = 1 min, and  Global Bulk = -0.3, Global Wall= -0.0
        NetworkName = 'Net1-1min-new-demand-pattern.inp';
        Unknown_Happen_Time = 3000; % Unknow Disturbance happened at the 3000-th minutes
        PipeID_Cell = {'P11','P21','P31'};
        JunctionID_Cell = {'J11','J21','J31'};
        Sudden_Concertration = 0.5;
        filename = 'Net1_4days.mat';
    case 8
        % Quality Timestep = 1 min, and  Global Bulk = -0.3, Global Wall= -0.0
        NetworkName = 'Fournode-Cl-As-1.inp';
    case 9
        %NetworkName = 'Net3-NH2CL-24hour-4.inp'; % this is used to test the topology changes
        NetworkName = 'Net3-NH2CL-24hour-modified.inp'; % 'Net3-NH2CL-24hour-zerovelocity.inp';%
        filename = 'Net3_1day.mat';
    otherwise
        disp('other value')
end

%% Prepare constants data for MPC
PrepareData4Control

%% initialize concentration at nodes

% initialize BOOSTER
% flow of Booster, assume we put booster at each nodes, so the size of it
% should be the number of nodes.
nodeCount = ElementCount.nodeCount;
NodeIndex = d.getNodeIndex;
LinkIndex = nodeCount+d.getLinkIndex;
NodeID = Variable_Symbol_Table2(NodeIndex,1);
LinkID = Variable_Symbol_Table2(LinkIndex,1);

PipeID = Variable_Symbol_Table2(PipeIndexInOrder,1);
JunctionID = Variable_Symbol_Table2(JunctionIndexInOrder,1);

switch Network
    case 1
        Location_B = {'J2'}; % NodeID here;
        flowRate_B = [10]; % unit: GPM
        Price_B = [1];
        % the C_B is what we need find in MPC, useless here
        %C_B = [1]; % unit: mg/L % Concentration of booster
    case {2,3,4}
        Location_B = {'J3','J7'}; % NodeID here;
        flowRate_B = [10,10]; % unit: GPM
        Price_B = [1,1];
        TargetedPipeID =  PipeID([2]); % TRY [], PipeID([2]) PipeID([2,4,6]) PipeID([3,5,7])
    case {5,6,7}
        Location_B = {'J11','J22','J31'}; % NodeID here;
        flowRate_B = [10,10,10]; % unit: GPM
        Price_B = [1,1,1];
        TargetedPipeID = [];%PipeID([2,4,6,8]);
    case 8
        Location_B = {'J2'}; % NodeID here;
        flowRate_B = [100]; % unit: GPM
        Price_B = [1];
    case 9
        Location_B = {'J217','J237','J247'}; % NodeID here;
        flowRate_B = 10*ones(size(Location_B)); % unit: GPM
        Price_B = ones(size(Location_B));
        TargetedPipeID = [];%PipeID;
%         Location_B = {'J123'}; % NodeID here;
%         flowRate_B = [10]; % unit: GPM
%         Price_B = [1];
    otherwise
        disp('other value')
end



%[q_B,C_B] = InitialBoosterFlow(nodeCount,Location_B,flowRate_B,NodeID,C_B);
Price_B1 = Price_B';
[q_B,Price_B,BoosterLocationIndex,BoosterCount] = InitialBooster(nodeCount,Location_B,flowRate_B,NodeID,Price_B);
%[q_B,Price_B,BoosterLocationIndex,BoosterCount] = InitialBooster1(Location_B,flowRate_B,NodeID,Price_B);


% Get the flow rate and head when use demand without uncertainty
HydraulicInfoWithoutUncertainty =[];
if DEMAND_UNCERTAINTY
    HydraulicInfoWithoutUncertainty = ObtainNetworkHydraulicInfoWithoutUncertainty(d);
end


% Compute Quality without MSX
% (This function contains events) Don't uncomment this commands!!! Crash
% easily
qual_res = d.getComputedQualityTimeSeries; %Value x Node, Value x Link
LinkQuality = qual_res.LinkQuality;
NodeQuality = qual_res.NodeQuality;

% Initial Concentration
C0 = [NodeQuality(1,:) LinkQuality(1,:)];

% add uncertainty to the network
NodeJunctionIndex = d.getNodeJunctionIndex;
NodePatternIndex = d.getNodePatternIndex;
JunctionPatternIndex = NodePatternIndex(NodeJunctionIndex);
UniqueJunctionPatternIndex = unique(JunctionPatternIndex);

% get junction patterns
Patterns = d.getPattern;
JunctionPattern = Patterns(UniqueJunctionPatternIndex,:);

% generate new pattern with uncertainty
JunctionPattern_Uncertainty = add_uncertainty(JunctionPattern,Demand_Unc);

% Set Pattern needs pattern index and the corresponding pattern.
% for example, we need the Junction 2's index is 2, and the correpsonding
% Pattern index is 1. If we want to set Junction 2's new pattern, then just
% setPattern(1,newpattern)

if DEMAND_UNCERTAINTY
    d.setPattern(UniqueJunctionPatternIndex,JunctionPattern_Uncertainty);
end



%% Construct aux struct
%'NumberofSegment',NumberofSegment,...
aux = struct('NumberofSegment4Pipes',NumberofSegment4Pipes,...
    'LinkLengthPipe',LinkLengthPipe,...
    'LinkDiameterPipe',LinkDiameterPipe,...
    'TankBulkReactionCoeff',TankBulkReactionCoeff,...
    'TankMassMatrix',TankMassMatrix,...
    'JunctionMassMatrix',JunctionMassMatrix,...
    'MassEnergyMatrix',MassEnergyMatrix,...
    'flowRate_B',flowRate_B,...
    'q_B',q_B,...
    'Price_B',Price_B1,...,
    'BoosterLocationIndex',BoosterLocationIndex,...,
    'BoosterCount',BoosterCount,...,
    'NodeNameID',{NodeNameID},...
    'LinkNameID',{LinkNameID},...
    'NodeID',{NodeID},...
    'LinkID',{LinkID},...
    'TargetedPipeID',{TargetedPipeID},...
    'NodesConnectingLinksID',{NodesConnectingLinksID},...
    'COMPARE',COMPARE);
%    'Price_B',Price_B,...,

%% Start MPC control

T = [];
Head = [];
Flow = [];
UeachMin = [];
NpMatrix = [];
Magnitude = [];
X_estimated = [];
QsN_Control = [];
QsL_Control = [];
XX_estimated = [];
ControlActionU = [];
U_C_B_eachStep = [];
PreviousDelta_t = [];
NodeSourceQuality = [];
ControlActionU_LDE = [];
JunctionActualDemand = [];
UeachIntervalforEPANET = [];
PreviousSystemDynamicMatrix = [];

VelocityPipe = [];


Hq_min = Constants4Concentration.Hq_min;% I need that all concention 5 minutes later are  in 0.2 mg 4 mg
T_booster_min = Constants4Concentration.T_booster_min; % Booster station inject chlorin each 2 minutes.
SimutionTimeInMinute = Constants4Concentration.SimutionTimeInMinute;

PreviousValue = struct('PreviousDelta_t',PreviousDelta_t,...
    'PreviousSystemDynamicMatrix',PreviousSystemDynamicMatrix,...
    'X_estimated',X_estimated,...
    'U_C_B_eachStep',0,...
    'UeachIntervalforEPANET',0);

d.openHydraulicAnalysis;
d.openQualityAnalysis;
d.initializeHydraulicAnalysis;
d.initializeQualityAnalysis;

tleft = 1;
tInMin = 0;
delta_t = 0;

if DEMAND_UNCERTAINTY
    % load the head, flow, and velocity without uncertainty
    HeadWithoutUncertainty = HydraulicInfoWithoutUncertainty.Head;
    FlowWithoutUncertainty = HydraulicInfoWithoutUncertainty.Flow;
    VelocityPipeWithoutUncertainty = HydraulicInfoWithoutUncertainty.Velocity;
end




% profile on
tic
while (tleft > 0 && tInMin < SimutionTimeInMinute && delta_t <= 60)
    t1 = d.runHydraulicAnalysis;
    t=d.runQualityAnalysis;
    
    % Obtain the actual Concentration
    QsN_Control=[QsN_Control; d.getNodeActualQuality];
    QsL_Control=[QsL_Control; d.getLinkQuality];
    Head=[Head; d.getNodeHydaulicHead];
    Flow=[Flow; d.getLinkFlows];
    TempDemand = d.getNodeActualDemand;
    JunctionActualDemand = [JunctionActualDemand; TempDemand(NodeJunctionIndex)];
    
    % Calculate Control Action
    tInMin = t/60;
    if(mod(tInMin,Hq_min) == 0)
        % 5 miniute is up, Calculate the New Control Action
        disp('Current time')
        tInMin
        tInHour = tInMin/60
        
        if DEMAND_UNCERTAINTY
            CurrentVelocity = VelocityPipeWithoutUncertainty(tInMin + 1,:);
        else
            CurrentVelocity = d.getLinkVelocity;
        end
        
        CurrentVelocityPipe = CurrentVelocity(:,PipeIndex);
        VelocityPipe = [VelocityPipe; CurrentVelocityPipe];
        if PARAMETER_UNCERTAINTY
            Kb_all = add_uncertainty(Kb_all, Kb_uncertainty);
            Kw_all = add_uncertainty(Kw_all, Kw_uncertainty);
        end
        PipeReactionCoeff = CalculatePipeReactionCoeff(CurrentVelocityPipe,LinkDiameterPipe,Kb_all,Kw_all,PipeIndex);
        % the minium step length for all pipes
        delta_t = LinkLengthPipe./NumberofSegment4Pipes./CurrentVelocityPipe;
        delta_t = min(delta_t);
        delta_t = MakeDelta_tAsInteger(delta_t)
        
        if DEMAND_UNCERTAINTY
            % Because tInmin starts from 0, but matlab's index is from 1, so we need to add 1 here
            CurrentFlow = FlowWithoutUncertainty(tInMin + 1,:);
            CurrentHead = HeadWithoutUncertainty(tInMin + 1,:);
        else
            CurrentFlow = d.getLinkFlows;
            CurrentHead = d.getNodeHydaulicHead;
        end
        
        Volume = d.getNodeTankVolume;
        CurrentNodeTankVolume = Volume(NodeTankIndex);
        CurrentHead = d.getNodeHydaulicHead;
        
        % Estimate Hp of concentration; basciall 5 mins = how many steps
        SetTimeParameter = Hq_min*Constants4Concentration.MinInSecond/delta_t;
        Np = round(SetTimeParameter)
        NpMatrix = [NpMatrix Np];
        %Np = floor(SetTimeParameter) + 1;
        
        % Collect the current value
        CurrentValue = struct('CurrentVelocityPipe',CurrentVelocityPipe,...
            'CurrentNodeTankVolume',CurrentNodeTankVolume,...
            'CurrentFlow',CurrentFlow,...
            'CurrentHead',CurrentHead,...
            'delta_t',delta_t,...
            'PipeReactionCoeff',PipeReactionCoeff,...
            'Np',Np);
        
        % Esitmate the concentration in all elements according to the
        % system dynamics each 5 mins
        xx_estimated = EstimateState_XX_SaveMem(CurrentValue,IndexInVar,aux,ElementCount,q_B,tInMin,C0,PreviousValue);
        x_estimated = xx_estimated(:,end);
        % when time = 200 minute, we simuate a disturbance, that is, the
        % chorine in J2 and Pipe 23 are suddenly drops to 0.5 due to
        % unknown reason, and we see how our MPC react.
        % We need to set the hijack x_estimated, and force the
        % concentration at J2 P23 as o.5 mg/L
        
        if(UNKNOW_UNCERTAINTY==1 && tInMin == Unknown_Happen_Time)
            % To do: this Hack function into the different number of
            % segmetns version. Before doing this, do not test UNKNOW_UNCERTAINTY
            
            % orangize parameter into a struct
            nsegment = aux.NumberofSegment;
            Struct4Hack = struct('NumberofSegment',nsegment,...
                'PipeID',{PipeID},...
                'PipeID_Cell',{PipeID_Cell},...
                'Pipe_CIndex',{Pipe_CIndex},...
                'JunctionID_Cell',{JunctionID_Cell},...
                'JunctionID',{JunctionID},...
                'Sudden_Concertration',Sudden_Concertration);
            % call function
            x_estimated = Hack_x_estimated_ByID(x_estimated,Struct4Hack);
            if Network == 1
                % Note that for three node, we also need to change the pump's
                % concnetration since pump = 0.5*(junction + Reservoir)
                x_estimated(104) = 0.9; % This is only for three-node, comment this for the othre network
            end
            % also update the each minute data to the every-5 minutes data
            xx_estimated(:,5) = x_estimated;
        end
        
        % Store the estimated value for future use
        % This is every 5 miutes, that is, the 5-th mins, for control
        % purpose
        %X_estimated = [X_estimated x_estimated];
        % This is every 1 minute, that is, all 5 mins, for records purpose
        XX_estimated = [XX_estimated xx_estimated];
        
        if COMPARE
            PreviousSystemDynamicMatrix = ObtainSystemDynamic(CurrentValue,IndexInVar,aux,ElementCount);
        else
            % Calculate all of the control actions at each min
            [UeachIntervalforEPANET,U_C_B_eachStep, PreviousSystemDynamicMatrix] = ObtainControlAction(CurrentValue,IndexInVar,aux,ElementCount,q_B,x_estimated,PreviousValue);
            % Save control actions and apply it to EPANET software
            ControlActionU = [ControlActionU; UeachIntervalforEPANET'];
            % Save control actions and apply it to OUR LDE model
            ControlActionU_LDE = [ControlActionU_LDE; U_C_B_eachStep'];
        end
        
        PreviousDelta_t = [PreviousDelta_t delta_t];
        PreviousValue.PreviousDelta_t = delta_t;
        PreviousValue.PreviousSystemDynamicMatrix = PreviousSystemDynamicMatrix;
        PreviousValue.X_estimated = xx_estimated(:,end);
        PreviousValue.U_C_B_eachStep = U_C_B_eachStep;
        PreviousValue.UeachIntervalforEPANET = UeachIntervalforEPANET;
        % find the maxium Eigenvalue of A matrix each 5 minutes, only do
        % this which applying control action to speed up these process,
        % otherwise it will take long time to run
        %         if(COMPARE == 1)
        %             mag = CalculateMaxEigenvalueofA(PreviousSystemDynamicMatrix.A);
        %             Magnitude = [Magnitude mag];
        %         end
    end
    
    % Apply Control action
    if(tInMin > 0 && ~COMPARE && mod(tInMin,T_booster_min) == 0)
        % Set booster type as mass booster
        for booster_i = 1:BoosterCount
            d.setNodeSourceType(BoosterLocationIndex(booster_i),'MASS'); %Junction2's index is 1; we set it as mass booster
        end
        
        TmpNodeSourceQuality = d.getNodeSourceQuality;
        NodeSourceQuality = [NodeSourceQuality; TmpNodeSourceQuality];
        intervalIndex = tInMin/T_booster_min;
        TmpNodeSourceQuality = ControlActionU(intervalIndex,:)/T_booster_min; %1 is the index of junction 2
        %applycounter = applycounter + 1;
        for booster_i = 1:BoosterCount
            indBooster = BoosterLocationIndex(booster_i);
            SourceQualityValue = TmpNodeSourceQuality(booster_i);
            d.setNodeSourceQuality(indBooster,SourceQualityValue);
        end
    end
    
    T=[T; t];
    tstep1 = d.nextHydraulicAnalysisStep;
    tstep = d.nextQualityAnalysisStep;
end
runningtime = toc
d.closeQualityAnalysis;
d.closeHydraulicAnalysis;
% p = profile('info')
% save myprofiledata p
% profile viewer
%% Start to plot
disp('Done!! Start to organize data')
disp('Summary:')
disp(['Compare is: ',num2str(COMPARE)]);
disp(['Demand uncertainty is: ',num2str(DEMAND_UNCERTAINTY)]);
disp(['Unknown uncertainty is: ',num2str(UNKNOW_UNCERTAINTY)]);
disp(['Parameter uncertainty is: ',num2str(PARAMETER_UNCERTAINTY)]);
disp(['NumberofSegment4Pipes is: '])
NumberofSegment4Pipes

disp('Done!! Start to organize data')


figure
plot(JunctionActualDemand)
xlabel('Time (minute)')
ylabel('Demand at junctions (GPM)')
legend(NodeID)

figure
plot(Flow)
legend(LinkID)
xlabel('Time (minute)')
ylabel('Flow rates in links (GPM)')

% plot comparsion results between EPANET and LDE
plotComparsion
% plot control action obtained from MPC algorithm
if ~COMPARE
    plotControlAction
end
% plot imagine of segment concentration of intested pipe
InterestedID =  {'P245','P247','P249'}; % LinkID(PipeIndex)' ;%
plotImaginesc4InterestedComponents(XX_estimated,Pipe_CStartIndex,NumberofSegment4Pipes,InterestedID,LinkID);

save(filename)
