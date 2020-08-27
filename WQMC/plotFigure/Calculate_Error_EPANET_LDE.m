function errorVetor = Calculate_Error_EPANET_LDE(EPANET_Result,LDE_Result)
% we use norm 2 relative error
% https://www.netlib.org/lapack/lug/node75.html
EPANET_Result_X = EPANET_Result';
LDE_Result_X = LDE_Result';
%d1=dtw(EPANET_Result_X,LDE_Result_X,30);

EPANET_Result = EPANET_Result(:,2:end);
LDE_Result = LDE_Result(:,1:end-1);
LDE_Result(:,1) = EPANET_Result(:,1);
[~,sizeEPANET] = size(EPANET_Result);
[~,sizeLDE] = size(LDE_Result);
TimeInMinutes = min(sizeEPANET,sizeLDE);
Error = EPANET_Result(:,1:TimeInMinutes) - LDE_Result(:,1:TimeInMinutes);
errorVetor = zeros(1,TimeInMinutes);
for i = 1:TimeInMinutes
    errorVetor(i) = norm(Error(:,i))/ norm(EPANET_Result(:,i));
end

figure1 = figure;
fontsize = 40;
plot(errorVetor,'LineWidth',2);
xticks([0 360 720 1080 1440])
% yticks([0.005 0.015 0.025])
% yticklabels({'0.5\%','1.5\%','2.5\%'})
xlim([0,1440])
%ylim([200,900]);
set(gca, 'TickLabelInterpreter', 'latex','fontsize',fontsize);
% lgd = legend(LinkID4Legend,'Location','eastoutside','Interpreter','Latex');
% lgd.FontSize = fontsize-6;
% %title('$h^{M} = s^2 (h_0 - r (q/s)^{\nu})$','interpreter','latex','FontSize',fontsize+7)
% set(lgd,'box','off')
% set(lgd,'Interpreter','Latex');

xlabel('Time (minute)','FontSize',fontsize,'interpreter','latex')
%ylabel({'Relative error between ';'   EPANET and LDE'},'FontSize',fontsize,'interpreter','latex')
ylabel('RE','FontSize',fontsize,'interpreter','latex')
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 5])
print(figure1,'Error_EPANET_LDE','-depsc2','-r300');
print(figure1,'Error_EPANET_LDE','-dpng','-r300');
end