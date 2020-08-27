function x_estimated = Hijack_x_estimated(x_estimated)
% See Variable_Symbol_Table for the indices
x_estimated(1) = 1;
x_estimated(4:103) = 1;
%when you change the junction as 1, the pump should be 0.5 (junction +
%reservoir) which is 0.5*(1+0.8)
x_estimated(104) = 0.9;
end