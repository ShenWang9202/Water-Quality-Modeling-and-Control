yalmip('clear')
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
x0 = InitialConcentration(x0,C0,MassEnergyMatrix,Head0,IndexInVar,ElementCount);
nx = NumberofX; % Number of states

% initialize BOOSTER
% flow of Booster, assume we put booster at each nodes, so the size of it
% should be the number of nodes.

nodeCount = double(JunctionCount+ReservoirCount+TankCount);
switch Network
    case 1
        Location_B = {'J2'}; % NodeID here;
        flowRate_B = [200]; % unit: GPM
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


% find the node's outflow pipe index
CurrentFlow = Flow(1,:);
CurrentFlow = CurrentFlow';
PipeIndexConnectingLocation = findOutFlowIndexByNodeID(Location_B,NodeID,CurrentFlow,MassEnergyMatrix);


nu = nodeCount; % Number of inputs

% MPC data
Q = eye(2);
R = 2;

% estimate Hp of concentration; basciall 5 mins = how many steps
CurrentVelocityPipe = VelocityPipe(1,:);
delta_t = LinkLengthPipe./NumberofSegment./CurrentVelocityPipe;
delta_t = min(delta_t); % the minium step length for all pipes
Hq_min = Constants4Concentration.Hq_min; % I need that all concention 5 minutes later are  in 0.2 mg 4 mg
SetTimeParameter = Hq_min*Constants4Concentration.MinInSecond/delta_t;
SetTimeStep = floor(SetTimeParameter)+ 1;
N = SetTimeStep;
% if(NumberofSegment > SetTimeStep)
%     N = NumberofSegment; % steps
% else
%     N = SetTimeStep;
% end

% q_B for the objective funtion
if(symbolicDebug)
    u = cell(1,N);
    stringU = 'u';
    for i=1:N
        u{1,i} = sym(strcat(stringU,num2str(i),'_'),[nu 1]);
    end
else
    u = sdpvar(repmat(nu,1,N),repmat(1,1,N));
end

constraints = [];
objective = 0;
x = x0;
BaseCindeofPipe = min(Pipe_CIndex);
CurrentTime = 0;
kC = 0;
CurrentNodeTankVolume = NodeTankVolume(1,:);
disp('total number of variables?')
N*NumberofSegment
%ENsetnodevalue
for k = 1:N
    % Generate A and B dynamically
    CurrentTime
    kC = floor(CurrentTime/double(TimeQualityStep))+1;
    CurrentVelocityPipe = VelocityPipe(kC,:);
    CurrentNodeNetFlowTank = NodeNetFlowTank(kC,:);
    CurrentFlow = Flow(kC,:);
    CurrentFlow = CurrentFlow';
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
    x = A*x + B*u{k};
    objective = objective + q_B'*u{k};% norm(Q*x,1) + norm(R*u{k},1);
    
    % concentration from booster is always greater than 0;
    for i = 1:nu
        constraints = [constraints; 0<=u{k}(i)];
    end
    
    [~,nPipe] = size(PipeIndexConnectingLocation);
    if(k<=NumberofSegment && k>=2)
        % 3. find the BaseCIndex of each PipeIndexConnectingLocation
        for i = 1:nPipe
            pipeIndex = PipeIndexConnectingLocation(i);
            KSegmentIndexofPipe = findKSegmentIndexofPipe(pipeIndex,k,BaseCindeofPipe,NumberofSegment);
            for i = KSegmentIndexofPipe
            constraints = [constraints; 2<=x(i)<=4];
            %constraints = [constraints; x(i)];
            end
        end
    elseif (k>=NumberofSegment )
        for i = 1:nPipe
            pipeIndex = PipeIndexConnectingLocation(i);
            CIndexofPipe = findCIndexofPipe(pipeIndex,BaseCindeofPipe,NumberofSegment);
            for i = CIndexofPipe
                constraints = [constraints; 2<=x(i)<=4];
            end
            %constraints = [constraints,  2 <=x(CIndexofPipe)<=4];
        end
    end
    
    CurrentTime = CurrentTime + delta_t;
end

if(symbolicDebug)
    constraints = vpa(constraints,4)
else
%ops = sdpsettings('solver','cplex');
%ops = sdpsettings('solver','mosek','verbose',1,'debug',1);
ops = sdpsettings('solver','','verbose',1,'debug',1);
ops.showprogress = 1;
optimize(constraints,objective,ops);
for i = 1: N
    value(u{i})
end
value(x)

disp('total number of variables?')
N*NumberofSegment
end
