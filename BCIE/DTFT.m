% xn: Input discrete sequence
% N: Length of input sequence xn
function X = DTFT(xn, N, K)
omega_s = 200;  % omega_s: # of Discretized samples of frequency domain (문제에서 지정)
% 컴퓨터는 continuous signal 계산 불가 -> discrete만 계산 가능, continuous에 근사할 수 있도록 최대한 많은 sample 추출
k = 0:K-1;  % k: frequency domain 범위 (내가 보고 싶은)
X = 0;
for n=0:N-1
    X = X + xn(n+1)*exp(-1j*2*pi*k*n/omega_s);
end
end