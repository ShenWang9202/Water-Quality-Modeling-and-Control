clear
% Plot MPC
load('Three-node_1day.mat')
% plotDemandPipeFlowRateSeperately_3nodes
% plotControlActionU_3node(ControlActionU,BoosterLocationIndex,Location_B)


% LinkID4Legend= {'P23','M12'};
% % This is from LED model
% plotLinkConcentrations_3node(LinkID4Legend,X_link_control_result)
% plotNodeConcentrations_3node(NodeID4Legend,X_node_control_result)
% % This is from EPANET model
% plotLinkConcentrations_3node(LinkID4Legend,QsL_Control)
% plotNodeConcentrations_3node(NodeID4Legend,QsN_Control)

%% Plot LinkNodeConcentration_3node Together
% NodeID4Legend = {'J2','T3'};
% LinkID4Legend= {'P23'};


% This is from LED model
ID4Legend = {'J2','TK3','P23'};
X_control_result = [];
X_control_result = [X_control_result X_node_control_result(:,1)]; % J2
X_control_result = [X_control_result X_node_control_result(:,3)]; % T3
X_control_result = [X_control_result X_link_control_result(:,1)]; % P23
fileName = 'EnlargedLinkNodeConcentrations_3node_WQM_LDE';
TitleName = 'LDE';
plotLinkNodeConcentrations_3node_WQM(ID4Legend,X_control_result,fileName,TitleName)
% This is from EPANET model
X_control_result = [];
X_control_result = [X_control_result QsN_Control(:,1)]; % J2
X_control_result = [X_control_result QsN_Control(:,3)]; % T3
X_control_result = [X_control_result QsL_Control(:,1)]; % P23
fileName = 'EnlargedLinkNodeConcentrations_3node_WQM_EPANET';
TitleName = 'EPANET';
plotLinkNodeConcentrations_3node_WQM(ID4Legend,X_control_result,fileName,TitleName)
