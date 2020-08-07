faceColor = 'b';
transparency = 0.2;
fontSize = 30;

ControlledJunctionID = {'J211','J213','J215','J219','J225','229','J231','J239',...
    'J239','J249','J243','J255','J251',...
    'J50','J253',...
    'J217','J237','J247'};%NodeID';
InterestedID = unique(ControlledJunctionID);
IDcell = NodeID;
[~,n] = size(InterestedID);
ControlledJunctionIndices = [];
for i = 1:n
    % find index according to ID.
    ControlledJunctionIndices = [ControlledJunctionIndices findIndexByID(InterestedID{i},IDcell)];
end

InterestedIndirectedControlledJunctionID = {'J211','J239'};%NodeID';;%NodeID';
InterestedIndirectedControlledJunctionID = unique(InterestedIndirectedControlledJunctionID);
IDcell = NodeID;
[~,n] = size(InterestedIndirectedControlledJunctionID);
InterestedIndirectedControlledJunctionIndices = [];
for i = 1:n
    % find index according to ID.
    InterestedIndirectedControlledJunctionIndices = [InterestedIndirectedControlledJunctionIndices findIndexByID(InterestedIndirectedControlledJunctionID{i},IDcell)];
end



ControlledPipeID = {'P245','P247','P249','P251','P257','P261',...
    'P263','P275','P281','P289',...
    'P291','P293','P295','P283','P277',...
    'P269','P271','P273',...
    'P281','P285','P287',...
    'P257','P251'
    };
InterestedID = unique(ControlledPipeID);
IDcell = LinkID;
[~,n] = size(InterestedID);
ControlledPipeIndices = [];
for i = 1:n
    ControlledPipeIndices = [ControlledPipeIndices findIndexByID(InterestedID{i},IDcell)];
end

InteresetedIndirectedControlledPipeID = {'P263','P283'};
InterestedID = unique(InteresetedIndirectedControlledPipeID);
IDcell = LinkID;
[~,n] = size(InterestedID);
InteresetedDirectedControlledPipeIndices = [];
for i = 1:n
    InteresetedDirectedControlledPipeIndices = [InteresetedDirectedControlledPipeIndices findIndexByID(InterestedID{i},IDcell)];
end


fig = figure;
%% Junction plots
h1 = subplot(2,1,1);

%% plot indirectly controlled.
y = X_node_control_result(:,ControlledJunctionIndices);
meanData = mean(y,2);
[m,~] = size(y);

% Find the min and max of y data
y_max = max(y,[],2);
y_min = min(y,[],2); % 
y = [y_min y_max]';
x = 1:m;

% Find the axis limit
y_axis_max = max(y_max) + 0.05;
y_axis_min = max(0,min(y_min)-0.05);

