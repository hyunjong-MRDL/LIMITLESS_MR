%% Question 1.1
n = 0:199;
x = cos(2*pi*0.005*n);
stem(n,x); % stem: Discrete-time datapoints에서 x축을 수선을 내린 그래프
xlabel('n'), ylabel('cos(2\pi*0.005n)'); grid on;

%% Question 1.2
n = 0:199;
x_n = 0;
for k=1:10
    out = cos(2*pi*0.005*k*n);
    x_n = x_n + out;
end
stem(n, x_n);
xlabel('n'), ylabel('cos(2\pi*0.005*k*n)'); grid on;

%% Question 1.3
n = 0:199;
x_n = 0;
for k=1:10
    out = cos(2*pi*0.005*k*n);
    x_n = x_n + out;
end
xn_shift = fftshift(x_n); % Rearranges F{X} by shifting the zero-frequency component to the center of the array.
stem(n, xn_shift);
xlabel('n'), ylabel('cos(2\pi*0.005*k*n)'); grid on;

%% Question 2.1
n_length = 100;

y = DT_square_conv(8,7);
y = [y zeros(1,n_length-length(y))];
stem(0:length(y)-1, y)
xlabel('n'), ylabel('y(n)'), title('N=2')

%% Question 2.2
y_3 = DT_square_conv(30,3);
y_3 = [y_3 zeros(1,n_length-length(y_3))];
figure, stem(0:length(y_3)-1, y_3);
xlabel('n'), ylabel('y(n)'), title('N=3')

y_5 = DT_square_conv(30,5);
y_5 = [y_5 zeros(1,n_length-length(y_5))];
figure, stem(0:length(y_5)-1, y_5);
xlabel('n'), ylabel('y(n)'), title('N=5')

y_10 = DT_square_conv(30,10);
y_10 = [y_10 zeros(1,n_length-length(y_10))];
figure, stem(0:length(y_10)-1, y_10);
xlabel('n'), ylabel('y(n)'), title('N=10')

%% Question 2.3
n_length = 100;
x = ones(1,30);

h_2 = ones(1,2);
y_2 = conv(x,h_2);
y_2 = [y_2 zeros(1,n_length-length(y_2))];
figure, stem(0:n_length-1, y_2)
xlabel('n'), ylabel('y(n)'), title('N=2')

h_3 = ones(1,3);
y_3 = conv(x,h_3);
y_3 = [y_3 zeros(1,n_length-length(y_3))];
figure, stem(0:n_length-1, y_3)
xlabel('n'), ylabel('y(n)'), title('N=3')

h_5 = ones(1,5);
y_5 = conv(x,h_5);
y_5 = [y_5 zeros(1,n_length-length(y_5))];
figure, stem(0:n_length-1, y_5)
xlabel('n'), ylabel('y(n)'), title('N=5')

h_10 = ones(1,10);
y_10 = conv(x,h_10);
y_10 = [y_10 zeros(1,n_length-length(y_10))];
figure, stem(0:n_length-1, y_10)
xlabel('n'), ylabel('y(n)'), title('N=10')

%% Question 3.1
im_size = 255;
im = phantom(im_size);

n_std = 0.1;
n = n_std*randn(size(im));
im_n = im + n;

kernel_size = 5;
kernel = gausswin(kernel_size, 1);
kernel_2D = kernel*kernel';
expanded_kernel = zeros(size(im));
i = (im_size-kernel_size)/2+1;
j = (im_size+kernel_size)/2;
expanded_kernel(i:j, i:j) = kernel_2D;
im_dn = conv2(im_n, expanded_kernel, 'same');

figure,
subplot(131), imshow(im, []), title('Original image');
subplot(132), imshow(im_n, []), title('Image with random noise');
subplot(133), imshow(im_dn, []), title('Denoised image');

impulse = zeros(size(im));
impulse(128, 128) = 1;
reduced_conv_out = conv2(kernel_2D, impulse, 'same');
conv_out = conv2(expanded_kernel, impulse, 'same');

figure,
subplot(131), imshow(impulse, []), title('Impulse function');
subplot(132), imshow(kernel_2D, []), title('Gaussian kernel (size=5)');
subplot(133), imshow(reduced_conv_out, []), title('\delta(x,y) \ast h(x,y)');

[X, Y] = meshgrid(1:im_size, 1:im_size);
figure, surf(X, Y, impulse, EdgeColor="#0072BD");
xlabel('x'), ylabel('y'), zlabel('value'), title('Impulse function');
figure, surf(X, Y, expanded_kernel, EdgeColor="#0072BD");
xlabel('x'), ylabel('y'), zlabel('value'), title('Gaussian kernel (size=5), h(x,y)');
figure, surf(X, Y, conv_out, EdgeColor="#0072BD");
xlabel('x'), ylabel('y'), zlabel('value'), title('\delta(x,y) \ast h(x,y)');

%% Question 3.2
im_size = 255;
im = phantom(im_size);

n_std = 0.1;
n = n_std*randn(size(im));
im_n = im + n;

kernel_size = 11;
kernel = gausswin(kernel_size, 1);
kernel_2D = kernel*kernel';
expanded_kernel = zeros(size(im));
i = (im_size-kernel_size)/2+1;
j = (im_size+kernel_size)/2;
expanded_kernel(i:j, i:j) = kernel_2D;
im_dn = conv2(im_n, expanded_kernel, 'same');

figure,
subplot(131), imshow(im, []), title('Original image');
subplot(132), imshow(im_n, []), title('Image with random noise');
subplot(133), imshow(im_dn, []), title('Denoised image');

impulse = zeros(size(im));
impulse(128, 128) = 1;
reduced_conv_out = conv2(kernel_2D, impulse, 'same');
conv_out = conv2(expanded_kernel, impulse, 'same');

figure,
subplot(131), imshow(impulse, []), title('Impulse function');
subplot(132), imshow(kernel_2D, []), title('Gaussian kernel (size=11)');
subplot(133), imshow(reduced_conv_out, []), title('\delta(x,y) \ast h(x,y)');

[X, Y] = meshgrid(1:im_size, 1:im_size);
figure, surf(X, Y, impulse, EdgeColor="#0072BD");
xlabel('x'), ylabel('y'), zlabel('value'), title('Impulse function');
figure, surf(X, Y, expanded_kernel, EdgeColor="#0072BD");
xlabel('x'), ylabel('y'), zlabel('value'), title('Gaussian kernel (size=11), h(x,y)');
figure, surf(X, Y, conv_out, EdgeColor="#0072BD");
xlabel('x'), ylabel('y'), zlabel('value'), title('\delta(x,y) \ast h(x,y)');