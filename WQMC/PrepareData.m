%% Constant from EPANET SOFTWARE

VISCOS = 1.1E-5;
DIFFUS  = 1.3E-5;

% /* Store value of viscosity & diffusivity */
ucf = 1.0;
% If the unit is SI, then ucf = sqr(MperFT), when the flow unit is CFS
% if (par->Unitsflag == SI)
% ucf = SQR(MperFT);


%% Constant from INP source file
% Relative Viscosity MEANS Ratio of the kinematic viscosity of the fluid to that of water at 20 deg. C (1.0 centistokes or 0.94 sq ft/day) (unitless).
RelativeViscosity = 1.0;
RelativeDiffusivity = 1.0;

%% Run Water Quality analysis of a network

% Load a network
%d = epanet('Threenode-cl-2.inp');
%d = epanet('tutorial8node.inp');% 5-min level;
%d = epanet('tutorial8node1.inp'); % 1-minite level;
%d = epanet('tutorial8node1inital.inp'); % 1-minite level with some initial concentration;
%d = epanet('Net1-1min.inp'); % 1-minite level;
d = epanet(NetworkName); % 1-minite level;
% Compute Quality without MSX
% (This function contains events) Don't uncomment this commands!!! Crash
% easily
qual_res = d.getComputedQualityTimeSeries; %Value x Node, Value x Link
LinkQuality = qual_res.LinkQuality;

%% get info from EPANET
% get index info from EPANET
%PipeIndex = 1:d.getLinkPipeCount;
PipeIndex = d.getLinkPipeIndex;
PumpIndex = d.getLinkPumpIndex;
ValveIndex = d.getLinkValveIndex;
NodeJunctionIndex = d.getNodeJunctionIndex;
ReservoirIndex = d.getNodeReservoirIndex;
NodeTankIndex = d.getNodeTankIndex;

% get LinkDiameter from EPANET
LinkDiameter = d.getLinkDiameter;
LinkDiameterPipe = LinkDiameter(PipeIndex);
LinkLength = d.getLinkLength;
LinkLengthPipe = LinkLength(PipeIndex);

LinkQualityPipe = LinkQuality(:,PipeIndex);
%% Calculte reaction rate
Kb_all = d.getLinkBulkReactionCoeff;
% Bulk reaction
Kb = Kb_all(PipeIndex)
Kw_all = d.getLinkWallReactionCoeff;


TimeQualityStep = d.getTimeQualityStep;

% wall reaction rate constant (length/time)
Kw = Kw_all(PipeIndex)

%% Compute Quality step by step
% d.solveCompleteHydraulics #needed
d.openQualityAnalysis
d.initializeQualityAnalysis
tleft=1; P=[];T=[];QsN=[]; QsL=[]; Velocity=[]; Head=[];
Flow=[]; JunctionActualDemand=[]; NodeTankVolume = [];NodeNetFlowTank = [];
while (tleft>0)
    %Add code which changes something related to quality
    t=d.runQualityAnalysis;
    P=[P; d.getNodePressure];
    Head=[Head; d.getNodeHydaulicHead];
    Flow=[Flow; d.getLinkFlows];
    Velocity = [Velocity; d.getLinkVelocity];
    TempDemand = d.getNodeActualDemand;
    JunctionActualDemand = [JunctionActualDemand; TempDemand(NodeJunctionIndex)];
    NodeNetFlowTank = [NodeNetFlowTank; TempDemand(NodeTankIndex)];
    Volume = d.getNodeTankVolume;
    NodeTankVolume = [NodeTankVolume; Volume(NodeTankIndex)];
    QsN=[QsN; d.getNodeActualQuality];
    QsL=[QsL; d.getLinkQuality];
    T=[T; t];
    tleft = d.stepQualityAnalysisTimeLeft;
end


%%
NodeMassFlowRate = d.getNodeMassFlowRate;
VelocityPipe = Velocity(:,PipeIndex);

BulkReactionCoeff = d.getNodeTankBulkReactionCoeff;
TankBulkReactionCoeff = BulkReactionCoeff(:,NodeTankIndex);
TankBulkReactionCoeff = TankBulkReactionCoeff/Constants4Concentration.DayInSecond;

