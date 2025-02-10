%% Question 1 (Basic setting)
im_size = 256;
f = zeros(im_size);
s_size = 32;  % signal size
padsize = (im_size-s_size)/2;
f(padsize+1:padsize+s_size, padsize+1:padsize+s_size) = 1;
F = fftshift(fft2(fftshift(f)));
f_shift = circshift(f, -32, 1);
F_shift = fftshift(fft2(fftshift(f_shift)));
figure,
subplot(121), imshow(f, []), title('Original image');
subplot(122), imshow(f_shift, []), title('Shifted image');
figure,
subplot(221), imshow(log(real(F)), []), title('Real part of F[I]');
subplot(222), imshow(log(imag(F)), []), title('Imag part of F[I]');
subplot(223), imshow(log(real(F_shift)), []), title('Real part of F_{shift}[I]');
subplot(224), imshow(log(imag(F_shift)), []), title('Imag part of F_{shift}[I]');
figure,
subplot(221), imshow(log(abs(F)), []), title('Magnitude of F[I]');
subplot(222), imshow(log(abs(F_shift)), []), title('Magnitude of F_{shift}[I]');
subplot(223), imshow(log(angle(F)), []), title('Phase of F[I]');
subplot(224), imshow(log(angle(F_shift)), []), title('Phase of F_{shift}[I]');

%% Question 1.b (Phase shift)
k = linspace(-im_size/2, im_size/2-1, im_size);
c_idx = ceil((im_size+1)/2);
center_F = F(:, c_idx);
center_Fshift = F_shift(:, c_idx);
F_phase = angle(center_F); Fshift_phase = angle(center_Fshift);
phase_diff = Fshift_phase - F_phase;
unwrapped = unwrap(phase_diff);
omega_k = 2*pi*k/im_size;

figure,
subplot(121), plot(omega_k, phase_diff);
xlabel('frequency'), ylabel('Phase difference'), title('Before unwrap');
subplot(122), plot(omega_k, unwrapped);
xlabel('frequency'), ylabel('Phase difference'), title('After unwrap');

k_arr = 0:im_size-1;
curr_pt = 40;
curr_diff = unwrapped(curr_pt, 1) / k_arr(1, curr_pt);
true_diff = pi/4;
disp([curr_diff, true_diff]);

%% Question 1.c (Shift correction)
k = 0:1:im_size-1;
phase_shift = exp(1j*(pi/4)*k).';
F_corrected = F_shift ./ phase_shift;
f_corrected = ifftshift(ifft2(ifftshift(F_corrected)));
figure,
subplot(121), imshow(f, []), title('Original image');
subplot(122), imshow(abs(f_corrected), []), title('Corrected image');

%% Question EXTRA-1.a (Bi-directional shifting)
im_size = 256;
f = zeros(im_size);
s_size = 32;  % signal size
padsize = (im_size-s_size)/2;
f(padsize+1:padsize+s_size, padsize+1:padsize+s_size) = 1;
F = fftshift(fft2(fftshift(f)));
f_shift = circshift(f, -32, 1);
f_shift = circshift(f_shift, 32, 2);
F_shift = fftshift(fft2(fftshift(f_shift)));
figure,
subplot(121), imshow(f, []), title('Original image');
subplot(122), imshow(f_shift, []), title('Shifted image');
figure,
subplot(221), imshow(log(real(F)), []), title('Real part of F[I]');
subplot(222), imshow(log(imag(F)), []), title('Imag part of F[I]');
subplot(223), imshow(log(real(F_shift)), []), title('Real part of F_{shift}[I]');
subplot(224), imshow(log(imag(F_shift)), []), title('Imag part of F_{shift}[I]');
figure,
subplot(221), imshow(log(abs(F)), []), title('Magnitude of F[I]');
subplot(222), imshow(log(abs(F_shift)), []), title('Magnitude of F_{shift}[I]');
subplot(223), imshow(log(angle(F)), []), title('Phase of F[I]');
subplot(224), imshow(log(angle(F_shift)), []), title('Phase of F_{shift}[I]');

%% Question EXTRA-1.b (Motion correction)
k = 0:1:im_size-1;
u_shift = exp(1j*(2*pi/im_size)*s_size*k).';  % 그냥 transpose하면 complex number의 conjugate 반환 -> element-wise computation 필요
v_shift = exp(-1j*(2*pi/im_size)*s_size*k);
shift_mtx = u_shift * v_shift;
Fu_corrected = F_shift ./ u_shift;
Fv_corrected = F_shift ./ v_shift;
F_corrected = F_shift ./ shift_mtx;
fx_corrected = ifftshift(ifft2(ifftshift(Fu_corrected)));
fy_corrected = ifftshift(ifft2(ifftshift(Fv_corrected)));
f_corrected = ifftshift(ifft2(ifftshift(F_corrected)));
figure,
subplot(221), imshow(f_shift, []), title('Shifted image');
subplot(222), imshow(abs(f_corrected), []), title('Corrected image');
subplot(223), imshow(abs(fx_corrected), []), title('X corrected image');
subplot(224), imshow(abs(fy_corrected), []), title('Y corrected image');

