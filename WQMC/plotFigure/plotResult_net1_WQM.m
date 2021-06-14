clear
close all;
clc

load('Net1_4days.mat')
% plotDemandPipeFlowRateSeperately_net1

% InterestedTime2 = 800;
% plotControlActionU_net1_4days(ControlActionU,BoosterLocationIndex,Location_B,InterestedTime2)
InterestedID = {'J11','J22','J31'};
InterestedTime1 = 70;
InterestedTime2 = 140;
FileName = 'EnlargedJunction_Net1_WQM_LDE';
plotJunction_WQM_LDE
FileName = 'EnlargedJunction_Net1_WQM_EPANET';
plotJunction_WQM_EPANET

InterestedTime1 = 70;
InterestedTime2 = 140;
InterestedID = {'P21','P31','P110'};
FileName = 'EnlargedPipe_Net1_WQM_LDE';
plotPipe_WQM_LDE
FileName = 'EnlargedPipe_Net1_WQM_EPANET';
plotPipe_WQM_EPANET

