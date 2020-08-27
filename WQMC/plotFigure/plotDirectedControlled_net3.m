faceColor = 'b';
transparency = 0.2;
fontSize = 40;

DirectedControlledJunctionID = {'J217','J237','J247'};%NodeID';
InterestedID = unique(DirectedControlledJunctionID);
IDcell = NodeID;
[~,n] = size(InterestedID);
DirectedControlledJunctionIndices = [];
for i = 1:n
    % find index according to ID.
    DirectedControlledJunctionIndices = [DirectedControlledJunctionIndices findIndexByID(InterestedID{i},IDcell)];
end


DirectedControlledPipeID = {'P269','P271','P273',...
    'P283','P285','P287',...
    'P257','P251'};
InterestedID = unique(DirectedControlledPipeID);
IDcell = LinkID;
[~,n] = size(InterestedID);
DirectedControlledPipeIndices = [];
for i = 1:n
    DirectedControlledPipeIndices = [DirectedControlledPipeIndices findIndexByID(InterestedID{i},IDcell)];
end

InteresetedDirectedControlledPipeID = {'P273','P281','P251'};
InterestedID = unique(InteresetedDirectedControlledPipeID);
IDcell = LinkID;
[~,n] = size(InterestedID);
InteresetedDirectedControlledPipeIndices = [];
for i = 1:n
    InteresetedDirectedControlledPipeIndices = [InteresetedDirectedControlledPipeIndices findIndexByID(InterestedID{i},IDcell)];
end


fig = figure;
%% Junction plots
h1 = subplot(2,1,1);
plot(X_node_control_result(:,DirectedControlledJunctionIndices),'LineWidth',lineWidth);
hold on
plot(X_node_control_result_no_control(:,DirectedControlledJunctionIndices),'-.','LineWidth',lineWidth);

xticks([0 360 720 1080 1440]);
xticklabels({'0','360','720','1080','1440'})
xlim([0,1440]);

yticks([0.2 0.6 1]);
yticklabels({'0.2','0.6','1'})
ylim([0.18,1.3]);

temp = NodeID(DirectedControlledJunctionIndices);
legendJunctionID = [temp;temp];
legendJunctionID{3} = [legendJunctionID{3}, ' (controlled)'] ;
legendJunctionID{6} = [legendJunctionID{6}, ' (uncontrolled)'];
lgd = legend(legendJunctionID,'Location','northwest','Orientation','horizontal');
lgd.NumColumns = 3;
lgd.FontSize = fontSize-4;
set(lgd,'box','off');
set(lgd,'Interpreter','Latex');
set(gca, 'TickLabelInterpreter', 'latex','fontsize',fontSize-2,'YGrid','off','XGrid','on');


%% pipes plot

h2 = subplot(2,1,2);
%% find the range zone and average value of controlled results

y = X_link_control_result(:,DirectedControlledPipeIndices);
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
plot(X_link_control_result(:,InteresetedDirectedControlledPipeIndices),'LineWidth',2);
hold on

%% find the range zone and average value of uncontrolled results
y = X_link_control_result_no_control(:,DirectedControlledPipeIndices);
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
patch(px,py,1,'FaceColor',faceColor,'EdgeColor','none','DisplayName','Range Zone');
alpha(transparency+0.2);
% plot mean or average value
hold on
plot(x,meanData',faceColor,'DisplayName','Average Value','LineWidth',1);



% plot(X_link_control_result_no_control(:,InteresetedDirectedControlledPipeIndices),'-.');

xticks([0 360 720 1080 1440]);
xticklabels({'0','360','720','1080','1440'})
xlim([0,1440]);

yticks([0.2 0.4 0.6]);
yticklabels({'0.2','0.4','0.6'})
ylim([0.18,0.94]);

temp = LinkID(InteresetedDirectedControlledPipeIndices);
legendPipeID = ['Range Zone (controlled)';'Average Value ';temp;'Range Zone (uncontrolled)';'Average Value'];

lgd = legend(legendPipeID,'Location','north','Orientation','horizontal');
lgd.NumColumns = 5;
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
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 7])
print(fig,['Controlled_Net3'],'-depsc2','-r300');
print(fig,['Controlled_Net3'],'-dpng','-r300');