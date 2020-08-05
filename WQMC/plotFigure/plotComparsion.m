
figure
subplot(2,1,1)
plot(QsN_Control);
legend(NodeID,'Location','eastoutside')
xlabel('Time (minute)')
ylabel('Concentrations at junctions (mg/L)')
title('EPAENT result')
subplot(2,1,2)
plot(QsL_Control);
legend(LinkID,'Location','eastoutside')
xlabel('Time (minute)')
ylabel('Concentrations in links (mg/L)')

% find average data;
X_Min_Average = mergePipeSegment(XX_estimated,IndexInVar,aux,ElementCount);

X_Min_Average = X_Min_Average';
X_node_control_result =  X_Min_Average(:,NodeIndex);
X_link_control_result =  X_Min_Average(:,LinkIndex);
X_Junction_control_result =  X_Min_Average(:,NodeJunctionIndex);
% X_link_control_result =  X_Min_Average(:,LinkIndex);


figure
subplot(2,1,1)
plot(X_node_control_result);
legend(NodeID,'Location','eastoutside')
xlabel('Time (minute)')
ylabel('Concentrations at junctions (mg/L)')
title('LDE result')
subplot(2,1,2)
plot(X_link_control_result);
legend(LinkID,'Location','eastoutside')
xlabel('Time (minute)')
ylabel('Concentrations in links (mg/L)')



epanetResult1 = [NodeQuality LinkQuality];
epanetResult = [QsN_Control QsL_Control];
% note that the above are both from EPAENT, their result are a little bit
% different. I believe this because they use different method to implement
% this.

LDEResult = [X_node_control_result X_link_control_result];
LDEResult1 = updateLDEResult(LDEResult,IndexInVar,MassEnergyMatrix);


%     Calculate_Error_EPANET_LDE(epanetResult1',LDEResult1');
%      This is for control purpose
Calculate_Error_EPANET_LDE(epanetResult',LDEResult1');

% For large scale network, we compare them in group

linkCount = d.getLinkCount;
if(linkCount > 2)
    eachGroup = 2;
    numberOfGroups = ceil(linkCount/eachGroup);
    for i = 1:numberOfGroups
        range = ((i-1)*eachGroup+1):(i*eachGroup);
        if i == numberOfGroups
            range = ((i-1)*10+1):linkCount;
        end
        InterestedID = LinkID(range,:);
        InterestedID = InterestedID';
        LDEGroup = LDEResult1(1:SimutionTimeInMinute,LinkIndex);
        %         plotInterestedComponents(InterestedID,LinkID,LDEGroup,'LDE');
        EPANETGroup = epanetResult(1:SimutionTimeInMinute,LinkIndex);
        %         plotInterestedComponents(InterestedID,LinkID,EPANETGroup,'EPANET');
        Calculate_Error_EPANET_LDE_Group(InterestedID,LinkID,EPANETGroup,LDEGroup)
    end
end

