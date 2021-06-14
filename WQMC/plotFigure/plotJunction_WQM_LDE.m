X_Junction_control_result =  X_Min_Average(:,NodeJunctionIndex);
faceColor = 'b';
transparency = 0.2;
fontSize = 40;
lineWidth = 3.5;
InterestedID = {'J11','J22','J31'};
% Since the first junction is J10, however, it is uncontrollable, and the
% data is always 1, we don't display the concentration of J10
%IngoreID = {'J10'};

InterestedTime2 = 140;
BlueLineWidth = 3.5;
FileName = 'EnlargedJunction_Net1_WQM_LDE';
plotMinMaxRange4Junction_WQM(X_Junction_control_result,InterestedID,JunctionID,faceColor,transparency,fontSize,BlueLineWidth,lineWidth,InterestedTime2,FileName)

% lineWidth = 3.5;
% InterestedID = {'J21','J31'};
% InterestedTime2 = 800;
% BlueLineWidth = 2;
% plotMinMaxRange4Junction_WQM(X_Junction_control_result,InterestedID,JunctionID,faceColor,transparency,fontSize,BlueLineWidth,lineWidth,InterestedTime2)
