function plotPipeSegmentVSLength(FileName,ylim1,ylim2,NumberofSegment4Pipes,LinkLengthPipe,PipeCount)
h = figure;
fontsize = 30;
x = [1:PipeCount(1)];
y1 = 200*exp(-0.05*x).*sin(x);
y2 = 0.8*exp(-0.5*x).*sin(10*x);

Segments=[NumberofSegment4Pipes' zeros(PipeCount(1),1)];
Length=[zeros(PipeCount(1),1)    LinkLengthPipe' ];
[AX,H1,H2] = plotyy(x,Segments,x,Length, 'bar', 'bar');

bluecolor = [0.00,0.45,0.74];
redcolor = [0.85, 0.33, 0.10];
set(AX(1),'XColor','k','YColor',bluecolor,'FontSize',fontsize,'TickLabelInterpreter', 'latex');
set(AX(2),'XColor','k','YColor',redcolor,'FontSize',fontsize,'TickLabelInterpreter', 'latex');

set(AX(1),'YLim',[0,ylim1]);
set(AX(2),'YLim',[0,ylim2]);

HH1=get(AX(1),'Ylabel');
set(HH1,'String','Number of segments','interpreter', 'latex');
set(HH1,'color',bluecolor);
HH2=get(AX(2),'Ylabel');
set(HH2,'String','Length (ft)','interpreter', 'latex');
set(HH2,'color',redcolor);
% set(H1,'LineStyle','-');
% set(H1,'color','b');
% set(H2,'LineStyle',':');
% set(H2,'color','r');
xlabel('Pipe IDs','interpreter', 'latex');
xticklabels('')
% title('Labeling plotyy','interpreter','latex');
% adjust the position of % 
pos = get(AX,'Position')
pos1 = pos{1};
pos1(2) = pos1(2) + 0.08;
pos1(4) = pos1(4) - 0.08;
pos{1} = pos1;

pos2 = pos{2};
pos2(2) = pos2(2) + 0.08;
pos2(4) = pos2(4) - 0.08;
pos{2} = pos2;

set(AX(1),'Position',pos{1})
set(AX(2),'Position',pos{2})
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 25 5])
print(h,FileName,'-depsc2','-r300');