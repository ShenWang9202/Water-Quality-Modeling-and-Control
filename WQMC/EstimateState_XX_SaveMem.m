function XX = EstimateState_XX_SaveMem(CurrentValue,IndexInVar,aux,ElementCount,q_B,tInMin,C0,PreviousValue)
NumberofX = IndexInVar.NumberofX;
MassEnergyMatrix = aux.MassEnergyMatrix;
XX = [];
if(tInMin==0)
    x0 = zeros(NumberofX,1);
    CurrentHead = CurrentValue.CurrentHead;
    %Head0 = Head(1,:);
    % Something wrong with this intial function with 8-node network
    x0 = InitialConcentration(x0,C0,MassEnergyMatrix,CurrentHead,IndexInVar,ElementCount);
    x_estimated = x0;
    XX = x_estimated;
else
    Previous_delta_t = PreviousValue.PreviousDelta_t;
    PreviousSystemDynamicMatrix = PreviousValue.PreviousSystemDynamicMatrix;
    x_estimated = PreviousValue.X_estimated;
    U_C_B_eachStep = PreviousValue.U_C_B_eachStep;
    [nodeCount,~] = size(U_C_B_eachStep);
    % We need to know the states 5 mins ago, apply the system dynamic for
    % the past 5 mins to obtain the estimation of current value.
    A = PreviousSystemDynamicMatrix.A;
    B = PreviousSystemDynamicMatrix.B;
    %    C = PreviousSystemDynamicMatrix.C;
    
    Hq_min = Constants4Concentration.Hq_min;
    
    % how many steps in 1 min
    SetTimeParameter = Hq_min * Constants4Concentration.MinInSecond/Previous_delta_t;
    Np = round(SetTimeParameter);
    
    U = U_C_B_eachStep;
    XX = zeros(NumberofX,Hq_min);
    
    %     A_1min = A^StepIn1Min;
    %     A_1min = speye(NumberofX);
    
    %     for i = 1:StepIn1Min
    %         A_1min =  A_1min * A;
    %     end
    
    %     B_1min = sparse()
    %     for i = 1:StepIn1Min
    %         B_1min =
    %     end
    IndexofApplyingU = [];
    for i = 1:Hq_min
        IndexofApplyingU = [IndexofApplyingU round(i * Constants4Concentration.MinInSecond/Previous_delta_t)];
    end
    indexEachMin  = 1;
    for i = 1:Np
        if(aux.COMPARE == 1)
            x_estimated = A * x_estimated;
        else
            x_estimated = A * x_estimated + B * U(:,i);
            % disp('to do');
        end
        if( i == IndexofApplyingU(indexEachMin))
            XX(:,indexEachMin) = x_estimated;
            indexEachMin = indexEachMin + 1;
        end
        
    end
end
end