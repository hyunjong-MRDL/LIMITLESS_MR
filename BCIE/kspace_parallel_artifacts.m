%% Individual effect of shifting (x-direction OR y-direction)
im_size = 64;
im = zeros(im_size);
c_idx = ceil((im_size+1)/2);

dist = 4;

impulse = im;
impulse(c_idx, c_idx) = 1;
I = fftshift(fft2(fftshift(impulse)));
figure,
subplot(121), imshow(impulse);
subplot(122), imshow(I);

impulse_vert = im;
impulse_vert(c_idx-dist, c_idx) = 1;
% impulse_vert(c_idx+dist, c_idx) = 1;

impulse_horz = im;
% impulse_horz(c_idx, c_idx-dist) = 1;
impulse_horz(c_idx, c_idx+dist) = 1;

I_vert = fftshift(fft2(fftshift(impulse_vert)));
I_horz = fftshift(fft2(fftshift(impulse_horz)));

figure,
subplot(121), imshow(real(I_vert));
subplot(122), imshow(real(I_horz));

%% Combined effects of shifting (x & y direction)
im_size = 64;
im = zeros(im_size);
c_idx = ceil((im_size+1)/2);

dist = 4;

impulse_45 = im;  % Phase: +45
impulse_45(c_idx-dist, c_idx+dist) = 1;

impulse_135 = im;  % Phase: +135
impulse_135(c_idx-dist, c_idx-dist) = 1;

impulse_225 = im;  % Phase: +225
impulse_225(c_idx+dist, c_idx-dist) = 1;

impulse_315 = im;  % Phase: +315
impulse_315(c_idx+dist, c_idx+dist) = 1;

I_45 = fftshift(fft2(fftshift(impulse_45)));
I_135 = fftshift(fft2(fftshift(impulse_135)));
I_225 = fftshift(fft2(fftshift(impulse_225)));
I_315 = fftshift(fft2(fftshift(impulse_315)));

figure,
subplot(221), imshow(real(I_45));
subplot(222), imshow(real(I_135));
subplot(223), imshow(real(I_225));
subplot(224), imshow(real(I_315));

%% Why combined artifacts are also a straight line?
I_vert_horz = I_vert .* I_horz;
figure,
subplot(121), imshow(real(I_45));
subplot(122), imshow(real(I_vert_horz));
%%% Considering real parts:
%%% Re[F'(u,v)] = cos(2pi(shift/M)(u+v))
%%% In the direction of (u+v) vector,
%%% when the magnitude of the vector equals (M/shift),
%%% the frequency domain signal goes through ONE cycle.
%%% Hence, the total cycle would be:
%%% [sqrt(2)*M]/[M/4] = 4*srqt(2)