d.getBinComputedAverageBulkReactionRate
d.getBinComputedAverageWallReactionRate
ReactionRate = d.getBinComputedLinkReactionRate
ReactionRatePipe = ReactionRate(:,PipeIndex);
LinkQualityPipe
%MSXRateUnits = d.getMSXRateUnits
% in EPANET
% Specific Gravity MEANS Ratio of the density of the fluid being modeled to that of water at 4 deg. C (unitless).



Viscosity = VISCOS * RelativeViscosity;
Diffusivity = DIFFUS * RelativeDiffusivity;

% Reynolds_number;  Velocity is in feet/second, LinkDiameterPipe is in feet, Viscosity is feet square/second
RE = VelocityPipe.*LinkDiameterPipe./Viscosity; %https://en.wikipedia.org/wiki/Reynolds_number
% mass transfer coefficient (length/time)
%Sc = Schmidt number (kinematic viscosity of water divided by the diffusivity of the chemical)
Sc = Viscosity/Diffusivity;
[~,n] = size(RE);
Kf = [];
for i = 1:n
    if(RE(i) < 1.0 )
        Sh = 2.0;
    elseif (RE(i) >= 2300.0)
        Sh = 0.0149 * RE(i)^0.88 * Sc^(0.333);
    else
        temp = LinkDiameterPipe(i)/LinkLengthPipe(i)*RE(i)*Sc;
        Sh = 3.65 + 0.0668*temp/(1 + 0.04*(temp)^(0.667));
    end
    Kf = [Kf; Sh * Diffusivity / LinkDiameterPipe(i)];
end
Kf1 = 1.5826e-4 * RE.^0.88 ./ LinkDiameterPipe;

% df = 1.5826e-4 ./0.0149 / Sc^(0.333)
% % wall reaction
Kwall = 4.* Kw .* Kf ./ LinkDiameterPipe ./ (abs(Kw) + Kf)
Kwall1 = 4.* Kw .* Kf1 ./ LinkDiameterPipe ./ (abs(Kw) + Kf1)

K = Kb + Kwall
K1 = Kb + Kwall1

d.closeQualityAnalysis;

PipeReactionCoeff = K;
PipeReactionCoeff = PipeReactionCoeff/Constants4Concentration.DayInSecond;
%% Initialize x(0)

% number of all elements

% step 1: count each element
JunctionCount = double(d.getNodeJunctionCount);
ReservoirCount = double(d.getNodeReservoirCount);
TankCount = double(d.getNodeTankCount);

PipeCount = double(d.getLinkPipeCount);
PumpCount = double(d.getLinkPumpCount);
ValveCount = double(d.getLinkValveCount);

ElementCount = struct('JunctionCount',JunctionCount,...
    'ReservoirCount',ReservoirCount,...
    'TankCount',TankCount,...
    'PipeCount',PipeCount,...
    'PumpCount',PumpCount,...
    'ValveCount',ValveCount);

% define the number of segment
NumberofSegment = Constants4Concentration.NumberofSegment;
% so the total size of x
NumberofX = double(JunctionCount + ReservoirCount + TankCount + ...
    PipeCount * NumberofSegment + PumpCount + ValveCount);
NumberofX2 = double(JunctionCount + ReservoirCount + TankCount + ...
    PipeCount + PumpCount + ValveCount);


% step 2-1: index of each element in x;
Junction_CIndex = 1:JunctionCount;

BaseCount4Next = JunctionCount;
Reservoir_CIndex = (BaseCount4Next+1):(BaseCount4Next + ReservoirCount);

BaseCount4Next = BaseCount4Next + ReservoirCount;
Tank_CIndex = (BaseCount4Next+1):(BaseCount4Next + TankCount);
% Pipe Concentration index in x
BaseCount4Next = BaseCount4Next + TankCount;
Pipe_CIndex = (BaseCount4Next+1):(BaseCount4Next + PipeCount * NumberofSegment);

% Pump Concentration index in x
BaseCount4Next = BaseCount4Next + PipeCount * NumberofSegment;
Pump_CIndex = (BaseCount4Next+1):(BaseCount4Next + PumpCount);

