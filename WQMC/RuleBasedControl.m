% Main Program to do Rule Based Control considering Unknown, Demand, Parameter
% Uncertainties

% System: only on Windows
% Author: Shen Wang
% Date: 3/7/2020

% Only Rule Based Control for three-node network so far.

clear all
clc
close all
%% Load EPANET MATLAB TOOLKIT
start_toolkit;

% check this example Toolkit_EX3_Minimum_chlorine_residual.m
%% run EPANET MATLAB TOOLKIT to obtain data
symbolicDebug = 0;
% Demand uncertainty on or off
DEMAND_UNCERTAINTY = 1;
Demand_Unc = 0.1;
% Unknown uncertainty on or off
UNKNOW_UNCERTAINTY = 1;
% Parameter uncertainty on or off

PARAMETER_UNCERTAINTY = 1;
Kb_uncertainty = 0.1;
Kw_uncertainty = 0.1;


Network = 1; % Don't use case 2
switch Network
    case 1
        % Quality Timestep = 1 min, and  Global Bulk = -0.3, Global Wall= -0.0
        filename = 'Three-node_1day_RBC';
        NetworkName = 'Threenode-cl-2-paper.inp';
    case 2
        % Don't not use one: Quality Timestep = 5 min, and  Global Bulk = -0.3, Global Wall=
        % -1.0
        NetworkName = 'tutorial8node.inp';
    case 3
        % Quality Timestep = 1 min, and  Global Bulk = -0.3, Global Wall= -0.0
        NetworkName = 'tutorial8node1.inp';
    case 4
        % Quality Timestep = 1 min, and  Global Bulk = -0.3, Global Wall=
        % -0.0; initial value: J2 = 0.5 mg/L, J6 = 1.2 mg/L, R1 = 0.8 mg/L;
        % segment = 1000;
        NetworkName = 'tutorial8node1inital.inp';
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
    case 8
        % Quality Timestep = 1 min, and  Global Bulk = -0.3, Global Wall= -0.0
        NetworkName = 'Fournode-Cl-As-1.inp';
    otherwise
        disp('other value')
end

%% Prepare constants data for MPC
PrepareData4Control

%% initialize concentration at nodes

nx = NumberofX; % Number of states

% initialize BOOSTER
% flow of Booster, assume we put booster at each nodes, so the size of it
% should be the number of nodes.
JunctionCount = double(JunctionCount);
ReservoirCount = double(ReservoirCount);
TankCount = double(TankCount);
nodeCount = JunctionCount + ReservoirCount + TankCount;

switch Network
    case 1
        Location_B = {'J2'}; % NodeID here;
        flowRate_B = [100]; % unit: GPM
        Price_B = [1];
        % the C_B is what we need find in MPC, useless here
        %C_B = [1]; % unit: mg/L % Concentration of booster
    case {2,3,4}
        Location_B = {}; %Location_B = {'J2'}; % NodeID here;
        flowRate_B = [0]; % unit: GPM
        Price_B = [1];
        % the C_B is what we need find in MPC, useless here
        %C_B = [1]; % unit: mg/L % Concentration of booster
    case {5,6,7}
        Location_B = {'J11','J22','J31'}; % NodeID here;
        flowRate_B = [100,100,100]; % unit: GPM
        Price_B = [1,1,1];
        % the C_B is what we need find in MPC, useless here
        %C_B = [1]; % unit: mg/L % Concentration of booster
    case 8
        Location_B = {'J2'}; % NodeID here;
        flowRate_B = [100]; % unit: GPM
        Price_B = [1];
    otherwise
        disp('other value')
end
NodeID = Variable_Symbol_Table(1:nodeCount,1);
%[q_B,C_B] = InitialBoosterFlow(nodeCount,Location_B,flowRate_B,NodeID,C_B);
[q_B,Price_B,BoosterLocationIndex,BoosterCount] = InitialBooster(nodeCount,Location_B,flowRate_B,NodeID,Price_B);


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
% get junction patterns
Patterns = d.getPattern;
JunctionPattern = Patterns(JunctionPatternIndex,:);
% generate new pattern with uncertainty
JunctionPattern_Uncertainty = add_uncertainty(JunctionPattern,Demand_Unc);

% Set Pattern needs pattern index and the corresponding pattern.
% for example, we need the Junction 2's index is 2, and the correpsonding
% Pattern index is 1. If we want to set Junction 2's new pattern, then just
% setPattern(1,newpattern)

if DEMAND_UNCERTAINTY
    d.setPattern(JunctionPatternIndex,JunctionPattern_Uncertainty);
end



%% Construct aux struct

