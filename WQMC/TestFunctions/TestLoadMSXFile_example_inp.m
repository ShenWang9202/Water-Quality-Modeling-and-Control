clear; clc;  close all
start_toolkit;

% Load EPANET Network and MSX
G = epanet('example.inp'); % Load EPANET Input file
G.loadMSXFile('example.msx'); % Load MSX file

sensor_id = {'C'};
sensor_index = G.getNodeIndex(sensor_id);
node_id = G.getNodeNameID;

%% Run
Q = G.getMSXComputedQualityNode(sensor_index); % Solve hydraulics and MSX quality dynamics

% Plot concentration for specific node and all species 
G.plotMSXSpeciesNodeConcentration(1,1:G.MSXSpeciesCount)
G.plotMSXSpeciesNodeConcentration(2,1:G.MSXSpeciesCount)
% Plot concentration for specific link and all species 
G.plotMSXSpeciesLinkConcentration(1,1:G.MSXSpeciesCount)
G.plotMSXSpeciesLinkConcentration(2,1:G.MSXSpeciesCount)


% The result of node C
clear quality
j = 1;
for i=1:length(Q.Time)
    if mod(Q.Time(i), 7200)==0
        
        quality(j, 1) = Q.Time(i)/3600;
        
        for s=1:G.getMSXSpeciesCount
            quality(j, s+1) = Q.Quality{1}(i, s); 
        end
        j = j + 1;
        
    end
end

quality

G.unloadMSX