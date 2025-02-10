%—– Signal shifting
%y(n) = {x(n-k)}
%m = n-k , n = m+k
%y(m+k) = {x(m)}
%————————-
%x(n)=x(n-n0)
%————————-
function [y,n]=sigshift(x,m,n0)
n= m+n0;
y=x;