%% Question EXTRA-2.a (Shift with rotation)
I_rot = imrotate(f, 10, "bilinear");
I_rot_shift = imrotate(f_shift, 10, "bilinear");
I_merged = f + f_shift;
I_merged_rot = imrotate(I_merged, 10, "bilinear");

figure,
subplot(131), imshow(I_rot, []);
subplot(132), imshow(I_rot_shift, []);
subplot(133), imshow(I_merged_rot, []);

%% Question 2 (Load image)
load mri.mat
I = D(:, :, :, 15);
S = fftshift(fft2(fftshift(I)));
figure,
subplot(121), imshow(I, []), title('Raw image');
subplot(122), imshow(log(abs(S)), []), title('Freq. domain F[I]');

%% Question 2.a,b (Corrupted image)
im_size = size(I, 1);
S_center = S(im_size/2+1, im_size/2+1);  % S(0,0)
% Corrupted image
S2 = S;
S2(im_size/2-3, im_size/2+1) = S_center;  % S(0,4) = S(0,0)
S2(im_size/2+5, im_size/2+1) = S_center;  % S(0,-4) = S(0,0)
I2 = ifftshift(ifft2(ifftshift(S2)));
figure,
subplot(121), imshow(real(I), []), title('Real part of I');
subplot(122), imshow(real(I2), []), title('Real part of I_2');

%% Question 2.c,d,e (Image with LPF)
f_size = 32;  % Central region filter
padsize = (im_size-f_size)/2;  % Regions filled with 0
filter = zeros(im_size);
filter(padsize+1:padsize+f_size, padsize+1:padsize+f_size) = 1;
S3 = S .* filter;
I3 = ifftshift(ifft2(ifftshift(S3)));
figure,
subplot(121), imshow(I, []), title('Original image');
subplot(122), imshow(abs(I3), []), title('Image with LPF');

%% Question 2.f (Attenuating artifacts)
%%% 1) Zero-padding
S_padded = padarray(S, [128, 128], 0, 'both');
I_padded = ifftshift(ifft2(ifftshift(S_padded)));
figure,
subplot(121), imshow(abs(I3), []), title('Image with Ideal LPF');
subplot(122), imshow(abs(I_padded), []), title('Image with zero-padding');

%%% 2) Use Hamming window instead of Ideal LPF
hamm_kernel = hamming(f_size);
hamming_window = hamm_kernel * hamm_kernel';
hamming_window = padarray(hamming_window, [48,48], 0, 'both');
S_hamm = S3 .* hamming_window;
I_hamm = ifftshift(ifft2(ifftshift(S_hamm)));
figure,
subplot(121), imshow(abs(I3), []), title('Image with Ideal LPF');
subplot(122), imshow(abs(I_hamm), []), title('Image with Hamming window');

%%% 3) Use Gaussian filter instead of Ideal LPF
gauss_kernel = gausswin(f_size, 1);
gauss_window = gauss_kernel * gauss_kernel';
gauss_window = padarray(gauss_window, [48, 48], 0, 'both');
S_gauss = S3 .* gauss_window;
I_gauss = ifftshift(ifft2(ifftshift(S_gauss)));
figure,
subplot(121), imshow(abs(I3), []), title('Image with Ideal LPF');
subplot(122), imshow(abs(I_gauss), []), title('Image with Gaussian window');

%% Question 2.g,h (Reconstruction with undersampled image)
% (1) MRI Reconstruction by Completing Under-sampled K-space Data with Learnable Fourier Interpolation (MICCAI)
% (2) Undersampling patterns in k-space for compressed sensing MRI using two-dimensional Cartesian sampling
% (3) Global k-Space Interpolation for Dynamic MRI Reconstruction using Masked Image Modeling (MICCAI)

% Partial Fourier Imaging
S_partial = S;
S_partial(66:end, :) = 0;  % Fills bottom half with 0's
% Fill the zeros using "conjugate symmetry"
S_pair = flip(S_partial(2:64, 2:end), 2);
S_pair = flip(S_pair, 1);
S_pair = vertcat(zeros(64, 127), S_pair);
figure,
subplot(121), imshow(log(abs(S_partial)), []), title('Partial Spatial Image');
subplot(122), imshow(log(abs(S_pair)), []), title('Partial Conjugate Image');

S_filled = S_partial(2:end, 2:end) + S_pair;
S_filled = vertcat(S(1,2:end), S_filled);
S_filled = horzcat(S(:, 1), S_filled);

for m=66:128
    Re = real(S_filled(m, :));
    Im = imag(S_filled(m, :));
    S_filled(m, :) = Re - 1j*Im;
end

figure,
subplot(121), imshow(log(abs(S)), []), title('Original Freq. Image');
subplot(122), imshow(log(abs(S_filled)), []), title('Partial Fourier Freq. Image');
I_filled = ifftshift(ifft2(ifftshift(S_filled)));
figure,
subplot(121), imshow(I, []), title('Original Image');
subplot(122), imshow(abs(I_filled), []), title('Partial Fourier Image');

%% Parallel imaging