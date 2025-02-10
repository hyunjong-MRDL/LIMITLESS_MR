function Real_Imag_plot(X, K)
k = 0:K-1;
wk = @(k) 2*k*pi/200;
w = wk(k);

X_real = real(X); X_imag = imag(X);

figure,
subplot(121), plot(w, X_real)
xlabel('Frequency'), title('Re(X)')
subplot(122), plot(w, X_imag)
xlabel('Frequency'), title('Im(X)')
sgtitle('X(e^{j\omega_k})')

end