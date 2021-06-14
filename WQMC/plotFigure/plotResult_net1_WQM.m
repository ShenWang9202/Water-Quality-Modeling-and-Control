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

TitleName = 'LDE';
FileName = 'EnlargedJunction_Net1_WQM_LDE_small';
plotJunction_WQM_LDE

TitleName = 'EPANET';
FileName = 'EnlargedJunction_Net1_WQM_EPANET_small';
plotJunction_WQM_EPANET

InterestedTime1 = 70;
InterestedTime2 = 140;
InterestedID = {'P21','P31','P110'};
FileName = 'EnlargedPipe_Net1_WQM_LDE_small';
TitleName = 'LDE';
plotPipe_WQM_LDE

TitleName = 'EPANET';
FileName = 'EnlargedPipe_Net1_WQM_EPANET_small';
plotPipe_WQM_EPANET

% plot number of segments in pipes and pipe length
FileName = 'Net1LengthandPipeSegments';
ylim1 = 300;
ylim2 = 12000;
plotPipeSegmentVSLength(FileName,ylim1,ylim2,NumberofSegment4Pipes,LinkLengthPipe,PipeCount);

