%curve 1
t1=0:1:50;
X1=(2*cos(t1/5)+3-t1.^2/200)/2;
Y1=2*sin(t1/5)+3;

%curve 2
X2=(2*cos(t1/4)+2-t1.^2/200)/2;
Y2=2*sin(t1/5)+3;

%curve 3
X3=(2*cos(t1/4)+2-t1.^2/200)/2;
Y3=2*sin(t1/4+2)+3;

f12=frechet(X1',Y1',X2',Y2');
f13=frechet(X1',Y1',X3',Y3');
f23=frechet(X2',Y2',X3',Y3');
f11=frechet(X1',Y1',X1',Y1');
f22=frechet(X2',Y2',X2',Y2');
f33=frechet(X3',Y3',X3',Y3');

figure;
subplot(2,1,1)
hold on
plot(X1,Y1,'r','linewidth',2)
plot(X2,Y2,'g','linewidth',2)
plot(X3,Y3,'b','linewidth',2)
legend('curve 1','curve 2','curve 3','location','eastoutside')
xlabel('X')
ylabel('Y')
axis equal tight
box on
title(['three space curves to compare'])
legend

subplot(2,1,2)
imagesc([[f11,f12,f13];[f12,f22,f23];[f13,f23,f33]])
xlabel('curve')
ylabel('curve')
cb1=colorbar('peer',gca);
set(get(cb1,'Ylabel'),'String','Frechet Distance')
axis equal tight