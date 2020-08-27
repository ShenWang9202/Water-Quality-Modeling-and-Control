clear; clc;  close all
start_toolkit;

% Load EPANET Network and MSX

% 3-node network
%d = epanet('Threenode-cl-3.inp'); % Load EPANET Input file
%d.loadMSXFile('Threenode-cl-3.msx'); % Load MSX file, only Chlorine
%d.loadMSXFile('Arsenite.msx'); % Load MSX file, only Chlorine

% 4-node network
d = epanet('Fournode-Cl-As-2.inp'); % Load EPANET Input file
%d.loadMSXFile('Threenode-cl-3.msx'); % Load MSX file, only Chlorine
d.loadMSXFile('Arsenite.msx'); % Load MSX file, multispecies

% Compute Quality without MSX
% (This function contains events) Don't uncomment this commands!!! Crash
% easily
qual_res = d.getComputedQualityTimeSeries; %Value x Node, Value x Link
LinkQuality = qual_res.LinkQuality;
NodeQuality = qual_res.NodeQuality;


sensor_id = {'2'};
sensor_index = d.getNodeIndex(sensor_id);
node_id = d.getNodeNameID;


max_inj_conc = 2;
max_inj_mass = 200;
inj_start_time = 2*2*24; % after day 2 (Dt = 30min)
inj_duration = 24; % maximum duration of 12 hours
inj_sc=[sensor_index, max_inj_conc, inj_start_time, inj_duration]; % Injection location, magnitude, start time, duration

d.getMSXSources
%d.setMSXSources(node_id(inj_sc(1)), 'Chlorine', 'Mass', inj_sc(2), 'AS3PAT'); % Specify Arsenite injection source
d.setMSXSources(node_id(inj_sc(1)), 'AsIII', 'SetPoint', inj_sc(2), 'AS3PAT'); % Specify Arsenite injection source
as3_pat = ones(1, 1);
%as3_pat(inj_sc(3):(inj_sc(3)+inj_sc(4))) = 1; %
d.setMSXPattern('AS3PAT',as3_pat); % Set pattern for injection
d.getMSXSources

%% solving for water quality results in overall step fashion

% Q = d.getMSXComputedQualityNode(sensor_index); % Solve hydraulics and MSX quality dynamics
% Plot concentration for specific node and all species
d.plotMSXSpeciesNodeConcentration(1,1:d.MSXSpeciesCount)
d.plotMSXSpeciesNodeConcentration(2,1:d.MSXSpeciesCount)
d.plotMSXSpeciesNodeConcentration(3,1:d.MSXSpeciesCount)
d.plotMSXSpeciesNodeConcentration(4,1:d.MSXSpeciesCount)
% Plot concentration for specific link and all species
d.plotMSXSpeciesLinkConcentration(1,1:d.MSXSpeciesCount)
d.plotMSXSpeciesLinkConcentration(2,1:d.MSXSpeciesCount)


%% solving for water quality results in step-wise fashion
% get index info from EPANET
%PipeIndex = 1:d.getLinkPipeCount;
PipeIndex = d.getLinkPipeIndex;
PumpIndex = d.getLinkPumpIndex;
ValveIndex = d.getLinkValveIndex;
NodeJunctionIndex = d.getNodeJunctionIndex;
ReservoirIndex = d.getNodeReservoirIndex;
NodeTankIndex = d.getNodeTankIndex;

% get LinkDiameter from EPANET
LinkDiameter = d.getLinkDiameter;
LinkDiameterPipe = LinkDiameter(PipeIndex);
LinkLength = d.getLinkLength;
LinkLengthPipe = LinkLength(PipeIndex);

% Since we are loading MSX file now, the d.getMSXComputedQualityLink is not
% working. d.getMSXComputedQualityLink only works with the quality
% reactions dynamic in .inp files

% d.openQualityAnalysis
% d.initializeQualityAnalysis
% tleft=1; P=[];T=[];QsN=[]; QsL=[]; Velocity=[]; Head=[];
% Flow=[]; JunctionActualDemand=[]; NodeTankVolume = [];NodeNetFlowTank = [];
% while (tleft>0)
%     %Add code which changes something related to quality
%     t=d.runQualityAnalysis;
%     P=[P; d.getNodePressure];
%     Head=[Head; d.getNodeHydaulicHead];
%     Flow=[Flow; d.getLinkFlows];
%     Velocity = [Velocity; d.getLinkVelocity];
%     TempDemand = d.getNodeActualDemand;
%     JunctionActualDemand = [JunctionActualDemand; TempDemand(NodeJunctionIndex)];
%     NodeNetFlowTank = [NodeNetFlowTank; TempDemand(NodeTankIndex)];
%     Volume = d.getNodeTankVolume;
%     NodeTankVolume = [NodeTankVolume; Volume(NodeTankIndex)];
%     QualityNode = d.getMSXSpeciesConcentration(0,1,1)
%     QualityNode = d.getMSXSpeciesConcentration(0,1,2)
%     QualityNode = d.getMSXSpeciesConcentration(0,1,3)
%     QsN=[QsN; d.getMSXSpeciesConcentration(0,1,1)];
%     %QsL=[QsL; d.getMSXComputedQualityLink];
%     T=[T; t];
%     tleft = d.stepQualityAnalysisTimeLeft;
% end


