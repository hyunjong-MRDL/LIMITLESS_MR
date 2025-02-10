%% Remedy of Ringing Artifacts (Zero-paddings)
im_size1 = 256; im_size2 = im_size1*2;
im_size3 = im_size1*4; im_size4 = im_size1*8;
s_size = 32;
pad_size1 = (im_size1-s_size)/2;
pad_size2 = (im_size2-s_size)/2;
pad_size3 = (im_size3-s_size)/2;
pad_size4 = (im_size4-s_size)/2;
im1 = zeros(im_size1);
im1(pad_size1+1:pad_size1+s_size, pad_size1+1:pad_size1+s_size) = 1;
im2 = zeros(im_size2);
im2(pad_size2+1:pad_size2+s_size, pad_size2+1:pad_size2+s_size) = 1;
im3 = zeros(im_size3);
im3(pad_size3+1:pad_size3+s_size, pad_size3+1:pad_size3+s_size) = 1;
im4 = zeros(im_size4);
im4(pad_size4+1:pad_size4+s_size, pad_size4+1:pad_size4+s_size) = 1;
figure,
subplot(221), imshow(im1, []), title('Size 256');
subplot(222), imshow(im2, []), title('Size 512');
subplot(223), imshow(im3, []), title('Size 1024');
subplot(224), imshow(im4, []), title('Size 2048');
I1 = fftshift(fft2(fftshift(im1)));
I2 = fftshift(fft2(fftshift(im2)));
I3 = fftshift(fft2(fftshift(im3)));
I4 = fftshift(fft2(fftshift(im4)));
figure,
subplot(221), imshow(log(abs(I1)), []), title('Size 256');
subplot(222), imshow(log(abs(I2)), []), title('Size 512');
subplot(223), imshow(log(abs(I3)), []), title('Size 1024');
subplot(224), imshow(log(abs(I4)), []), title('Size 2048');