aux = struct('NumberofSegment',NumberofSegment,...
    'LinkLengthPipe',LinkLengthPipe,...
    'LinkDiameterPipe',LinkDiameterPipe,...
    'TankBulkReactionCoeff',TankBulkReactionCoeff,...
    'TankMassMatrix',TankMassMatrix,...
    'JunctionMassMatrix',JunctionMassMatrix,...
    'MassEnergyMatrix',MassEnergyMatrix,...
    'flowRate_B',flowRate_B,...
    'q_B',q_B,...
    'Price_B',Price_B);

%% Start MPC control


QsN_Control = []; QsL_Control = []; NodeSourceQuality = []; T = []; PreviousSystemDynamicMatrix = []; UeachMin = [];
X_estimated = []; PreviousDelta_t = []; ControlActionU = []; JunctionActualDemand = []; Head = []; Flow = []; XX_estimated = [];

Hq_min = Constants4Concentration.Hq_min;% I need that all concention 5 minutes later are  in 0.2 mg 4 mg
SimutionTimeInMinute = Constants4Concentration.SimutionTimeInMinute4RBC;

PreviousValue = struct('PreviousDelta_t',PreviousDelta_t,...
    'PreviousSystemDynamicMatrix',PreviousSystemDynamicMatrix,...
    'X_estimated',X_estimated,...
    'U_C_B_eachMin',0,...
    'UeachMinforEPANET',0);

d.openHydraulicAnalysis;
d.openQualityAnalysis;
d.initializeHydraulicAnalysis;
d.initializeQualityAnalysis;

tleft=1;
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
while (tleft>0 && tInMin < SimutionTimeInMinute && delta_t <= 60)
    t1 = d.runHydraulicAnalysis
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
    if(mod(tInMin,Hq_min)==0)
        % 5 miniute is up, Calculate the New Control Action
        disp('Calculte')
        tInMin
        tInHour = tInMin/60
        
        if DEMAND_UNCERTAINTY
%             CurrentVelocity = d.getLinkVelocity
            CurrentVelocity = VelocityPipeWithoutUncertainty(tInMin + 1,:);
        else
            CurrentVelocity = d.getLinkVelocity;
        end

        
        CurrentVelocityPipe = CurrentVelocity(:,PipeIndex);
        if PARAMETER_UNCERTAINTY
            Kb_all = add_uncertainty(Kb_all, Kb_uncertainty);
            Kw_all = add_uncertainty(Kw_all, Kw_uncertainty);            
        end
        PipeReactionCoeff = CalculatePipeReactionCoeff(CurrentVelocityPipe,LinkDiameterPipe,Kb_all,Kw_all,PipeIndex);
        % the minium step length for all pipes
        delta_t = LinkLengthPipe./NumberofSegment./CurrentVelocityPipe;
        delta_t = min(delta_t);
        delta_t = MakeDelta_tAsInteger(delta_t)
        
        
        
        if DEMAND_UNCERTAINTY
%             CurrentFlow = d.getLinkFlows
            CurrentFlow = FlowWithoutUncertainty(tInMin + 1,:);