%% getMSXComputedQualitySpecie
% %the following code is equivalient to d.getMSXComputedQualitySpecie('Chlorine')
% link_indices = d.getLinkIndex;%for all link index
% node_indices = d.getNodeIndex;%for all node index
% %             specie_name = d.getMSXSpeciesIndex('Chlorine');
% %             specie_name = d.getMSXSpeciesIndex('AsIII');
% specie_name = d.getMSXSpeciesIndex('AsV');
% value.NodeQuality = nan(1, length(node_indices));
% value.LinkQuality = nan(1, length(node_indices));
% % Obtain a hydraulic solution
% d.solveMSXCompleteHydraulics;
% % Run a step-wise water quality analysis without saving
% % RESULTS to file
% d.initializeMSXQualityAnalysis(0);
% % Retrieve species concentration at node
% k=1; tleft=1;t=0;
% value.Time(k, :)=0;
% time_step = d.getMSXTimeStep;
% timeSmle=d.getTimeSimulationDuration;%bug at time
% while(tleft>0 && timeSmle~=t)
%     [t, tleft]=d.stepMSXQualityAnalysisTimeLeft;
%     if t<time_step || t==time_step
%         if node_indices(end) < link_indices(end)
%             for lnk=link_indices
%                 value.LinkQuality(k, lnk)=d.getMSXLinkInitqualValue{lnk}(specie_name);
%                 if lnk < node_indices(end) + 1
%                     value.NodeQuality(k, lnk)=obj.getMSXNodeInitqualValue{lnk}(specie_name);
%                 end
%             end
%         else
%             for lnk=node_indices
%                 value.NodeQuality(k, lnk)=d.getMSXNodeInitqualValue{lnk}(specie_name);
%                 if lnk < link_indices(end) + 1
%                     value.LinkQuality(k, lnk)=d.getMSXLinkInitqualValue{lnk}(specie_name);
%                 end
%             end
%         end
%     else
%         if node_indices(end) < link_indices(end)
%             for lnk=link_indices
%                 value.LinkQuality(k, lnk)=d.getMSXSpeciesConcentration(1, lnk, specie_name);%link code 1
%                 if lnk < node_indices(end) + 1
%                     value.NodeQuality(k, lnk)=d.getMSXSpeciesConcentration(0, lnk, specie_name);%node code0
%                 end
%             end
%         else
%             for lnk=node_indices
%                 value.NodeQuality(k, lnk)=d.getMSXSpeciesConcentration(0, lnk, specie_name);%link code 1
%                 if lnk < link_indices(end) + 1
%                     value.LinkQuality(k, lnk)=d.getMSXSpeciesConcentration(1, lnk, specie_name);%node code0
%                 end
%             end
%         end
%     end
%     if k>1
%         value.Time(k, :)=t;
%     end
%     k=k+1;
% end
%% node 

% NodeCount=1:d.getNodeCount;%index node
% LinkCount=1:d.getLinkCount;%index link
% SpeciesCount=1:d.getMSXSpeciesCount;
% 
% value.NodeQuality = cell(1, length(NodeCount));
% value.LinkQuality = cell(1, length(LinkCount));
% % Obtain a hydraulic solution
% d.solveMSXCompleteHydraulics;
% % Run a step-wise water quality analysis without saving
% % RESULTS to file
% d.initializeMSXQualityAnalysis(0);
% % Retrieve species concentration at node
% k=1; tleft=1;t=0;
% value.Time(k, :)=0;
% time_step = d.getMSXTimeStep;
% timeSmle=d.getTimeSimulationDuration;%bug at time
% while(tleft>0 && d.Errcode==0 && timeSmle~=t)
%     [t, tleft]=d.stepMSXQualityAnalysisTimeLeft;
%         if t<time_step || t==time_step
%             i=1;
%             for nl=NodeCount
%                 g=1;
%                 for j=SpeciesCount
%                     value.NodeQuality{i}(k, g)=d.getMSXNodeInitqualValue{(nl)}(j);
%                     g=g+1;
%                 end
%                 i=i+1;
%             end
%         else
%             i=1;
%             for nl=NodeCount
%                 g=1;
%                 for j=SpeciesCount
%                     value.NodeQuality{i}(k, g)=d.getMSXSpeciesConcentration(0, (nl), j);%node code0
%                     g=g+1;
%                 end
%                 i=i+1;
%             end
%         end
% 
%     if k>1
%         value.Time(k, :)=t;
%     end
%     k=k+1;
% end

