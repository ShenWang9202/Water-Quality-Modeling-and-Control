%% Multiple-Species Reaction Model for Water Quality Control in Drinking Water Networks
% Author: Salma ElSherif
% V01 _ R01
% Date: 06/02/2021
%%
clear
clc
close all
%%
start_toolkit;

% Load EPANET Network and MSX
G = epanet('Threenode-cl-4.inp'); % Load EPANET Input file
G.loadMSXFile('Threenode-cl-3-Salma-2.msx'); % Load MSX file

node_id = G.getNodeNameID;

PipeIndex = G.getLinkPipeIndex;
PumpIndex = G.getLinkPumpIndex;
JunctionIndex = G.getNodeJunctionIndex;
ReservoirIndex = G.getNodeReservoirIndex;
TankIndex = G.getNodeTankIndex;

%% Run
H = G.getComputedHydraulicTimeSeries;
Flow = H.Flow;
Head = H.Head;
Q_Node = G.getMSXComputedQualityNode; % Solve hydraulics and MSX quality dynamics
Q_Reservoir = Q_Node.Quality{ReservoirIndex};
Q_Junction = Q_Node.Quality{JunctionIndex};
Q_Tank = Q_Node.Quality{TankIndex};
Q_Link = G.getMSXComputedQualityLink; % Solve hydraulics and MSX quality dynamics
Q_Pipe = Q_Link.Quality{PipeIndex};
Q_Pump = Q_Link.Quality{PumpIndex};
TimeSeries_EPANET = Q_Link.Time;
%%
%Hyadraulics, initial conditions and parameters from EPANET
TankVolume = H.TankVolume(:, 3); %Volume of the tank time series

PipeVelocity = H.Velocity(:, PipeIndex);
JunctionCount = G.getNodeJunctionCount;
PipeCount = G.getLinkPipeCount;
PumpCount = G.getLinkPumpCount;
TankCount = G.getNodeTankCount;
ReservoirCount = G.getNodeReservoirCount;
Segment = 100; %number of pipe segments
PipeLinkLength = G.getLinkLength(PipeIndex);
nx = JunctionCount + TankCount + ReservoirCount + PipeCount*Segment + PumpCount; %total number of elements
K = G.getMSXConstantsValue;
Kb = K(1, 1)/60; %A bulk decay rate for each second
Kr=K(1,2)/60; % mutual reaction rate for each second
% kb=0;
JunctionDemand = H.Demand(:, JunctionIndex); %demand at junction
PipeFlowRate = H.Flow(:, PipeIndex); %flow in pipe time series
PumpFlowRate = H.Flow(:, PumpIndex); %flow in pump time series
cB0 = 0; %no booster station as start

IndexTimeStart = 2;
IndexChemicalA = 1;
IndexChemicalB = 2;
cA_R = Q_Reservoir(IndexTimeStart, IndexChemicalA); %source concentrations at reservoir for A
cB_R = Q_Reservoir(IndexTimeStart, IndexChemicalB); %source concentrations at reservoir for B
%%
SecinMin = 60;
GPM2CFPS = 0.0022280092592593; % CONSTANT GPM TO Cube foot per Sec
% fix the number of segements and get the Delta_X for each pipe
DeltaX = PipeLinkLength / Segment;
DeltaTQ = min(DeltaX./PipeVelocity);
DeltaTQ = MakeDelta_tAsInteger(DeltaTQ);
DeltaTQ_Report = double(G.getMSXTimeStep);
DeltaTH = double(G.getTimeHydraulicStep);
TStepsH = double((G.getTimeSimulationDuration) / DeltaTH);
TStepsQ = int64(TStepsH*SecinMin/DeltaTQ);
%constructing matrices with dimensions
A_A = zeros(nx, nx);
A_B = zeros(nx, nx);
x_A = zeros(nx, 1); %initial conditions for concentrations
x_B = zeros(nx, 1); %initial conditions for concentrations
PhiA = zeros(nx, 1); %the non linear part
PhiB = zeros(nx, 1); %the non linear part
% uWQ=zeros(nt,1);
% uWQ(3,1)=cB0;
for ind = 1:nx
    x_A(:, :) = 0; %initial condition at t=0
    x_B(:, :) = 0;