%             CurrentHead = d.getNodeHydaulicHead
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
        [x_estimated,xx_estimated] = EstimateState_XX(CurrentValue,IndexInVar,aux,ElementCount,q_B,tInMin,C0,PreviousValue);
        
        % when time = 200 minute, we simuate a disturbance, that is, the
        % chorine in J2 and Pipe 23 are suddenly drops to 0.5 due to
        % unknown reason, and we see how our MPC react.
        % We need to set the hijack x_estimated, and force the
        % concentration at J2 P23 as o.5 mg/L
        
        if(UNKNOW_UNCERTAINTY==1 && tInMin == 200)
            x_estimated = Hijack_x_estimated(x_estimated);
            xx_estimated(:,5) = x_estimated;
        end
        
        % Store the estimated value for future use
        % This is every 5 miutes, that is, the 5-th mins, for control
        % purpose
        X_estimated = [X_estimated x_estimated];
        % This is every 1 minute, that is, all 5 mins, for records purpose
        XX_estimated = [XX_estimated xx_estimated];
        
        
        % Calculate all of the control actions at each min via Rule Based
        % Control
        [UeachMinforEPANET,U_C_B_eachMin, PreviousSystemDynamicMatrix] = ObtainControlAction_RBC(CurrentValue,IndexInVar,aux,ElementCount,q_B,x_estimated,PreviousValue);
        
        
        
        
        % Save Control Actions
        ControlActionU = [ControlActionU; UeachMinforEPANET'];
        PreviousDelta_t = [PreviousDelta_t delta_t];
        
        PreviousValue.PreviousDelta_t = PreviousDelta_t;
        PreviousValue.PreviousSystemDynamicMatrix = PreviousSystemDynamicMatrix;
        PreviousValue.X_estimated = X_estimated;
        PreviousValue.U_C_B_eachMin = U_C_B_eachMin;
        PreviousValue.UeachMinforEPANET = UeachMinforEPANET;
    end
    
    % Apply Control action
    if(tInMin > 0)
        % Set booster type as mass booster
        for booster_i = 1:BoosterCount
            d.setNodeSourceType(BoosterLocationIndex(booster_i),'MASS'); %Junction2's index is 1; we set it as mass booster
        end
        %     SourcePattern = d.getNodeSourcePatternIndex;
        %     SourcePattern = [3 0 0]; % set the third pattern
        %     d.setNodeSourcePatternIndex(SourcePattern);
        %     d.getNodeSourcePatternIndex
        TmpNodeSourceQuality = d.getNodeSourceQuality;
        NodeSourceQuality = [NodeSourceQuality; TmpNodeSourceQuality];
        TmpNodeSourceQuality = ControlActionU(tInMin,:); %1 is the index of junction 2
        %applycounter = applycounter + 1;
        d.setNodeSourceQuality(TmpNodeSourceQuality);
    end
    
    T=[T; t];
    tstep1 = d.nextHydraulicAnalysisStep;
    tstep = d.nextQualityAnalysisStep;
    %
    %     tleft = d.stepQualityAnalysisTimeLeft
    %     tleft1 = d.stepHydraulicAnalysisTimeLeft
end
toc
d.closeQualityAnalysis;
d.closeHydraulicAnalysis;
% p = profile('info')
% save myprofiledata p
% profile viewer

disp('Done!! Start to organize data')

% find average data;
X_Min = XX_estimated;
[m,n] = size(X_Min);
X_Min_Average = zeros(NumberofElement,n);
basePipeCIndex = min(Pipe_CIndex);
First = basePipeCIndex:basePipeCIndex+NumberofSegment-1;
for i = 1:n
    X_Min_Average(JunctionIndexInOrder,i) = X_Min(Junction_CIndex,i);
    X_Min_Average(ReservoirIndexInOrder,i) = X_Min(Reservoir_CIndex,i);
    X_Min_Average(TankIndexInOrder,i) = X_Min(Tank_CIndex,i);
    for j = 1:PipeCount
        Indexrange = (j-1)*NumberofSegment + First;
        X_Min_Average(PipeIndexInOrder(j),i) = mean(X_Min(Indexrange,i));
    end
    X_Min_Average(PumpIndexInOrder,i) = X_Min(Pump_CIndex,i);
    X_Min_Average(ValveIndexInOrder,i) = X_Min(Valve_CIndex,i);
end


close all
NodeIndex = d.getNodeIndex;
LinkIndex = nodeCount+d.getLinkIndex;

X_Min_Average = X_Min_Average';
X_node_control_result =  X_Min_Average(:,NodeIndex);
X_link_control_result =  X_Min_Average(:,LinkIndex);

NodeID4Legend = Variable_Symbol_Table2(NodeIndex,1);
LinkID4Legend = Variable_Symbol_Table2(LinkIndex,1);
% figure
% plot(JunctionActualDemand)

figure
%plot(QsN_Control)
plot(X_node_control_result);
legend(NodeID4Legend)
xlabel('Time (minute)')
ylabel('Concentrations at junctions (mg/L)')

figure
%plot(QsL_Control)
plot(X_link_control_result);
legend(LinkID4Legend)
xlabel('Time (minute)')
ylabel('Concentrations in links (mg/L)')

figure
plot(JunctionActualDemand)
xlabel('Time (minute)')
ylabel('Demand at junctions (GPM)')

legend(NodeID4Legend)

figure
plot(ControlActionU(:,BoosterLocationIndex))
legend(Location_B)
xlabel('Time (minute)')
ylabel('Mass at boosters (mg/minute)')


chlorinedose = sum(sum(ControlActionU(:,BoosterLocationIndex)));
Price_Weight = Constants4Concentration.Price_Weight;
Price = chlorinedose* Price_Weight;


figure
plot(Flow)
legend(LinkID4Legend)
xlabel('Time (minute)')
ylabel('Flow rates in links (GPM)')

disp('Summary:')
disp(['Demand uncertainty is: ',num2str(DEMAND_UNCERTAINTY)]);
disp(['Unknown uncertainty is: ',num2str(UNKNOW_UNCERTAINTY)]);
disp(['Parameter uncertainty is: ',num2str(PARAMETER_UNCERTAINTY)]);

save(filename)