BaseCount4Next = BaseCount4Next + PumpCount;
Valve_CIndex = (BaseCount4Next+1):(BaseCount4Next + ValveCount);


% step 2-2: index of each element in x;
JunctionIndexInOrder = 1:JunctionCount;

BaseCount4Next = JunctionCount;
ReservoirIndexInOrder = (BaseCount4Next+1):(BaseCount4Next + ReservoirCount);

BaseCount4Next = BaseCount4Next + ReservoirCount;
TankIndexInOrder = (BaseCount4Next+1):(BaseCount4Next + TankCount);
% Pipe index
BaseCount4Next = BaseCount4Next + TankCount;
PipeIndexInOrder = (BaseCount4Next+1):(BaseCount4Next + PipeCount);
% Pipe index
BaseCount4Next = BaseCount4Next + PipeCount;
PumpIndexInOrder = (BaseCount4Next+1):(BaseCount4Next + PumpCount);

BaseCount4Next = BaseCount4Next + PumpCount;
ValveIndexInOrder = (BaseCount4Next+1):(BaseCount4Next + ValveCount);

NumberofElement = BaseCount4Next + ValveCount;
IndexInVar = struct('NumberofX',NumberofX,...
    'NumberofElement',NumberofElement,...
    'Junction_CIndex',Junction_CIndex,...
    'Reservoir_CIndex',Reservoir_CIndex,...
    'Tank_CIndex',Tank_CIndex,...
    'Pipe_CIndex',Pipe_CIndex,...
    'Pump_CIndex',Pump_CIndex,...
    'Valve_CIndex',Valve_CIndex,...
    'JunctionIndexInOrder',JunctionIndexInOrder,...
    'ReservoirIndexInOrder',ReservoirIndexInOrder,...
    'TankIndexInOrder',TankIndexInOrder,...
    'PipeIndexInOrder',PipeIndexInOrder,...
    'PumpIndexInOrder',PumpIndexInOrder,...
    'ValveIndexInOrder',ValveIndexInOrder,...
    'PipeIndex',PipeIndex,...
    'PumpIndex',PumpIndex,...
    'ValveIndex',ValveIndex);

aux = struct('NodeNetFlowTank',NodeNetFlowTank,...
    'JunctionActualDemand',JunctionActualDemand,...
    'NodeTankVolume',NodeTankVolume,...
    'NumberofSegment',NumberofSegment,...
    'LinkLengthPipe',LinkLengthPipe,...
    'LinkDiameterPipe',LinkDiameterPipe,...
    'TankBulkReactionCoeff',TankBulkReactionCoeff,...
    'PipeReactionCoeff',PipeReactionCoeff);


%% Variable_Symbol_Table
NodeNameID = d.getNodeNameID; % the Name of each node   head of each node
LinkNameID = d.getLinkNameID; % the Name of each pipe   flow of each pipe

Variable_Symbol_Table = cell(NumberofX,2);
NodeIndexInVar = d.getNodeIndex;
LinkIndexInVar = d.getLinkIndex  + d.getNodeCount;

NodeJunctionNameID = d.getNodeJunctionNameID;
NodeReservoirNameID = d.getNodeReservoirNameID;
NodeTankNameID = d.getNodeTankNameID;
LinkPipeNameID = d.getLinkPipeNameID;
LinkPumpNameID = d.getLinkPumpNameID;
LinkValveNameID = d.getLinkValveNameID;

% Junction
temp_i = 1;
for i = Junction_CIndex
    Variable_Symbol_Table{i,1} = strcat('J',NodeJunctionNameID{temp_i});
    temp_i = temp_i + 1;
end

% Reservoir
temp_i = 1;
for i = Reservoir_CIndex
    Variable_Symbol_Table{i,1} = strcat('R',NodeReservoirNameID{temp_i});
    temp_i = temp_i + 1;
end

% Tank
temp_i = 1;
for i = Tank_CIndex
    Variable_Symbol_Table{i,1} = strcat('T',NodeTankNameID{temp_i});
    temp_i = temp_i + 1;
end

