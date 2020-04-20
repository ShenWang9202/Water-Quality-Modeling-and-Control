function [A_W,B_W] = ConstructMatrixForValveNew(EnergyMatrixValve,UpstreamNode_Amatrix,UpstreamNode_Bmatrix)
EnergyMatrixValve = -EnergyMatrixValve;

% next, remove the downstream node index for valves
[m,~] = size(EnergyMatrixValve);
for i = 1:m
    downstreamNodeIndex = find(EnergyMatrixValve(:,i)<0);
    EnergyMatrixValve(i,downstreamNodeIndex) = 0;
end

A_W = EnergyMatrixValve * UpstreamNode_Amatrix;
B_W = EnergyMatrixValve * UpstreamNode_Bmatrix;
end

