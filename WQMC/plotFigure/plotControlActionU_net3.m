figure1 = figure;
fontsize = 40;
ControlActionU1 = ControlActionU(1:1440,:);
plot(ControlActionU1,'LineWidth',3);
xticks([0 360 720 1080 1440])
xlim([0,1440])
%ylim([200,900]);
set(gca, 'TickLabelInterpreter', 'latex','fontsize',fontsize,'YGrid','off','XGrid','on');
lgd = legend(Location_B,'Location','Best','Interpreter','Latex','Orientation','horizontal');
lgd.FontSize = fontsize;
%title('$h^{M} = s^2 (h_0 - r (q/s)^{\nu})$','interpreter','latex','FontSize',fontsize+7)
set(lgd,'box','off')
set(lgd,'Interpreter','Latex');

xlabel('Time (minute)','FontSize',fontsize,'interpreter','latex')
ylabel({'Mass rate at ';'boosters';'(mg/minute)'},'FontSize',fontsize-3,'interpreter','latex')
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 5])
print(figure1,'ControlActionU_net3','-depsc2','-r300');
print(figure1,'ControlActionU_net3','-dpng','-r300');