%% node and link

NodeCount=1:d.getNodeCount;%index node
LinkCount=1:d.getLinkCount;%index link
SpeciesCount=1:d.getMSXSpeciesCount;

value.NodeQuality = cell(1, length(NodeCount));
value.LinkQuality = cell(1, length(LinkCount));
% Obtain a hydraulic solution
d.solveMSXCompleteHydraulics;
% Run a step-wise water quality analysis without saving
% RESULTS to file
d.initializeMSXQualityAnalysis(0);
% Retrieve species concentration at node
k=1; tleft=1;t=0;
value.Time(k, :)=0;
time_step = d.getMSXTimeStep;
timeSmle=d.getTimeSimulationDuration;%bug at time
while(tleft>0 && d.Errcode==0 && timeSmle~=t)
    [t, tleft]=d.stepMSXQualityAnalysisTimeLeft;
    [NodeQuality,LinkQuality] = ObtainSpeciesConcentration(d,t,time_step,NodeCount,LinkCount,SpeciesCount);
    NodeQuality
    LinkQuality
    for i = NodeCount
        value.NodeQuality{i}(k,:) = NodeQuality{i};
    end
    for i = LinkCount
        value.LinkQuality{i}(k,:) = LinkQuality{i};
    end
    if k>1
        value.Time(k, :)=t;
    end
    k=k+1;
end




%
%
% %%  Case Study for CCWI2016
% %https://github.com/KIOS-Research/CCWI2016/tree/master/CCWI2016
% % the paper and presentation are also available here
% close all; clear; rng(1)
%
% %% Load EPANET Network and MSX
% G = epanet('Threenode-cl-3.inp'); % Load EPANET Input file
% %G.loadMSXFile('Arsenite.msx'); % Load MSX file
%
% % Sensor locations
% sensor_id = {'2'};
% sensor_index = G.getNodeIndex(sensor_id);
%
% %% Simulation Setup
% % t_d = 5; % days
% % G.setTimeSimulationDuration(t_d*24*60*60); % Set simulation duration of 5 days
%
% %% Get Network data
% demand_pattern = G.getPattern;
% roughness_coeff = G.getLinkRoughnessCoeff;
% node_id = G.getNodeNameID;
%
% %% Scenarios
% Ns = 1; % Number of scenarios to simulate
% u_p = 0.20; % pattern uncertainty
% u_r = 0.20; % roughness coefficient uncertainty
% max_inj_conc = 2.0;
% inj_start_time = 2*48; % after day 2 (Dt = 30min)
% inj_duration = 24; % maximum duration of 12 hours
% % Injection location, magnitude, start time, duration
% %inj_sc=[randi(G.NodeCount,Ns,1), max_inj_conc*rand(Ns,1), randi(48,Ns,1)+inj_start_time, randi(inj_duration,Ns,1)];
% % Injection location, magnitude, start time, duration
% inj_sc=[1, max_inj_conc, inj_start_time, 10];
% %% Run epochs
%
% %     G.setMSXSources(node_id(inj_sc(i,1)), 'AsIII', 'Setpoint', inj_sc(i,2), 'AS3PAT'); % Specify Arsenite injection source
% %     as3_pat = zeros(1, t_d*48);
% %     as3_pat(inj_sc(i,3):(inj_sc(i,3)+inj_sc(i,4))) = 1; %
% %     G.setMSXPattern('AS3PAT',as3_pat); % Set pattern for injection
% %     Q{i} = G.getMSXComputedQualityNode; % Solve hydraulics and MSX quality dynamics
% %     G.setMSXSources(node_id(inj_sc(i,1)), 'AsIII', 'Setpoint', 0, 'AS3PAT'); % Reset injection source
%
%
%
% %% Plot results
% % for i = 1:Ns
% %     for j = 1:length(sensor_index)
% %        subplot(5,1,j)
% %        plot(Q{i}.Time/24/60/60, Q{i}.Quality{j}(:,1),'-','Color',[0,0.7,0.9]); hold on; grid on
% %     end
% % end
% % for i = 1:length(sensor_index)
% %    subplot(5,1,i)
% %    title(sensor_id{i})
% %    ylabel('Cl_2 (mg/L)')
% %    xlabel('Time (days)')
% % end
% % Plot concentration for specific node and all species
% % G.plotMSXSpeciesNodeConcentration(1,1:G.MSXSpeciesCount)
% %
% % % Plot concentration for specific link and all species
% % G.plotMSXSpeciesLinkConcentration(1,1:G.MSXSpeciesCount)
% %
% % G.unloadMSX