% plot the range
px=[x,fliplr(x)];
py=[y(1,:), fliplr(y(2,:))];
patch(px,py,1,'FaceColor',faceColor,'EdgeColor','none','DisplayName','Range Zone');
alpha(transparency);
% plot mean or average value
hold on
plot(x,meanData',faceColor,'DisplayName','Average Value','LineWidth',BlueLineWidth);
% plot intested junctions
plot(X_node_control_result(:,InterestedIndirectedControlledJunctionIndices(1)),'g','LineWidth',2);
plot(X_node_control_result(:,InterestedIndirectedControlledJunctionIndices(2)), 'Color',[0.2941 0 0.5098],'LineWidth',2);
hold on


%% no control
y = X_node_control_result_no_control(:,ControlledJunctionIndices);
meanData = mean(y,2);
[m,~] = size(y);

% Find the min and max of y data
y_max = max(y,[],2);
y_min = min(y,[],2); % 
y = [y_min y_max]';
x = 1:m;

% Find the axis limit
y_axis_max = max(y_max) + 0.05;
y_axis_min = max(0,min(y_min)-0.05);

% plot the range
faceColor = 'r';
px=[x,fliplr(x)];
py=[y(1,:), fliplr(y(2,:))];
patch(px,py,1,'FaceColor',faceColor,'EdgeColor','white','DisplayName','Range Zone (uncontrolled)');
alpha(transparency);
% plot mean or average value
hold on
plot(x,meanData',faceColor,'DisplayName','Average Value','LineWidth',2);
hold on
% % plot intested junctions
% plot(X_node_control_result_no_control(:,InterestedIndirectedControlledJunctionIndices),'LineWidth',2);
% hold on


xticks([0 360 720 1080 1440]);
xticklabels({'0','360','720','1080','1440'})
xlim([0,1440]);

yticks([0.2 0.6 1]);
yticklabels({'0.2','0.6','1'})
ylim([0.18,1.2]);



temp = NodeID(InterestedIndirectedControlledJunctionIndices);
legendJunctionID = ['Range Zone';'Average Value';temp;'Range Zone';'Average Value'];
lgd = legend(legendJunctionID,'Location','northwest','Orientation','horizontal');
lgd.NumColumns = 4;
lgd.FontSize = fontSize-4;
set(lgd,'box','off');
set(lgd,'Interpreter','Latex');
set(gca, 'TickLabelInterpreter', 'latex','fontsize',fontSize-2,'YGrid','off','XGrid','on');


%% pipes plot
faceColor = 'b';
h2 = subplot(2,1,2);
%% find the range zone and average value of controlled results

y = X_link_control_result(:,ControlledPipeIndices);
meanData = mean(y,2);
[m,~] = size(y);

% Find the min and max of y data
y_max = max(y,[],2);
y_min = min(y,[],2); % 
y = [y_min y_max]';
x = 1:m;

% Find the axis limit
y_axis_max = max(y_max) + 0.05;
y_axis_min = max(0,min(y_min)-0.05);



% plot the range
px=[x,fliplr(x)];
py=[y(1,:), fliplr(y(2,:))];
patch(px,py,1,'FaceColor',faceColor,'EdgeColor','none','DisplayName','Range Zone');
alpha(transparency);
% plot mean or average value
hold on
plot(x,meanData',faceColor,'DisplayName','Average Value','LineWidth',BlueLineWidth);
hold on
% plot intested pipes
plot(X_link_control_result(:,InteresetedDirectedControlledPipeIndices(1)),'g','LineWidth',2);
plot(X_link_control_result(:,InteresetedDirectedControlledPipeIndices(2)),'Color',[0.2941 0 0.5098],'LineWidth',2);
hold on

%% find the range zone and average value of uncontrolled results
y = X_link_control_result_no_control(:,ControlledPipeIndices);
meanData = mean(y,2);
[m,~] = size(y);

% Find the min and max of y data
y_max = max(y,[],2);
y_min = min(y,[],2); % 
y = [y_min y_max]';
x = 1:m;

% Find the axis limit
y_axis_max = max(y_max) + 0.05;
y_axis_min = max(0,min(y_min)-0.05);

% plot the range
faceColor = 'r';
px=[x,fliplr(x)];
py=[y(1,:), fliplr(y(2,:))];
patch(px,py,1,'FaceColor',faceColor,'EdgeColor','white','DisplayName','Range Zone');
alpha(transparency);
% plot mean or average value
hold on
plot(x,meanData',faceColor,'DisplayName','Average Value','LineWidth',1);



% plot(X_link_control_result_no_control(:,InteresetedDirectedControlledPipeIndices),'-.');

xticks([0 360 720 1080 1440]);
xticklabels({'0','360','720','1080','1440'})
xlim([0,1440]);

yticks([0.2 0.4 0.6]);
yticklabels({'0.2','0.4','0.6'})
ylim([0.18,0.9]);

temp = LinkID(InteresetedDirectedControlledPipeIndices);
legendPipeID = ['Range Zone';'Average Value';temp;'Range Zone';'Average Value'];

lgd = legend(legendPipeID,'Location','northwest','Orientation','horizontal');
lgd.NumColumns = 4;
lgd.FontSize = fontSize-4;
set(lgd,'box','off');
set(lgd,'Interpreter','Latex');
set(gca, 'TickLabelInterpreter', 'latex','fontsize',fontSize-2,'YGrid','off','XGrid','on');
%% common titles and labels
p1 = get(h1,'position');
p2 = get(h2,'position');
height = p1(2) + p1(4) - p2(2);
position = [p2(1)-0.03 p2(2)-0.02 p2(3) height-0.2];
han = axes(fig,'position',position,'visible','off');
han.Title.Visible = 'on';
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';

xlabel(han,'Time (minute)','FontSize',fontSize,'interpreter','latex')
ylabel(han,'Concentration (mg/L)','FontSize',fontSize,'interpreter','latex')
%% print 
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 10])
print(fig,['Controlled_Net3','Area'],'-depsc2','-r300');
print(fig,['Controlled_Net3','Area'],'-dpng','-r300');