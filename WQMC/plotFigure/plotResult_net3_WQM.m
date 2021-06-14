clear
close all;
clc

% Prepare data
load('Net3_1day_Without_Control.mat')
Calculate_Error_EPANET_LDE(epanetResult',LDEResult1')

X_node_control_result_no_control = X_node_control_result(1:1440,:);
X_link_control_result_no_control = X_link_control_result(1:1440,:);
epanetResult_no_control = epanetResult(1:1440,:); 
LDEResult1_no_control = LDEResult1(1:1440,:);
QsL_Control_no_control = QsL_Control(1:1440,:); 
QsN_Control_no_control = QsN_Control(1:1440,:);

load('Net3_1day_WithControl.mat')

% start plotting

InterestedTime1 = 1170;
InterestedTime2 = 1200;

InterestedID = {'J35','J105','J117'};
FileName = 'EnlargedJunction_Net3_WQM_LDE';
X_Min_Average = LDEResult1_no_control;
TitleName = 'LDE';
plotJunction_WQM_LDE

FileName = 'EnlargedJunction_Net3_WQM_EPANET';
TitleName = 'EPANET';
QsN_Control = QsN_Control_no_control;
plotJunction_WQM_EPANET


InterestedTime1 = 850;
InterestedTime2 = 920;
InterestedID = {'P111','P131','P277'};
FileName = 'EnlargedPipe_Net3_WQM_LDE';
TitleName = 'LDE';
plotPipe_WQM_LDE

FileName = 'EnlargedPipe_Net3_WQM_EPANET';
TitleName = 'EPANET';
QsL_Control = QsL_Control_no_control;
plotPipe_WQM_EPANET


% plot number of segments in pipes and pipe length
FileName = 'Net3LengthandPipeSegments';
ylim1 = 1000;
ylim2 = 50000;
plotPipeSegmentVSLength(FileName,ylim1,ylim2,NumberofSegment4Pipes,LinkLengthPipe,PipeCount);