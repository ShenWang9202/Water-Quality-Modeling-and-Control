 function [UeachMinforEPANET,U_C_B_eachMin,PreviousSystemDynamicMatrix] = ObtainControlAction_RBC(CurrentValue,IndexInVar,aux,ElementCount,q_B,x_estimated,PreviousValue)
% Here we need to know the current concentration vector x which includes
% the c^J, c^R, c^TK, c^P, c^M, and c^W.

delta_t = CurrentValue.delta_t;

JunctionCount= ElementCount.JunctionCount;
ReservoirCount = ElementCount.ReservoirCount;
TankCount = ElementCount.TankCount;
PipeCount= ElementCount.PipeCount;

JunctionCount = double(JunctionCount);
ReservoirCount = double(ReservoirCount);
TankCount = double(TankCount);
PipeCount = double(PipeCount);



nodeCount = JunctionCount + ReservoirCount + TankCount;

flowRate_B = aux.flowRate_B;
q_B = aux.q_B;
Price_B = aux.Price_B;

Np = CurrentValue.Np;
[A,B,C] = ObtainDynamic(CurrentValue,IndexInVar,aux,ElementCount,q_B);


PreviousSystemDynamicMatrix = struct('A',A,...
    'B',B,...
    'C',C);

x = x_estimated; 

Pipe_CIndex = IndexInVar.Pipe_CIndex;
Junction_CIndex = IndexInVar.Junction_CIndex;

Pipe_Concentration = x_estimated(Pipe_CIndex,:);
Junction_Concentration = x_estimated(Junction_CIndex,:);

[n_care,~] = size(Pipe_Concentration);
reference = Constants4Concentration.reference;
reference = reference*ones(n_care,1);

NumberofSegment = aux.NumberofSegment;
Error_Level_Pipe = (sum(Pipe_Concentration - reference))/NumberofSegment;

[n_care,~] = size(Junction_Concentration);
reference = Constants4Concentration.reference;
reference = reference*ones(n_care,1);
Error_Level_Junction = sum(Junction_Concentration - reference);

Error_Level = (Error_Level_Pipe + Error_Level_Junction)/(PipeCount + JunctionCount)

reference = Constants4Concentration.reference;

% call rule
Rule7

U = zeros(3,5); % 3 nodes, 5 mins
U(1,:) = U_rbc * ones(1,5); % only junction 2 have a booster

U

% This U is acutally C_B; UforEPANET is the source quality for EPAENT
% software since it requirs mg/min
UforEPANET =  U .* q_B .* Constants4Concentration.Gallon2Liter;
U_C_B = U;

UeachMinforEPANET = UforEPANET;
U_C_B_eachMin = U_C_B;

% Get the prevoius U;
PreviousU_C_B_eachMin = PreviousValue.U_C_B_eachMin;
PreviousUforEPANET = PreviousValue.UeachMinforEPANET;
% Get the Current U;
% U_C_B_eachMin = U_C_B_eachMin + PreviousU_C_B_eachMin(:,end);
% UeachMinforEPANET = UeachMinforEPANET + PreviousUforEPANET(:,end);
% make sure the UeachMinforEPANET IS NOT NEGATIVE
[m_UCB,n_UCB] = size(U_C_B_eachMin);
for i = 1:m_UCB
    for j = 1:n_UCB
        if(U_C_B_eachMin(i,j) < 0)
            disp('U_C_B_eachMin negative')
            U_C_B_eachMin(i,j) = 0;
        end
        if(UeachMinforEPANET(i,j) < 0)
            disp('UeachMinforEPANET negative')
            UeachMinforEPANET(i,j) = 0;
        end
    end
end


U_C_B_eachMin
UeachMinforEPANET

