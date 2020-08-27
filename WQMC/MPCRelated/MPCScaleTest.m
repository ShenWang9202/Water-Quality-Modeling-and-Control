function  MPCScaleTest
A = [1 1;0 1];
B = [0.5;1];
C = [1 0];
Np = 10;
[W,Z,Ca,PhiA,GammaA] = MPCScale(A,B,C,Np);
W
Z
Ca
PhiA
GammaA
end