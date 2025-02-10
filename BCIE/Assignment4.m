%% Question 1.1
t = -3:0.01:3;
ak = @(k) 0.5*sinc(0.5*k);
summation = 0;
for i = -2:2
    summation = summation + ak(i)*exp(j*2*i*pi*t);
end
plot(t, summation);
xlabel('t'), ylabel('$\hat{x}$(t)', 'Interpreter', 'latex')
title('Fourier Series of 5 Harmonics')

%% Question 1.2
t = -3:0.01:3;
ak = @(k) 0.5*sinc(0.5*k);
summation = 0;
for i = -9:9
    summation = summation + ak(i)*exp(j*2*i*pi*t);
end
plot(t, summation);
xlabel('t'), ylabel('$\hat{x}$(t)', 'Interpreter', 'latex')
title('Fourier Series of 19 Harmonics')

%% Question 1.3
t = -3:0.01:3;
ak = @(k) 0.5*sinc(0.5*k);
summation = 0;
for i = -49:49
    summation = summation + ak(i)*exp(j*2*i*pi*t);
end
plot(t, summation);
xlabel('t'), ylabel('$\hat{x}$(t)', 'Interpreter', 'latex')
title('Fourier Series of 99 Harmonics')

%% Question 2 (DTFT)
x1 = [1 1 1 1 1 1 1 1 1 1];
x2 = [1 1 1 1 1 -1 -1 -1 -1 -1];
x3 = [1 1 -1 -1 1 1 -1 -1 1 1];
x4 = [1 -1 1 -1 1 -1 1 -1 1 -1];

X1 = DTFT(x1, 10, 200);
X2 = DTFT(x2, 10, 200);
X3 = DTFT(x3, 10, 200);
X4 = DTFT(x4, 10, 200);

%% Question 2.1.1 (Real/Imaginary)
% Real_Imag_plot: X1~X4를 Real/Imag 별로 Plotting
% 마지막 argument: 주파수 domain 길이
Real_Imag_plot(X1, 200);
Real_Imag_plot(X2, 200);
Real_Imag_plot(X3, 200);
Real_Imag_plot(X4, 200);

%% Question 2.1.2 (Magnitude/Phase)
Mag_Phase_plot(X1, 200);
Mag_Phase_plot(X2, 200);
Mag_Phase_plot(X3, 200);
Mag_Phase_plot(X4, 200);

%% Question 2.3
X1_2T = DTFT(x1, 10, 400);
X2_2T = DTFT(x2, 10, 400);
X3_2T = DTFT(x3, 10, 400);
X4_2T = DTFT(x4, 10, 400);

Real_Imag_plot(X1_2T, 400);
Real_Imag_plot(X2_2T, 400);
Real_Imag_plot(X3_2T, 400);
Real_Imag_plot(X4_2T, 400);

%% Question 2.4
my_plot(x1, 'f');
my_plot(x2, 'f');
my_plot(x3, 'f');
my_plot(x4, 'f');

%% Question 2.5
my_plot(x1, 'i');
my_plot(x2, 'i');
my_plot(x3, 'i');
my_plot(x4, 'i');

%% Question 2.6
X1 = DFT(x1, 10, 10); X2 = DFT(x2, 10, 10);
X3 = DFT(x3, 10, 10); X4 = DFT(x4, 10, 10);
x1_recon = Inv_DFT(X1, 10, 20);
x2_recon = Inv_DFT(X2, 10, 20);
x3_recon = Inv_DFT(X3, 10, 20);
x4_recon = Inv_DFT(X4, 10, 20);

subplot(221), stem(0:19, x1_recon)
xlabel('n'), title('Reconstructed x_1[n]')
subplot(222), stem(0:19, x2_recon)
xlabel('n'), title('Reconstructed x_2[n]')
subplot(223), stem(0:19, x3_recon)
xlabel('n'), title('Reconstructed x_3[n]')
subplot(224), stem(0:19, x4_recon)
xlabel('n'), title('Reconstructed x_4[n]')

%% prac
x1 = [1 1 1 1 1 1 1 1 1 1];
x2 = [1 1 1 1 1 -1 -1 -1 -1 -1];
x3 = [1 1 -1 -1 1 1 -1 -1 1 1];
x4 = [1 -1 1 -1 1 -1 1 -1 1 -1];
n = 0:9;

figure,
subplot(221), stem(n, x1)
xlabel('n'), title('x_1[n]')
subplot(222), stem(n, x2)
xlabel('n'), title('x_2[n]')
subplot(223), stem(n, x3)
xlabel('n'), title('x_3[n]')
subplot(224), stem(n, x4)
xlabel('n'), title('x_4[n]')