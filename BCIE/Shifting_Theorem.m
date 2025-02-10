%%% Shifting Theorem in Fourier Transform %%%
%% CASE1: 1D FT
% N: number of sampling points
% T: length of time domain
N = 10;
T = 2*pi;
t = linspace(0, T, N);
y = cos(t);

dt = T/(N-1);  % (N-1) spacings in N points
shift_num = 2;  % How many spacings are shifted
shift = shift_num * dt;
y_shift = circshift(y, shift_num);

df = 1/(N*dt);
freq = 0:df:(1/T-df);

figure,
subplot(121), stem(t, y); title('Original function');
subplot(122), stem(t, y_shift); title('Shifted function');

Y = fftshift(fft(fftshift(y)));
Y_shift = fftshift(fft(fftshift(y_shift)));

figure,
subplot(121), stem(t, real(Y)); title('Original freq. response');
subplot(122), stem(t, real(Y_shift)); title('Shifted freq. response');

phase_shift = exp(-1j*2*pi*freq*shift);
Y_corrected = Y_shift ./ phase_shift;
y_corrected = ifftshift(ifft(ifftshift(Y_corrected)));
figure,
subplot(121), stem(t, real(Y)); title('Original reconstruction');
subplot(122), stem(t, real(Y_corrected)); title('Corrected reconstruction');