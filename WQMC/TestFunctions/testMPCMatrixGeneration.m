A = PreviousSystemDynamicMatrix.A;
B = PreviousSystemDynamicMatrix.B;
C = PreviousSystemDynamicMatrix.C;
Np = 200;
 tic
% [W,Z,Ca,PhiA,GammaA] = MPCScale(A,B,C,Np);
[W,Z,Ca,PhiA,GammaA] = MPCScale(A,B,C,Np);
 time1 = toc
[W1,Z1,Ca,PhiA,GammaA] = MPCScale2(A,B,C,Np);
time2 = toc;
% figure
% spy(W)
% figure
% spy(W1)
% time1
time2 = time2-time1