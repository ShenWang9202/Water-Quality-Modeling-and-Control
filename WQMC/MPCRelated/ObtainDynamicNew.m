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

TankMassMatrix = aux.TankMassMatrix;
MassEnergyMatrix = aux.MassEnergyMatrix;
NumberofSegment4Pipes = aux.NumberofSegment4Pipes;
LinkID = aux.LinkID;

PipeIndex = IndexInVar.PipeIndex;
PumpIndex = IndexInVar.PumpIndex;
ValveIndex = IndexInVar.ValveIndex;

JunctionCount = double(ElementCount.JunctionCount);
ReservoirCount = double(ElementCount.ReservoirCount);
nodeCount = double(ElementCount.nodeCount);

% Step 2, if all flows are positive, we can continue on

% for Pipes (non-first segments)
EnergyMatrixPipe= MassEnergyMatrixWithDirection(PipeIndex,:);
% A_P = ConstructMatrixForPipeNew_NoneFirstSeg(delta_t,CurrentFlowWithDirection,EnergyMatrixPipe,ElementCount,IndexInVar,aux,PipeReactionCoeff);
% A_P = ConstructMatrixForPipeNew_NoneFirstSeg_Speed(delta_t,CurrentFlowWithDirection,EnergyMatrixPipe,ElementCount,IndexInVar,aux,PipeReactionCoeff);
%A_P = ConstructMatrixForPipeNew_NoneFirstSeg_SpeedUp(delta_t,CurrentFlowWithDirection,EnergyMatrixPipe,ElementCount,IndexInVar,aux,PipeReactionCoeff);
A_P = ConstructMatrixForPipeNew_NoneFirstSeg_SpeedUpUp(delta_t,CurrentFlowWithDirection,EnergyMatrixPipe,ElementCount,IndexInVar,aux,PipeReactionCoeff);
% for reservoirs
A_R = ConstructMatrixForReservoir(ElementCount,IndexInVar);
B_R = sparse(ReservoirCount,nodeCount);

% for tanks
[A_TK,B_TK,~] = ConstructMatrixForTank(delta_t,CurrentFlow,CurrentNodeTankVolume,TankMassMatrix,ElementCount,IndexInVar,aux,q_B,flipped);

% for junctions in none D set
JunctionDecayRate_sec = PipeReactionCoeff(1); % all pipes has the same decay rate, and we just use the first one.
JunctionDecayRate_step = JunctionDecayRate_sec * delta_t;
[A_J, B_J] = ConstructMatrixForJunction_NoneD(CurrentFlow,MassEnergyMatrix,flipped,ElementCount,IndexInVar,q_B,aux,JunctionDecayRate_step);

% for Pumps
% B_M = sparse(PumpCount,nodeCount);
UpstreamNode_Amatrix = [A_J;A_R;A_TK];
UpstreamNode_Bmatrix = [B_J;B_R;B_TK];
EnergyMatrixPump= MassEnergyMatrix(PumpIndex,:);
[A_M,B_M] = ConstructMatrixForPumpNew(EnergyMatrixPump,UpstreamNode_Amatrix,UpstreamNode_Bmatrix);

% for Valves
% B_W = sparse(ValveCount,nodeCount);
EnergyMatrixValve= MassEnergyMatrix(ValveIndex,:);
[A_W,B_W] = ConstructMatrixForValveNew(EnergyMatrixValve,UpstreamNode_Amatrix,UpstreamNode_Bmatrix);

% for junctions in D set
[A_J, B_J] = ConstructMatrixForJunction_D(CurrentFlow,MassEnergyMatrix,flipped,ElementCount,IndexInVar,q_B, A_J, B_J, aux, JunctionDecayRate_step);

% for Pipes (non-first segments)
% B_P = sparse(NumberofSegment*PipeCount,nodeCount);

B_P = sparse(sum(NumberofSegment4Pipes),nodeCount);
EnergyMatrixPipe= MassEnergyMatrixWithDirection(PipeIndex,:);


% this is not considering the first segment of a pipe

% NewUpstreamNode_Amatrix = [A_J;A_R;A_TK]; % Note this A_J includes the downstream node of pump and nodes, that is different from UpstreamNode_Amatrix
% NewUpstreamNode_Bmatrix = [B_J;B_R;B_TK]; % Same as B_J
% % [A_P,B_P] = ConstructMatrixForPipeNew_FirstSeg(EnergyMatrixPipe,ElementCount,IndexInVar,A_P,NewUpstreamNode_Amatrix,NewUpstreamNode_Bmatrix,B_P);
% [A_P,B_P] = ConstructMatrixForPipeNew_FirstSeg_SpeedUp(EnergyMatrixPipe,ElementCount,IndexInVar,A_P,NewUpstreamNode_Amatrix,NewUpstreamNode_Bmatrix,B_P);

% The following four lines are for debugging purpose
% [A_P1,B_P1] = ConstructMatrixForPipeNew_FirstSeg(EnergyMatrixPipe,ElementCount,IndexInVar,A_P,NewUpstreamNode_Amatrix,NewUpstreamNode_Bmatrix,B_P);
% [A_P2,B_P2] = ConstructMatrixForPipeNew_FirstSeg_SpeedUp(EnergyMatrixPipe,ElementCount,IndexInVar,A_P,NewUpstreamNode_Amatrix,NewUpstreamNode_Bmatrix,B_P);
% zeroExpected = full(B_P1 - B_P2);
% isempty(find(zeroExpected~=0, 1))



% construct A;
A = [A_J;A_R;A_TK;A_P;A_M;A_W];
% construct B;
B = [B_J;B_R;B_TK;B_P;B_M;B_W];

nx = IndexInVar.NumberofX; % Number of states

Pipe_CStartIndex = IndexInVar.Pipe_CStartIndex;
TargetedPipeID = aux.TargetedPipeID;
C = generateC(TargetedPipeID,LinkID,NumberofSegment4Pipes,Pipe_CStartIndex,JunctionCount,nx);
%C = speye(nx,nx);
% MAKE A B C as Sparse to save memory
A = sparse(A);
B = sparse(B);
C = sparse(C);
end