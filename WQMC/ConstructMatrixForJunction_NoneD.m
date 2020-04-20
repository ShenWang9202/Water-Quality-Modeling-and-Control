function [A_J, B_J]= ConstructMatrixForJunction_NoneD(CurrentFlow,MassEnergyMatrix,MassMatrix,ElementCount,IndexInVar,q_B)
% CurrentFlow = Flow(1,:);
% CurrentFlow = CurrentFlow';
JunctionCount = ElementCount.JunctionCount;
NumberofX = IndexInVar.NumberofX;
JunctionIndexInOrder = IndexInVar.JunctionIndexInOrder;
inFlowSelectionMatrix = MassEnergyMatrix(:,JunctionIndexInOrder);
% Next we find the outFlow of each jucntion. Sine the outflow of a junction is actual outflow in pipes + its demand, which is the inflows flow links  
% So all we need to do is just to find the inflow index
% To find the inflow index, just replace all -1 with 0
[m,n] = size(inFlowSelectionMatrix);
for i = 1:n
    inflow_index = find(inFlowSelectionMatrix(:,i)<0);
    inFlowSelectionMatrix(inflow_index,i) = 0;
end
% this outFlow already include demand

inFlowMatrix = inFlowSelectionMatrix .* CurrentFlow;
outFlowofEachJuction = sum(inFlowMatrix);
outFlow = outFlowofEachJuction;
inFlow = inFlowMatrix';
%% find contribution from pipes
[m,n] = size(inFlow);
contributionC = zeros(m,n); 
for i = 1:m
    if (outFlow(i)~=0)
        contributionC(i,:) = inFlow(i,:)/outFlow(i);
    end
end
%% find the downstram node of pump and valves

PumpIndex = IndexInVar.PumpIndex;
ValveIndex = IndexInVar.ValveIndex;
PumpValveIndex =  [PumpIndex ValveIndex];
PumpValveEnergMatrix = MassEnergyMatrix(PumpValveIndex,:);
[row,~] = size(PumpValveEnergMatrix);
DownStreamNodesIndex_PumpValves = [];
% for links, -1 is its index of upstream nodes, 1 is its index of downstream nodes
for i = 1:row
     tempindex = find(PumpValveEnergMatrix(i,:)>0);
     DownStreamNodesIndex_PumpValves = [DownStreamNodesIndex_PumpValves tempindex];
end

A_J = zeros(JunctionCount,NumberofX);

[m,~] = size(contributionC);
for i = 1:m % for each junction
    if(~ismember(i,DownStreamNodesIndex_PumpValves)) % if this junction is not the downstream nodes of pumps and valves
        % find contribution of link
        [~,Col] = find(contributionC(i,:)~=0);
        [~,n] = size(Col);
        for j=1:n
            lastSegmentIndex = findIndexofLastSegment(Col(j),IndexInVar);
            A_J(i,lastSegmentIndex) = contributionC(i,Col(j));
        end
    end
end


[NodeCount,~] = size(q_B);
B_J = zeros(JunctionCount,NodeCount);

for i = 1:JunctionCount % for each junction
    if(~ismember(i,DownStreamNodesIndex_PumpValves)) % not the downstream nodes of pumps and valves
        B_J(i,JunctionIndexInOrder(i)) = q_B(JunctionIndexInOrder(i),1)/outFlow(i);
    end
end


end