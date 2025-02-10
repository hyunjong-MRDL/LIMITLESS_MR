function my_plot(xn, tr_type)
% xn: original DT signal
% tr_type: transform type (Fourier / Inverse) -> ("f"/"i")
N = 10; % 입력 sequence의 길이
K = 200; % DTFT의 주파수 범위
M = 10; % # of sampling points in DFT
k = 0:K-1;
m = 0:M-1;

% Filter start
spacing = K/M;
filter = zeros(1,K);
for i=0:K-1
    if rem(i,spacing) == 0
        filter(i+1) = 1;
    end
end
% Filter end

Xn = DTFT(xn, N, K);
Xn_real = real(Xn); Xn_imag = imag(Xn);
Xn_smp = Xn.*filter;
Xs_real = real(Xn_smp); Xs_imag = imag(Xn_smp);
XD = DFT(xn, N, M);
XD_real = real(XD); XD_imag = imag(XD);

if tr_type == "f"
    figure,
    subplot(221), stem(m, XD_real)
    xlabel('Frequency'), title('Re(X_D[k])')
    subplot(222), plot(k, Xn_real), hold on; stem(k, Xs_real)
    xlabel('Frequency'), title('Re(X[k])')
    subplot(223), stem(m, XD_imag)
    xlabel('Frequency'), title('Im(X_D[k])')
    subplot(224), plot(k, Xn_imag), hold on; stem(k, Xs_imag)
    xlabel('Frequency'), title('Im(X[k])'),
    sgtitle('X_D(e^{j\omega_k})')
else
    n = 0:N-1;
    xn_recon = Inv_DFT(XD, M, N);
    figure,
    subplot(211), stem(n, xn), title('Original x[n]')
    subplot(212), stem(n, xn_recon)
    xlabel('n'), title('Reconstructed x[n]')
end
end