% M: # of sampling points in DFT
function X = DFT(xn, N, M)
m = 0:M-1;  % k: frequency domain 범위
X = 0;
for n=0:N-1
    X = X + xn(n+1)*exp(-1j*2*pi*m*n/M);
end
end