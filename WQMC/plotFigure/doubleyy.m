clear
clc
h = figure;
fontsize = 40;
x = 0:0.01:20;
y1 = 200*exp(-0.05*x).*sin(x);
y2 = 0.8*exp(-0.5*x).*sin(10*x);
% plotyy returns the handles of the two axes created in
% AX and the handles of the graphics objects from 
% each plot in H1 and H2. 
% AX(1) is the left axes and AX(2) is the right axes.
[AX,H1,H2] = plotyy(x,y1,x,y2,'plot');
set(AX(1),'XColor','k','YColor','b','FontSize',fontsize,'TickLabelInterpreter', 'latex');
set(AX(2),'XColor','k','YColor','r','FontSize',fontsize,'TickLabelInterpreter', 'latex');
% set the lim of YTick
set(AX(1),'YTick',-200:100:200);
set(AX(2),'YTick',-0.8:0.4:0.8);
set(H1,'LineWidth',2.5);set(H2,'LineWidth',2.5);

HH1=get(AX(1),'Ylabel');
set(HH1,'String','Left Y-axis','interpreter', 'latex');
set(HH1,'color','b');
HH2=get(AX(2),'Ylabel');
set(HH2,'String','Right Y-axis','interpreter', 'latex');set(HH2,'color','r');
set(H1,'LineStyle','-');
set(H1,'color','b');
set(H2,'LineStyle',':');
set(H2,'color','r');
xlabel('Zero to 20 $\mu$ sec.','interpreter', 'latex');
title('Labeling plotyy','interpreter','latex');

lgd = legend([H1,H2],{'y1 = 200 exp(-0.05x).*sin(x)';'y2 = 0.8exp(-0.5x).*sin(10*x)'});
lgd.NumColumns=1;
set(lgd,'box','off')
set(lgd,'Interpreter','latex','FontSize',fontsize);
% adjust the position of % pos = get(AX,'Position');% pos = pos{2};% pos(1) = pos(1) + 0.05;% pos(3) = pos(3) - 0.05;% set(AX,'Position',pos)
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 13])
print(h,'plottyExample','-depsc2','-r300');