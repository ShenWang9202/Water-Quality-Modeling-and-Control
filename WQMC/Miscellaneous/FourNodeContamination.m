clear; clc;  close all
start_toolkit;

% Load EPANET Network and MSX
d = epanet('Fournode-Cl-As-1.inp'); % Load EPANET Input file
%d.loadMSXFile('Threenode-cl-3.msx'); % Load MSX file, only Chlorine
d.loadMSXFile('Arsenite-4node.msx'); % Load MSX file, only Chlorine
% Compute Quality without MSX
% (This function contains events) Don't uncomment this commands!!! Crash
% easily
qual_res = d.getComputedQualityTimeSeries; %Value x Node, Value x Link
LinkQuality = qual_res.LinkQuality;
NodeQuality = qual_res.NodeQuality;


sensor_id = {'2'};
sensor_index = d.getNodeIndex(sensor_id);
node_id = d.getNodeNameID;


max_inj_conc = 0.2;
inj_start_time = 2*2*24; % after day 2 (Dt = 30min)
inj_duration = 24; % maximum duration of 12 hours
inj_sc=[sensor_index, max_inj_conc, inj_start_time, inj_duration]; % Injection location, magnitude, start time, duration 

d.getMSXSources
% HERE SHEN
d.setMSXSources(node_id(inj_sc(1)), 'AsIII', 'Setpoint', inj_sc(2), 'AS3PAT'); % Specify Arsenite injection source
as3_pat = ones(1, 5*2*24);
%as3_pat(inj_sc(3):(inj_sc(3)+inj_sc(4))) = 1; % 
d.setMSXPattern('AS3PAT',as3_pat); % Set pattern for injection

d.getMSXSources
% %% get info from EPANET
% % get index info from EPANET
% %PipeIndex = 1:d.getLinkPipeCount;
% PipeIndex = d.getLinkPipeIndex;
% PumpIndex = d.getLinkPumpIndex;
% ValveIndex = d.getLinkValveIndex;
% NodeJunctionIndex = d.getNodeJunctionIndex;
% ReservoirIndex = d.getNodeReservoirIndex;
% NodeTankIndex = d.getNodeTankIndex;
% 
% % get LinkDiameter from EPANET
% LinkDiameter = d.getLinkDiameter;
% LinkDiameterPipe = LinkDiameter(PipeIndex);
% LinkLength = d.getLinkLength;
% LinkLengthPipe = LinkLength(PipeIndex);
% 
% %%
% 
% 
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
%     QsN=[QsN; d.getNodeActualQuality];
%     QsL=[QsL; d.getLinkQuality];
%     T=[T; t];
%     tleft = d.stepQualityAnalysisTimeLeft;
% end


Q = d.getMSXComputedQualityNode(sensor_index); % Solve hydraulics and MSX quality dynamics

% Plot concentration for specific node and all species 
d.plotMSXSpeciesNodeConcentration(1,1:d.MSXSpeciesCount)
d.plotMSXSpeciesNodeConcentration(2,1:d.MSXSpeciesCount)
d.plotMSXSpeciesNodeConcentration(3,1:d.MSXSpeciesCount)
d.plotMSXSpeciesNodeConcentration(4,1:d.MSXSpeciesCount)
% Plot concentration for specific link and all species 
d.plotMSXSpeciesLinkConcentration(1,1:d.MSXSpeciesCount)
d.plotMSXSpeciesLinkConcentration(2,1:d.MSXSpeciesCount)
d.plotMSXSpeciesLinkConcentration(3,1:d.MSXSpeciesCount)

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
