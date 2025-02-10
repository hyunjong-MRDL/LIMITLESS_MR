function Mag_Phase_plot(X, K)
k = 0:K-1;
wk = @(k) 2*k*pi/200;
w = wk(k);

X_mag = abs(X); X_phase = angle(X);

figure,
subplot(121), plot(w, X_mag)
xlabel('Frequency'), title('Magnitude')
subplot(122), plot(w, X_phase)
xlabel('Frequency'), title('Phase')
sgtitle('X(e^{j\omega_k})')

end