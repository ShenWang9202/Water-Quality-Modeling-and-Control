clear; clc;  close all
start_toolkit;

% Load EPANET Network and MSX
G = epanet('Threenode-cl-2.inp'); % Load EPANET Input file
%G.loadMSXFile('Chlorine.msx'); % Load MSX file

sensor_id = {'2'};
sensor_index = G.getNodeIndex(sensor_id);
node_id = G.getNodeNameID;

%% Run
H = G.getComputedHydraulicTimeSeries;
Flow = H.Flow;
Head = H.Head;
qual_res = G.getComputedQualityTimeSeries % Solve hydraulics and MSX quality dynamics
%Q = G.getMSXComputedQualityNode(sensor_index); 

% Plot concentration for specific node and all species 
% G.plotMSXSpeciesNodeConcentration(1,1:G.MSXSpeciesCount)
% G.plotMSXSpeciesNodeConcentration(2,1:G.MSXSpeciesCount)
% G.plotMSXSpeciesNodeConcentration(3,1:G.MSXSpeciesCount)
% % Plot concentration for specific link and all species 
% G.plotMSXSpeciesLinkConcentration(1,1:G.MSXSpeciesCount)
% G.plotMSXSpeciesLinkConcentration(2,1:G.MSXSpeciesCount)


