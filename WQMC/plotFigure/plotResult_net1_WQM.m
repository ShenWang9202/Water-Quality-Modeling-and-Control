clear
close all;
clc

load('Net1_4days.mat')
% plotDemandPipeFlowRateSeperately_net1

% InterestedTime2 = 800;
% plotControlActionU_net1_4days(ControlActionU,BoosterLocationIndex,Location_B,InterestedTime2)
plotJunction_WQM_LDE
plotPipe_WQM_LDE

plotJunction_WQM_EPANET
plotPipe_WQM_EPANET

