function y = DT_square_conv(M, N)
% M: length of x[n] signal
% N: length of h[n] signal
y = zeros(1,x_n+2*h_n-2);  % output을 입력받을 empty array 생성
x = y;
h = y;
for i=h_n:h_n+x_n-1
    x(i) = 1;
end
for j=1:h_n
    h(j) = 1;
end
k = h_n; % Rightmost index of h[n]
while k <= length(y)
    y(k-h_n+1) = sum(h.*x);
    h(k+1) = 1;
    h(k-h_n+1) = 0;
    k = k + 1;
end
end