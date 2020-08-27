clear 

load('Net3_1day_Without_Control.mat')
Calculate_Error_EPANET_LDE(epanetResult',LDEResult1')

X_node_control_result_no_control = X_node_control_result(1:1440,:);
X_link_control_result_no_control = X_link_control_result(1:1440,:);
epanetResult_no_control = epanetResult(1:1440,:); 
LDEResult1_no_control = LDEResult1(1:1440,:);
QsL_Control_no_control = QsL_Control(1:1440,:); 
QsN_Control_no_control = QsN_Control(1:1440,:);

load('Net3_1day_WithControl.mat')
X_node_control_result = X_node_control_result(1:1440,:);
X_link_control_result = X_link_control_result(1:1440,:);
epanetResult = epanetResult(1:1440,:); 
LDEResult1 = LDEResult1(1:1440,:);
QsL_Control = QsL_Control(1:1440,:); 
QsN_Control = QsN_Control(1:1440,:);



% plot junctions and pipes that are directed controlled pipes;
%plotDirectedControlled_net3
plotControlledArea_net3







IndirectedControlledPipeID = {'P245','P247','P249','P251','P257','P261','P269',...
    'P263','P271','P273','P275','P281','P283','P285','P289',...
        'P287','P291','P293','P295','P281','P283','P285'
    };

IndirectedControlledPipeID = {'P245','P247','P249','P251','P257','P261','P269',...
    'P263','P271','P273','P275','P281','P283','P285','P289',...
        'P287','P291','P293','P295','P281','P283','P285'
    };