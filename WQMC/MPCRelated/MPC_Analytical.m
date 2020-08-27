clear all
%% Load EPANET MATLAB TOOLKIT
start_toolkit;
%% run EPANET MATLAB TOOLKIT to obtain data
symbolicDebug = 0;
Network = 1; % Don't use case 2
switch Network
    case 1
        % Quality Timestep = 1 min, and  Global Bulk = -0.3, Global Wall= -0.0
        NetworkName = 'Threenode-cl-2.inp';
    case 2
        % Don't not use one: Quality Timestep = 5 min, and  Global Bulk = -0.3, Global Wall=
        % -1.0
        NetworkName = 'tutorial8node.inp';
    case 3
        % Quality Timestep = 1 min, and  Global Bulk = -0.3, Global Wall= -0.0
        NetworkName = 'tutorial8node1.inp';
    case 4
        % Quality Timestep = 1 min, and  Global Bulk = -0.3, Global Wall=
        % -0.0; initial value: J2 = 0.5 mg/L, J6 = 1.2 mg/L, R1 = 0.8 mg/L;
        % segment = 1000;
        NetworkName = 'tutorial8node1inital.inp';
    case 5
        % Quality Timestep = 1 min, and  Global Bulk = -0.5, Global Wall=
        % -0.0; 
        NetworkName = 'Net1-1min.inp';
    case 6
        % The initial value is slightly different
        NetworkName = 'Net1-1mininitial.inp';
    otherwise
        disp('other value')
end

switch Network
    case 1
        SavedData = 'PreparedData3node.mat';
    case {2,3}
        SavedData = 'PreparedData8node.mat';
    case 4
        SavedData = 'PreparedData8nodeInitial.mat';
    case 5
        SavedData = 'PreparedDataNet1.mat';
    case 6
        SavedData = 'PreparedDataNet1Initial.mat';
    otherwise
        disp('other value')
end

if exist(SavedData, 'file') == 2
    disp('file exists, loading...')
    load(SavedData)
else
    if ispc %Code to run on Windows platform
        disp('file does not exist, simulating...')
        PrepareData
    end
end

% if ismac
%     % Code to run on Mac platform
% elseif isunix
%     % Code to run on Linux platform
% elseif ispc
%     % Code to run on Windows platform
% else
%     disp('Platform not supported')
% end
%% Initialization

% initialize concentration at nodes
x0 = zeros(NumberofX,1);
C0 = [QsN(1,:) QsL(1,:)];
Head0 = Head(1,:);
% something wrong with this intial function with 8-node network
x0 = InitialConcentration(x0,C0,MassEnergyMatrix,Head0,IndexInVar,ElementCount);
nx = NumberofX; % Number of states

% initialize BOOSTER
% flow of Booster, assume we put booster at each nodes, so the size of it
% should be the number of nodes.
JunctionCount = double(JunctionCount);
ReservoirCount = double(ReservoirCount);
TankCount = double(TankCount);
nodeCount = JunctionCount + ReservoirCount + TankCount;
switch Network
    case 1
        Location_B = {'J2'}; % NodeID here;
        flowRate_B = [100]; % unit: GPM
        % the C_B is what we need find in MPC, useless here
        C_B = [1]; % unit: mg/L % Concentration of booster
    case {2,3,4}
        Location_B = {}; %Location_B = {'J2'}; % NodeID here;
        flowRate_B = [0]; % unit: GPM
        % the C_B is what we need find in MPC, useless here
        C_B = [1]; % unit: mg/L % Concentration of booster
    case {5,6}
        Location_B = {'22'}; % NodeID here;
        flowRate_B = [200]; % unit: GPM
        % the C_B is what we need find in MPC, useless here
        C_B = [1]; % unit: mg/L % Concentration of booster
    otherwise
        disp('other value')
end
NodeID = Variable_Symbol_Table(1:nodeCount,1);
[q_B,C_B] = InitialBoosterFlow(nodeCount,Location_B,flowRate_B,NodeID,C_B);
[nu,~] = size(C_B);


% find the node's outflow pipe index
CurrentFlow = Flow(1,:);
CurrentFlow = CurrentFlow';
PipeIndexConnectingLocation = findOutFlowIndexByNodeID(Location_B,NodeID,CurrentFlow,MassEnergyMatrix);


nu = nodeCount; % Number of inputs

% the minium step length for all pipes
CurrentVelocityPipe = VelocityPipe(1,:);
delta_t = LinkLengthPipe./NumberofSegment./CurrentVelocityPipe;
delta_t = min(delta_t);

% estimate Hp of concentration; basciall 5 mins = how many steps
Hq_min = Constants4Concentration.Hq_min; % I need that all concention 5 minutes later are  in 0.2 mg 4 mg
SetTimeParameter = Hq_min*Constants4Concentration.MinInSecond/delta_t;
SetTimeStep = floor(SetTimeParameter)+ 1;
N = SetTimeStep;

