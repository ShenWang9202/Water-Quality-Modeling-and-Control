function [A_J_New, B_J_New]= ConstructMatrixForJunction_D(CurrentFlow,MassEnergyMatrix,MassMatrix,ElementCount,IndexInVar,q_B,A_J,B_J)

%% find the inflows and outflows of each junctions
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
outFlow_Each_Junction = sum(inFlowMatrix);
inFlow = inFlowMatrix';
%% find the downstream junctions of pump and valves

PumpIndex = IndexInVar.PumpIndex;
ValveIndex = IndexInVar.ValveIndex;
PumpValveIndex =  [PumpIndex ValveIndex];
JunctionIndexInOrder = IndexInVar.JunctionIndexInOrder;
PumpValveEnergMatrixforJunctions = MassEnergyMatrix(PumpValveIndex,JunctionIndexInOrder);

[row,~] = size(PumpValveEnergMatrixforJunctions);
DownStreamJunctionsIndex_PumpValves = [];
% for links, -1 is its index of upstream nodes, 1 is its index of downstream nodes
for i = 1:row
     tempindex = find(PumpValveEnergMatrixforJunctions(i,:)>0);
     DownStreamJunctionsIndex_PumpValves = [DownStreamJunctionsIndex_PumpValves tempindex];
end

%% find contribution from pipes
[m,n] = size(inFlow);
contributionC = zeros(m,n); 
for i = 1:m
    if (outFlow_Each_Junction(i)~=0)
        contributionC(i,:) = inFlow(i,:)/outFlow_Each_Junction(i);
    end
end
%% find the downstram node of pump and valves

[m,~] = size(contributionC);
for i = 1:m % for each junction
    if(ismember(i,DownStreamJunctionsIndex_PumpValves)) % if this junction is the downstream nodes of pumps and valves
        % find contribution of link
        [~,Col] = find(contributionC(i,:)~=0);
        [~,n] = size(Col);
        for j=1:n
            lastSegmentIndex = findIndexofLastSegment(Col(j),IndexInVar);
            A_J(i,lastSegmentIndex) = contributionC(i,Col(j));
            % note the following three functions can be summerized as
            % these above two statements because findIndexofLastSegment
            % didn't care about wheter it is a pipe or a pump or a valve
            
%             % if this link is a pipe
%             if(ismember(Col(j),IndexInVar.PipeIndex))
%                 lastSegmentIndex = findIndexofLastSegment(Col(j),IndexInVar);
%                 A_J(i,lastSegmentIndex) = contributionC(i,Col(j));
%             end
%             
%             % if this link is a pump
%             if(ismember(Col(j),IndexInVar.PumpIndex))
%                 pumpCIndex = findIndexofLastSegment(Col(j),IndexInVar);
%                 A_J(i,pumpCIndex) = contributionC(i,Col(j));
%             end
%             
%             % if this link is a valve
%             if(ismember(Col(j),IndexInVar.ValveIndex))
%                 valveCIndex = findIndexofLastSegment(Col(j),IndexInVar);
%                 A_J(i,valveCIndex) = contributionC(i,Col(j));
%             end
        end
    end
end

for i = 1:JunctionCount % for each junction
    if(ismember(i,DownStreamJunctionsIndex_PumpValves)) % not the downstream nodes of pumps and valves
        B_J(i,JunctionIndexInOrder(i)) = q_B(JunctionIndexInOrder(i),1)/outFlow_Each_Junction(i);
    end
end

A_J_New = A_J;
B_J_New = B_J;

end