%% Question 1 (Zero-Padding)
im = imread('HJ_headshot.jpg');
im = imcrop(im, [1,1,425,424]);  % 얼굴만 보이게 crop
im = imresize(im, [256 256]);  % [256, 256]으로 Resize
im = double(rgb2gray(im));  % Normalization 수행하기 위해 double로 변환
im = im/max(im(:));
im_size = max(size(im,1), size(im,2));

padsize = ceil((im_size*sqrt(2)-im_size)/2);
padded_im = padarray(im, [padsize, padsize], 0, 'both');
figure, imshow(padded_im, []);

%% Question 2.1 (Rotation & Interpolation)
im_rot = my_rotate(padded_im, 45);
im_int_4 = KNN_interpolation_4(im_rot);
im_int_8 = KNN_interpolation_8(im_rot);

figure,
subplot(131), imshow(im_rot, []), title('Rotated');
subplot(132), imshow(im_int_4, []), title('KNN (k=4)');
subplot(133), imshow(im_int_8, []), title('KNN (k=8)');

%% Question 2.2 (Sinogram)
del_theta = 1;
theta = 0:del_theta:180-del_theta;
proj = zeros(length(theta), size(padded_im, 1));
P = zeros(size(proj));

f = figure;
for k=1:length(theta)
    im_rot = my_rotate(padded_im, -theta(k));
    im_int = KNN_interpolation_4(im_rot);
    proj(k,:) = sum(im_int, 1);
    f.Position(1:4) = [500 400 800 800]; hold on;
    imshow(im_int, []);
    pause(0.05);
    P(k,:) = fftshift(fft(fftshift(proj(k,:))));
end
figure, imshow(proj, []); title('Sinogram');

%% Question 3.0 (Filtered-Backprojection, w "fft")
backprojection(proj, 1, "ramlak");
backprojection(proj, 1, "hann");
backprojection(proj, 1, "none");

%% Question 4 (FBP on Noisy Image)
n = 0.5 + 1*randn(im_size);  % Gaussian noise
In = im + n;  % Image with noise

padded_n = padarray(In, [padsize, padsize], 0, 'both');  % In: Image with noise
proj_n = projection(padded_n, 1);

b_rl = backprojection(proj_n, 1, "ramlak");
b_hann = backprojection(proj_n, 1, "hann");
b = backprojection(proj_n, 1, "none");

%% Question 5 & 6 (Effect of Rotation Angle "Delta theta")
proj_tenth = projection(padded_im, 0.1);  % Del_theta = 0.1;
proj_1 = projection(padded_im, 1);  % Del_theta = 1;
proj_5 = projection(padded_im, 5);  % Del_theta = 5;
proj_10 = projection(padded_im, 10);  % Del_theta = 10;

b_tenth = backprojection(proj_tenth, 0.1, "ramlak");
b_1 = backprojection(proj_1, 1, "ramlak");
b_5 = backprojection(proj_5, 5, "ramlak");
b_10 = backprojection(proj_10, 10, "ramlak");

%% Question 7.a (Motion Correction, basic setting)
shifted_im = padded_im;
shifted_im = padarray(shifted_im, [10, 10], 0, "both");
shift_size = size(shifted_im, 1);
proj_motion = zeros([180, shift_size]);  % Projection with motion
pf_motion = zeros(size(proj_motion));  % Filtered projection with motion
pf_corrected = zeros(size(proj_motion));  % Corrected projection

P_motion = zeros(size(proj_motion));  % Freq. domain projection with motion
P_corrected = zeros(size(proj_motion));  % Freq. domain corrected projection
b_motion = zeros(shift_size);  % Backprojected image with motion
b_corrected = zeros(shift_size);  % Backprojected image with correction

df = 2*pi/shift_size;
half = shift_size/2;
rl_freqs = -df*half:df:df*(half-1);
rl_filter = abs(rl_freqs);  % Row vectors concatenated vertically
%%% Ram-Lak filter = [ - abs(freqs) - ]
%%%                        . . .
%%%                  [ - abs(freqs) - ]

%% Question 7.b (Forward projection, w. motion)
del_theta = 1;
theta = 0:del_theta:180-del_theta;
for i=1:length(theta)
    if mod(i, 10) == 0
        shifted_im = circshift(shifted_im, 1, 2);  %  Shift image 1 pixel to direction of (AXIS=2)
    end
    I_rot = my_rotate(shifted_im, -theta(i));
    I_int = KNN_interpolation_4(I_rot);
    proj_motion(i,:) = sum(I_int, 1);
    P_motion(i,:) = fftshift(fft(fftshift(proj_motion(i,:))));
end
figure,
subplot(121), imshow(proj, []), title('p(r,\theta)');
subplot(122), imshow(proj_motion, []), title('p(r,\theta) with motion');

figure,
subplot(121), imshow(log(abs(P)), []), title('P(k,\theta)');
subplot(122), imshow(log(abs(P_motion)), []), title('P_{motion}(k,\theta)');

%% Question 7.c (Freq. domain projection)
pf_orig = zeros(size(proj));
shift = 0;
for j=1:length(theta)
    if mod(j, 10) == 0
        shift = shift + 1;
    end
    phase_diff = exp(-1j*rl_freqs*shift*(cosd(theta(j))));
    P_corrected(j,:) = P_motion(j,:) ./ phase_diff;
end

Pf_motion = P_motion .* rl_filter;
Pf_corrected = P_corrected .* rl_filter;

for k=1:length(theta)
    pf_motion(k,:) = ifftshift(ifft(ifftshift(Pf_motion(k,:))));
    pf_corrected(k,:) = ifftshift(ifft(ifftshift(Pf_corrected(k,:))));
end
figure,
subplot(121), imshow(log(abs(Pf_motion)), []), title('Filtered P_{motion}(k,\theta)');
subplot(122), imshow(log(abs(Pf_corrected)), []), title('Filtered P_{corrected}(k,\theta)');

figure,
subplot(121), imshow(log(abs(pf_motion)), []), title('Filtered p_{motion}(r,\theta)');
subplot(122), imshow(log(abs(pf_corrected)), []), title('Filtered p_{corrected}(r,\theta)');

%% Question 7.d (Filtered backprojection)
for l=1:length(theta)
    pfm_theta = pf_motion(l,:) .* ones(shift_size);
    pfm_rot = my_rotate(pfm_theta, theta(l));
    pfm_int = KNN_interpolation_4(pfm_rot);
    b_motion = b_motion + pfm_int;

    pfc_theta = pf_corrected(l,:) .* ones(shift_size);
    pfc_rot = my_rotate(pfc_theta, theta(l));
    pfc_int = KNN_interpolation_4(pfc_rot);
    b_corrected = b_corrected + pfc_int;
end

figure,
subplot(121), imshow(abs(b_motion), []), title('b_{motion}(x,y)');
subplot(122), imshow(abs(b_corrected), []), title('b_{corrected}(x,y)');

%% Question 7.e (Original projection)
b_orig = zeros(size(padded_size));
Pf_orig = P .* rl_filter;
for l=1:length(theta)
    pf_orig = ifftshift(ifft(ifftshift(Pf_orig(l,:))));
    pf_theta = pf_orig .* ones(padded_size);
    pf_rot = my_rotate(pf_theta, theta(l));
    pf_int = KNN_interpolation_4(pf_rot);
    b_orig = b_orig + pf_int;
end

figure, imshow(abs(b_orig), []), title('b_{original}(x,y)');