objective = 0;
x = x0;
BaseCindeofPipe = min(Pipe_CIndex);
CurrentTime = 0;
kC = 0;
CurrentNodeTankVolume = NodeTankVolume(1,:);
disp('total number of variables?')
N*NumberofSegment
%ENsetnodevalue

delta_t = LinkLengthPipe./NumberofSegment./CurrentVelocityPipe;
delta_t = min(delta_t); % the minium step length for all pipes
% for junctions
[A_J, B_J] = ConstructMatrixForJunction(CurrentFlow,JunctionMassMatrix,ElementCount,IndexInVar,q_B);
% for reservoirs
A_R = ConstructMatrixForReservoir(ElementCount,IndexInVar);
% for tanks
[A_TK,B_TK,CurrentNodeTankVolume] = ConstructMatrixForTank(delta_t,CurrentFlow,CurrentNodeTankVolume,TankMassMatrix,ElementCount,IndexInVar,aux,q_B);
% for Pipes
EnergyMatrixPipe= MassEnergyMatrix(PipeIndex,:);
A_P = ConstructMatrixForPipe(delta_t,CurrentFlow,EnergyMatrixPipe,ElementCount,IndexInVar,aux);
% for Pumps
EnergyMatrixPump= MassEnergyMatrix(PumpIndex,:);
A_M = ConstructMatrixForPump(EnergyMatrixPump,ElementCount,IndexInVar);
% for Valves
EnergyMatrixValve= MassEnergyMatrix(ValveIndex,:);
A_W = ConstructMatrixForValve(EnergyMatrixValve,ElementCount,IndexInVar);
% construct A;
A = [A_J;A_R;A_TK;A_P;A_M;A_W];
% construct B;
B_R = sparse(ReservoirCount,nodeCount);
B_P = sparse(NumberofSegment*PipeCount,nodeCount);
B_M = sparse(PumpCount,nodeCount);
B_W = sparse(ValveCount,nodeCount);
B = [B_J;B_R;B_TK;B_P;B_M;B_W];
% System dynamic
% Make sure A and B and C do not change during this horizen; Do
% Receding Horizen instead of MPC
% x = A*x + B*u{k};
%objective = objective + q_B'*u{k};% norm(Q*x,1) + norm(R*u{k},1);
C = generateC(nx);
% MPC data
Np = N;
[W,Z,Ca,PhiA,GammaA] = MPCScale(A,B,C,Np);
size(W)
size(Z)
size(Ca)
size(PhiA)
size(GammaA)
% full(W)
% full(Z)
% full(Ca)
% full(PhiA)
% full(GammaA)

% Xa = [Delta x;y]
yk = C*x;
[ny,~] = size(yk);
Deltax = zeros(nx,1);
Xa = [Deltax;yk];
% only select the booster location;
n_deltau = Np*nu;
R = speye(n_deltau,n_deltau);
% for i = 1:Np
%     R_i = eye(nu,nu);
% %     R_i = zeros(nu,nu);
% %     for j = 1:JunctionCount
% %         R_i(j,j) = 1; 
% %     end
%     R = blkdiag(R, R_i);
% end
% reference
n_ref = ny*Np;
reference = 2;%any value between 0.4~4mg/L;
reference = reference*ones(n_ref,1);
% only select the pipes now.
n_Q = Np*ny;
Q = speye(n_Q,n_Q);
% for i = 1:Np
%     Q_i = eye(ny,ny);
% %    Q_i = zeros(ny,ny);
% %     for j = (nodeCount + 1):(nodeCount + NumberofSegment*PipeCount)
% %         Q_i(j,j) = 1; 
% %     end
%     Q = blkdiag(Q, Q_i);
% end
% This is just C_B;
DeltaU = (R + Z'*Q*Z)^(-1)*Z'*Q*(reference-W*Xa);
% We reshape it based on the number of nodes.
[m_Delta,~] = size(DeltaU);
column = m_Delta/nu;
DeltaU = reshape(DeltaU,nu,column);
% Just pick the Junction2 out
DeltaU_Junction2 = DeltaU(1,:);
% Times the flowRate_B to get the mass which is in mg/min
DeltaU_Junction2 =  DeltaU_Junction2 * flowRate_B * Constants4Concentration.Gallon2Liter;
% Accumulate Delta U and make it as U;
[~,n_Delta] = size(DeltaU_Junction2);
U = zeros(1,n_Delta);
U(1) = DeltaU_Junction2(1);
for i = 1:n_Delta-1
    U(i+1) = U(i) + DeltaU_Junction2(i+1);
end
% Get the prevoius U;
PreviousU = 0;
% Get the Current U;
U = U + PreviousU;
% now this is the U for next Hq_min = 5 mins here
% But our Quality Time Step is set to 1 min, so we need to pick out the
% valvue at each minute.
IndexofUeachMin = [];
for i = 1:Hq_min
    IndexofUeachMin = [IndexofUeachMin floor(i * Constants4Concentration.MinInSecond/delta_t)+1];
end

UeachMin = U(IndexofUeachMin)

    








