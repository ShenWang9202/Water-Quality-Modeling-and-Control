X_Pipe_control_result =  QsL_Control(:,PipeIndex);
faceColor = 'b';
transparency = 0.2;
fontSize = 40;
lineWidth = 3.5;
InterestedID = {'P21','P31','P110'};
% Since the first junction is J10, however, it is uncontrollable, and the
% data is always 1, we don't display the concentration of J10
%IngoreID = {'J10'};
InterestedTime2 = 140;
BlueLineWidth = 3.5;
FileName = 'EnlargedPipe_Net1_WQM_EPANET';
plotMinMaxRange4Pipe_WQM(X_Pipe_control_result,InterestedID,PipeID,faceColor,transparency,fontSize,BlueLineWidth,lineWidth,InterestedTime2,FileName)

% InterestedID = {'P31','P110'};
% InterestedTime2 = 800;
% lineWidth = 3.5;
% BlueLineWidth = 2;
% plotMinMaxRange4Pipe_WQM(X_Pipe_control_result,InterestedID,PipeID,faceColor,transparency,fontSize,BlueLineWidth,lineWidth,InterestedTime2)