end
clear nn
%XWQ; 1 Reservoir, 2 Pump, 3 Junction, Segment+3 Pipe seg., end tank
IndexReservoir_Q = 1;
IndexPump_Q = 2;
IndexJunction_Q = 3;
IndexPipe_Q = (IndexJunction_Q + 1):(IndexJunction_Q + Segment);
IndexTank_Q = IndexPipe_Q(end)+1;
x_A(IndexReservoir_Q) = cA_R;
x_B(IndexReservoir_Q) = cB_R;
% x_A(2) = cA_R; %conc. at pump is equal to at reservoir
% X_B(2) = cB_R;
X_A_Q = zeros(nx, TStepsQ + 1); %every column represent the time step
X_B_Q = zeros(nx, TStepsQ + 1);

%XWQ; 1 Reservoir, 2 Pump, 3 Junction, Segment+3 Pipe seg., end tank

%for reservoir
A_A(IndexReservoir_Q, 1) = 1;
A_B(IndexReservoir_Q, 1) = 1;
% for pump
A_A(IndexPump_Q, 1) = 1;
A_B(IndexPump_Q, 1) = 1;

DDT = DeltaTH / DeltaTQ; %How many quality steps in a hydraulic time-step


% Hydraulic simulation (each step stands for a hyrdualic time-step that is 60s.)
for tH = 1: TStepsH % each minite, you will have a new A matrix.
    
    % todo: for each pipe, we should do this
    
    % Velocity is in foot/second, and length is in foot.
    tH
    
    currentV = PipeVelocity(tH, 1)
    
    CR = PipeVelocity(tH, PipeIndex) * DeltaTQ / DeltaX %check between 0 and 1
    a0 = (0.5 * CR ^ 2 + 0.5 * CR); %L-W constants
    a1 = (1 - CR ^ 2);
    a2 = (0.5 * CR ^ 2 - 0.5 * CR);
    
    %for pipes
    for ind = IndexPipe_Q
        % for A, there is bulk reaction
        A_A(ind, ind - 1) = a0;
        A_A(ind, ind) = a1 - Kb * DeltaTQ;
        A_A(ind, ind + 1) = a2;
        % for B, there is no bulk reaction
        A_B(ind, ind - 1) = a0;
        A_B(ind, ind) = a1;
        A_B(ind, ind + 1) = a2;
    end
    
    FlowedInVolume = PipeFlowRate(tH) * GPM2CFPS * DeltaTQ;
    NextTankVolume  = TankVolume(tH) + FlowedInVolume;
    A_A(3, 2) = PumpFlowRate(tH) / (JunctionDemand(tH) + PipeFlowRate(tH)); %for junction
    A_B(3, 2) = A_A(3, 2);
    A_B(end, end - 1) = FlowedInVolume  / NextTankVolume; %for tank
    A_A(end, end - 1) = A_B(end, end - 1);
    A_B(end, end) = TankVolume(tH) / NextTankVolume; %for tank
    A_A(end, end) = A_B(end, end) - Kb * DeltaTQ;
    
    for tt = ((tH - 1) * DDT + 1): (tH * DDT)
        tt
        if 1 == tt
            X_A_Q(:, 1) = x_A;
            X_B_Q(:, 1) = x_B;
        else
            % mutual reaction in pipes and tanks
            MutualReactionIdex = [IndexPipe_Q IndexTank_Q];
            PhiA(MutualReactionIdex) = -Kr* DeltaTQ *X_A_Q(MutualReactionIdex, (tt - 1)).*X_B_Q(MutualReactionIdex, (tt - 1));
            PhiB = PhiA;     
            X_A_Q(:, tt) = A_A * X_A_Q(:, (tt - 1)) + PhiA;
            X_B_Q(:, tt) = A_B * X_B_Q(:, (tt - 1)) + PhiB;
        end
    end
end

PlotResult_Shen



 
