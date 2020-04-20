function [W,Z,Ca,PhiA,GammaA] = MPCScale(A,B,C,Np)
D = 0;
A_d = A;
B_d = B;
C_d = C;
n =size(A_d,1);
p =size(C_d,1);
% build PhiA;
PhiA = [A_d sparse(n,p);
    C_d*A_d speye(p)];
% build GammaA;
GammaA = [B_d;C_d*B_d];
PhiA = sparse(PhiA);
GammaA = sparse(GammaA);
Ca = [sparse(p,n) speye(p)];
%build W;
Cell_temp = cell(1,Np);
Cell_temp{1} = Ca*PhiA;
% size(Ca)
% size(PhiA)

for i = 2:Np
    Cell_temp{i} = Cell_temp{i-1}*PhiA;
end

% [m_n, n_n] = size(Ca*PhiA);
% W = zeros(Np*m_n,n_n);
% for i = 1:Np
%     row_temp = ((i-1)*m_n + 1):(i*m_n);
%     W(row_temp,:) = Cell_temp{i};
% end

W = cell(Np,1);
for i = 1:Np
    W(i) = Cell_temp(i);
end
W = cell2mat(W);
W = sparse(W);
%build Z;

% build first column of Z ,which is Cell_temp;
for i = 1:Np
    Cell_temp{i}  = Cell_temp{i} * GammaA;
end
% Cell_temp{i} = Cell_temp{i-1}
for i = 0:Np -2
    Cell_temp{Np-i}  = Cell_temp{Np-i -1};
end
% deal with the first element
Cell_temp {1} = Ca * GammaA;
 
%build Z_cell,the size is NpxNp
Z_cell = cell(Np,Np);
% build zero_vector in Z
zero_vector = zeros(size(Cell_temp{1}));
% each element in Z consists of the element in Cell_temp or zero_vector
for row = 1:Np
    for column = 1:Np
        if(column > row)
            Z_cell{row,column} = zero_vector;
        else
            Z_cell{row,column} = Cell_temp{row + 1 - column};
        end
    end
end
% convert cell to matrix Z
Z = cell2mat(Z_cell);
Z = sparse(Z);
end
