function PreviousSystemDynamicMatrix = ObtainSystemDynamic(CurrentValue,IndexInVar,aux,ElementCount)
% Here we need to know the current concentration vector x which includes
% the c^J, c^R, c^TK, c^P, c^M, and c^W.

delta_t = CurrentValue.delta_t;

JunctionCount= ElementCount.JunctionCount;
ReservoirCount = ElementCount.ReservoirCount;
TankCount = ElementCount.TankCount;

JunctionCount = double(JunctionCount);
ReservoirCount = double(ReservoirCount);
TankCount = double(TankCount);
nodeCount = JunctionCount + ReservoirCount + TankCount;

flowRate_B = aux.flowRate_B;
q_B = aux.q_B;
Price_B = aux.Price_B;
BoosterLocationIndex = aux.BoosterLocationIndex;
BoosterCount = aux.BoosterCount;

Np = CurrentValue.Np;
[A,B,C] = ObtainDynamicNew(CurrentValue,IndexInVar,aux,ElementCount,q_B);

B = B(:,BoosterLocationIndex);

PreviousSystemDynamicMatrix = struct('A',A,...
    'B',B,...
    'C',C);