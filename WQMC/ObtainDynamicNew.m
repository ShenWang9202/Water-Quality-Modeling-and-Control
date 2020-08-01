function [A,B,C] = ObtainDynamicNew(CurrentValue,IndexInVar,aux,ElementCount,q_B)
% Update the connectivity matrix according to current water flow direction.
delta_t = CurrentValue.delta_t;
CurrentFlow = CurrentValue.CurrentFlow;
CurrentFlow = CurrentFlow';


% Step 1,update connection matrix at first.

% We need to update the old A matrix according our WFP solution,
% Since we assume a direction before we solve the WFP, but for two random
% variable, their variables is the sum of the individual one regardless of
% addition or substraction.

% Fine the negative index in PipeFlow vector
%old = aux.MassEnergyMatrix


CurrentFlowWithDirection = CurrentFlow;
MassEnergyMatrixWithDirection = aux.MassEnergyMatrix;

PipeFlow = CurrentFlow(IndexInVar.PipeIndex);
NegativePipeIndex = find(PipeFlow<0);
linkCount = ElementCount.PipeCount +  ElementCount.PumpCount +  ElementCount.ValveCount;
flipped = zeros(1,linkCount);
if(~isempty(NegativePipeIndex))
    flipped(NegativePipeIndex) = 1;%which pipe flow direction is changed;
    MatrixStruct = UpdateConnectionMatrix(IndexInVar,aux,NegativePipeIndex);
    % Update
    aux.MassEnergyMatrix = MatrixStruct.MassEnergyMatrix;
    aux.JunctionMassMatrix = MatrixStruct.JunctionMassMatrix;
    aux.TankMassMatrix = MatrixStruct.TankMassMatrix;
    % Update flow
    CurrentFlow = abs(CurrentFlow);
end
%%
CurrentNodeTankVolume = CurrentValue.CurrentNodeTankVolume;
PipeReactionCoeff = CurrentValue.PipeReactionCoeff;
Np = CurrentValue.Np;

JunctionMassMatrix = aux.JunctionMassMatrix;
TankMassMatrix = aux.TankMassMatrix;
MassEnergyMatrix = aux.MassEnergyMatrix;

PipeIndex = IndexInVar.PipeIndex;
PumpIndex = IndexInVar.PumpIndex;
ValveIndex = IndexInVar.ValveIndex;

JunctionCount= ElementCount.JunctionCount;
ReservoirCount = ElementCount.ReservoirCount;
TankCount = ElementCount.TankCount;
PipeCount = ElementCount.PipeCount;
PumpCount= ElementCount.PumpCount;
ValveCount = ElementCount.ValveCount;


JunctionCount = double(JunctionCount);
ReservoirCount = double(ReservoirCount);
TankCount = double(TankCount);
nodeCount = JunctionCount + ReservoirCount + TankCount;
NumberofSegment = Constants4Concentration.NumberofSegment;

% Step 2, if all flows are positive, we can continue on

% for Pipes (non-first segments)
EnergyMatrixPipe= MassEnergyMatrixWithDirection(PipeIndex,:);
A_P = ConstructMatrixForPipeNew_NoneFirstSeg(delta_t,CurrentFlowWithDirection,EnergyMatrixPipe,ElementCount,IndexInVar,aux,PipeReactionCoeff);

% for reservoirs
A_R = ConstructMatrixForReservoir(ElementCount,IndexInVar);
B_R = sparse(ReservoirCount,nodeCount);

% for tanks
[A_TK,B_TK,~] = ConstructMatrixForTank(delta_t,CurrentFlow,CurrentNodeTankVolume,TankMassMatrix,ElementCount,IndexInVar,aux,q_B);
% for junctions in none D set
[A_J, B_J] = ConstructMatrixForJunction_NoneD(CurrentFlow,MassEnergyMatrix,flipped,ElementCount,IndexInVar,q_B);

% for Pumps
B_M = sparse(PumpCount,nodeCount);
UpstreamNode_Amatrix = [A_J;A_R;A_TK];
UpstreamNode_Bmatrix = [B_J;B_R;B_TK];
EnergyMatrixPump= MassEnergyMatrix(PumpIndex,:);
[A_M,B_M] = ConstructMatrixForPumpNew(EnergyMatrixPump,UpstreamNode_Amatrix,UpstreamNode_Bmatrix);

% for Valves
B_W = sparse(ValveCount,nodeCount);
EnergyMatrixValve= MassEnergyMatrix(ValveIndex,:);
[A_W,B_W] = ConstructMatrixForValveNew(EnergyMatrixValve,UpstreamNode_Amatrix,UpstreamNode_Bmatrix);

% for junctions in D set
[A_J, B_J] = ConstructMatrixForJunction_D(CurrentFlow,MassEnergyMatrix,flipped,ElementCount,IndexInVar,q_B, A_J, B_J);

% for Pipes (non-first segments)
B_P = sparse(NumberofSegment*PipeCount,nodeCount);
EnergyMatrixPipe= MassEnergyMatrixWithDirection(PipeIndex,:);
NewUpstreamNode_Amatrix = [A_J;A_R;A_TK]; % Note this A_J includes the downstream node of pump and nodes, that is different from UpstreamNode_Amatrix
NewUpstreamNode_Bmatrix = [B_J;B_R;B_TK]; % Same as B_J
[A_P,B_P] = ConstructMatrixForPipeNew_FirstSeg(EnergyMatrixPipe,ElementCount,aux,A_P,NewUpstreamNode_Amatrix,NewUpstreamNode_Bmatrix,B_P);

% construct A;
A = [A_J;A_R;A_TK;A_P;A_M;A_W];
% construct B;
B = [B_J;B_R;B_TK;B_P;B_M;B_W];

NumberofX = double(JunctionCount + ReservoirCount + TankCount + ...
    PipeCount * NumberofSegment + PumpCount + ValveCount);
nx = NumberofX; % Number of states

C = generateC(nx);

% MAKE A B C as Sparse to save memory
A = sparse(A);
B = sparse(B);
C = sparse(C);
end