function HydraulicInfoWithoutUncertainty = ObtainNetworkHydraulicInfoWithoutUncertainty(d)

SimutionTimeInMinute = Constants4Concentration.SimutionTimeInMinute;
d.setTimeSimulationDuration(SimutionTimeInMinute*60);

% Hydraulic and Quality analysis STEP-BY-STEP
d.openHydraulicAnalysis;
d.initializeHydraulicAnalysis(0);
% d.getTimeHydraulicStep


tstep = 1;
T = []; Head = []; Flow = [];  Demand_all =[]; Velocity = []; 
while (tstep>0)
    t = d.runHydraulicAnalysis;
    T = [T; t];
    
    CurrentVelocity = d.getLinkVelocity;
    PipeIndex = d.getLinkPipeIndex;
    Velocity = [Velocity; CurrentVelocity];
    Flow = [Flow; d.getLinkFlows];
    Head = [Head; d.getNodeHydaulicHead];
    Demand_known = d.getNodeActualDemand;
    Demand_all = [Demand_all; Demand_known];
    tstep = d.nextHydraulicAnalysisStep;
end
d.closeHydraulicAnalysis;
 
% % Unload library
% d.unload;

HydraulicInfoWithoutUncertainty = struct('Velocity',Velocity,...
    'Flow',Flow,...
    'Head',Head,...
    'Demand_all',Demand_all);

end