% Pipe
basePipeCindex = min(Pipe_CIndex);
temp_i = 1;
for i = Pipe_CIndex
    j1 = floor((double(i - basePipeCindex))/NumberofSegment )+ 1;
    Variable_Symbol_Table{i,1} =  strcat('P',LinkPipeNameID{j1},'_',int2str(temp_i));
    temp_i = temp_i + 1;
    if(temp_i == NumberofSegment+1)
        temp_i = 1;
    end
end

% Pump
temp_i = 1;
for i = Pump_CIndex
    Variable_Symbol_Table{i,1} = strcat('Pu',LinkPumpNameID{temp_i});
    temp_i = temp_i + 1;
end

% Valve
temp_i = 1;
for i = Valve_CIndex
    Variable_Symbol_Table{i,1} = strcat('V',LinkValveNameID{temp_i});
    temp_i = temp_i + 1;
end

for i = 1:NumberofX
    Variable_Symbol_Table{i,2} =  strcat('W_',int2str(i));
end

% Variable_Symbol_Table 2 

Variable_Symbol_Table2 = cell(NumberofX2,2);

% Junction
temp_i = 1;
for i = JunctionIndexInOrder
    Variable_Symbol_Table2{i,1} = strcat('J',NodeJunctionNameID{temp_i});
    temp_i = temp_i + 1;
end

% Reservoir
temp_i = 1;
for i = ReservoirIndexInOrder
    Variable_Symbol_Table2{i,1} = strcat('R',NodeReservoirNameID{temp_i});
    temp_i = temp_i + 1;
end

% Tank
temp_i = 1;
for i = TankIndexInOrder
    Variable_Symbol_Table2{i,1} = strcat('T',NodeTankNameID{temp_i});
    temp_i = temp_i + 1;
end

% Pipe
temp_i = 1;
for i = PipeIndexInOrder
    Variable_Symbol_Table2{i,1} =  strcat('P',LinkPipeNameID{temp_i});
    temp_i = temp_i + 1;
end

% Pump
temp_i = 1;
for i = PumpIndexInOrder
    Variable_Symbol_Table2{i,1} = strcat('Pu',LinkPumpNameID(temp_i));
    temp_i = temp_i + 1;
end

% Valve
temp_i = 1;
for i = ValveIndexInOrder
    Variable_Symbol_Table2{i,1} = strcat('V',LinkValveNameID(temp_i));
    temp_i = temp_i + 1;
end

for i = 1:NumberofX2
    Variable_Symbol_Table2{i,2} =  strcat('W_',int2str(i));
end


%% Generate Mass and Energy Matrice
NodesConnectingLinksID = d.getNodesConnectingLinksID; %
[m,n] = size(NodesConnectingLinksID);
NodesConnectingLinksIndex = zeros(m,n);

for i = 1:m
    for j = 1:n
        NodesConnectingLinksIndex(i,j) = find(strcmp(NodeNameID,NodesConnectingLinksID{i,j}));
    end
end
%NodesConnectingLinksIndex
% Generate MassEnergyMatrix
[~,n1] = size(NodeNameID);
[~,n2] = size(LinkNameID);
MassEnergyMatrix = zeros(n2,n1);

for i = 1:m
    MassEnergyMatrix(i,NodesConnectingLinksIndex(i,1)) = -1;
    MassEnergyMatrix(i,NodesConnectingLinksIndex(i,2))= 1;
end
% Display
%MassEnergyMatrix

% Generate Mass Matrix
JunctionMassMatrix = MassEnergyMatrix(:,NodeJunctionIndex)';
[RowNeg,ColNeg] = find(JunctionMassMatrix == -1);
[m,~] = size(RowNeg);
for i = 1:m
    JunctionMassMatrix(RowNeg(i),ColNeg(i)) = 0;
end

TankMassMatrix = MassEnergyMatrix(:,NodeTankIndex)';

switch Network
    case 1
        SavedData = 'PreparedData3node.mat';
        save(SavedData)
    case {2,3}
        SavedData = 'PreparedData8node.mat';
        save(SavedData)
    case 4
        SavedData = 'PreparedData8nodeInitial.mat';
        save(SavedData)
    case 5
        SavedData = 'PreparedDataNet1.mat';
        save(SavedData)
    case 6
        SavedData = 'PreparedDataNet1Initial.mat';
        save(SavedData)
    otherwise
        disp('other value')
end
