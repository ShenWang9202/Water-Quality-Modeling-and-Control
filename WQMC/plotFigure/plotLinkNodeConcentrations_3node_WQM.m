function plotLinkNodeConcentrations_3node_WQM(ID4Legend,X_control_result,fileName)
figure1 = figure
h1 = subplot(1,2,1)
fontsize = 38;
plot(X_control_result,'LineWidth',3);
xticks([0 360 720 1080 1440])
yticks([0 1.0 2.0 3.0])
xlim([-30,1440])
ymin = min(min(X_control_result));
ymax = max(max(X_control_result));
ymax = ymax+0.2;
ylim([ymin,ymax]);
yticks([0 0.8 1.6])

 ax = gca();
% ax.YRuler.Exponent = 3;
 ax.YRuler.TickLabelFormat = '%.1f';

set(gca, 'TickLabelInterpreter', 'latex','fontsize',fontsize);
lgd = legend(ID4Legend,'Location','Best','Interpreter','Latex','Orientation','horizontal');
lgd.FontSize = fontsize;
%title('$h^{M} = s^2 (h_0 - r (q/s)^{\nu})$','interpreter','latex','FontSize',fontsize+7)
set(lgd,'box','off')
set(lgd,'Interpreter','Latex');

% xlabel('Time (minute)','FontSize',fontsize,'interpreter','latex')
ylabel({'Concentration (mg/L)'},'FontSize',fontsize-3,'interpreter','latex')


%% plot enlarged part
h2 = subplot(1,2,2)
InterestedTime1 = 1;
InterestedTime2 = 20;
ranges = InterestedTime1:InterestedTime2;

plot(ranges,X_control_result(ranges,:),'LineWidth',3);
xticks([InterestedTime1 InterestedTime2])
xlim([InterestedTime1,InterestedTime2])
ymin = min(min(X_control_result));
ymax = max(max(X_control_result));
ymax = ymax + 0.2;
ylim([ymin,ymax]);
h = gca; h.YAxis.Visible = 'off';

xlim([InterestedTime1 InterestedTime2]);
% xlabel('  ','FontSize',fontsize,'interpreter','latex')
set(gca, 'TickLabelInterpreter', 'latex','fontsize',fontsize);

% set(h1, 'Position', [0.1, 0.1, 0.75, 0.8]);
% set(h2, 'Position', [0.9, 0.1, 0.1, 0.8])
FirstPosition = h1.Position;

SecondPosition = h2.Position;
FirstPosition(3) = 0.6;
SecondPosition(1) = FirstPosition(1) + FirstPosition(3) + 0.08;
SecondPosition(3) = 0.15;
FirstPosition(2) = 0.25
FirstPosition(4) = 0.6
SecondPosition(2)  = FirstPosition(2) ;
SecondPosition(4)  = FirstPosition(4);
set(h1, 'Position',FirstPosition)
set(h2, 'Position',SecondPosition)

h1
h2

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 6])
print(figure1,fileName,'-depsc2','-r300');
end