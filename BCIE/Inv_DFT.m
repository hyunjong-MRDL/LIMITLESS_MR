function x = Inv_DFT(X, M, N)
xn_length = 10; % Length of input sequence
n = 0:N-1;
x = 0;
for m=0:M-1
    x = x + X(m+1)*exp(1j*2*pi*m*n/M);
end
x = x/xn_length;
end