clear all
clear; clc;  close all
%% Load EPANET MATLAB TOOLKIT
start_toolkit;
%% run EPANET MATLAB TOOLKIT to obtain data
symbolicDebug = 0;
Network = 9; % Don't use case 1-8
switch Network
    case 1
        % Quality Timestep = 1 min, and  Global Bulk = -0.3, Global Wall= -0.0
        NetworkName = 'Threenode-cl-2.inp';
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
        % Without MSXfile
        NetworkName = 'Fournode-Cl-As-1.inp';
    case 9
        % Quality Timestep = 1 min, and  Global Bulk = -0.3, Global Wall= -0.0
        % With MSXfile
        NetworkName = 'Fournode-Cl-As-2.inp';
        %MSXName = 'Arsenite.msx';
        MSXName = 'Threenode-cl-3.msx';% Load MSX file, only Chlorine
    otherwise
        disp('other value')
end

%% Prepare constants data for MPC
PrepareData4Control
%d.loadMSXFile('Threenode-cl-3.msx'); % Load MSX file, only Chlorine
d.loadMSXFile(MSXName); % Load MSX file,mulit-species
%d.getMSXSources
% % Plot concentration for specific node and all species
% d.plotMSXSpeciesNodeConcentration(1,1:d.MSXSpeciesCount)
% d.plotMSXSpeciesNodeConcentration(2,1:d.MSXSpeciesCount)
% d.plotMSXSpeciesNodeConcentration(3,1:d.MSXSpeciesCount)
% % Plot concentration for specific link and all species
% d.plotMSXSpeciesLinkConcentration(1,1:d.MSXSpeciesCount)
% d.plotMSXSpeciesLinkConcentration(2,1:d.MSXSpeciesCount)
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
    case {8,9}
        Location_B = {'J2'}; % NodeID here;
        flowRate_B = [100]; % unit: GPM
        Price_B = [1];
    otherwise
        disp('other value')
end
NodeID = Variable_Symbol_Table(1:nodeCount,1);
%[q_B,C_B] = InitialBoosterFlow(nodeCount,Location_B,flowRate_B,NodeID,C_B);
[q_B,Price_B,BoosterLocationIndex,BoosterCount] = InitialBooster(nodeCount,Location_B,flowRate_B,NodeID,Price_B);

% Compute Quality without MSX
% (This function contains events) Don't uncomment this commands!!! Crash
% easily
qual_res = d.getComputedQualityTimeSeries; %Value x Node, Value x Link
LinkQuality = qual_res.LinkQuality;
NodeQuality = qual_res.NodeQuality;

C0 = [NodeQuality(1,:) LinkQuality(1,:)];

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
SimutionTimeInMinute = Constants4Concentration.SimutionTimeInMinute;

PreviousValue = struct('PreviousDelta_t',PreviousDelta_t,...
    'PreviousSystemDynamicMatrix',PreviousSystemDynamicMatrix,...
    'X_estimated',X_estimated,...
    'U_C_B_eachMin',0,...
    'UeachMinforEPANET',0);

NodeCount=1:d.getNodeCount;%index node
LinkCount=1:d.getLinkCount;%index link
SpeciesCount=1:d.getMSXSpeciesCount;

uu = SpeciesCount
ss = NodeCount
value.NodeQuality = cell(1, length(NodeCount));
value.LinkQuality = cell(1, length(LinkCount));
% Obtain a hydraulic solution   Don't uncomment this commands!!! Crash
d.solveMSXCompleteHydraulics

k=1; tleft=1;t=0;
value.Time(k, :)=0;
time_step = d.getMSXTimeStep;
timeSmle=d.getTimeSimulationDuration;%bug at time

tleft=1;
tInMin = 0;
delta_t = 0;

d.openHydraulicAnalysis;
d.openQualityAnalysis;
d.initializeHydraulicAnalysis(0);
d.initializeQualityAnalysis(0);
% profile on
tic
%while (tleft>0 && tInMin < SimutionTimeInMinute && delta_t <= 60)
while (tleft>0 && d.Errcode==0 && timeSmle~=t && delta_t <= 60)
    d.runHydraulicAnalysis
    [t, tleft]=d.stepMSXQualityAnalysisTimeLeft;
    
    Head=[Head; d.getNodeHydaulicHead];
    Flow=[Flow; d.getLinkFlows];
    TempDemand = d.getNodeActualDemand;
    JunctionActualDemand = [JunctionActualDemand; TempDemand(NodeJunctionIndex)];
    
    [NodeQuality,LinkQuality] = ObtainSpeciesConcentration(d,t,time_step,NodeCount,LinkCount,SpeciesCount);
    
    % Obtain the actual Concentration
    for i = NodeCount
        value.NodeQuality{i}(k,:) = NodeQuality{i};
    end
    for i = LinkCount
        value.LinkQuality{i}(k,:) = LinkQuality{i};
    end
    
%     if t<time_step || t==time_step
%         i=1;
%         for nl=ss
%             g=1;
%             for j=uu
%                 value.NodeQuality{i}(k, g)=d.getMSXNodeInitqualValue{(nl)}(j);
%                 g=g+1;
%             end
%             i=i+1;
%         end
%     else
%         i=1;
%         for nl=ss
%             g=1;
%             for j=uu
%                 d.getMSXSpeciesConcentration(0, (nl), j)
%                 value.NodeQuality{i}(k, g)=d.getMSXSpeciesConcentration(0, (nl), j);%node code0
%                 g=g+1;
%             end
%             i=i+1;
%         end
%         
%     end
    if k>1
        value.Time(k, :)=t;
    end
    k = k + 1;
    T=[T; t];
    
    
    tsstep = d.nextHydraulicAnalysisStep
    %    qststep = d.nextQualityAnalysisStep
end
d.closeQualityAnalysis;
d.closeHydraulicAnalysis;
toc

QNode = d.getMSXComputedQualityNode
QLink = d.getMSXComputedQualityLink

close all
NodeID4Legend = Variable_Symbol_Table2(d.getNodeIndex,1);
LinkID4Legend = Variable_Symbol_Table2(nodeCount+d.getLinkIndex,1);


figure
plot(JunctionActualDemand)
xlabel('Time (minute)')
ylabel('Demand at junctions (GPM)')

legend(NodeID4Legend)


figure
plot(Flow)
legend(LinkID4Legend)
xlabel('Time (minute)')
ylabel('Flow rates in links (GPM)')