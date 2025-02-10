function b_image = backprojection(proj, del_theta, filter)
%%% Filter name: ramlak/hann/none %%%
im_size = size(proj, 1);  % Padded_image size
theta = 0:del_theta:180-del_theta;

P = zeros(size(proj));  % P: Fourier transform of sinogram
p_filtered = zeros(size(proj));  % p: Filtered sinogram

freqs = linspace(-size(proj,1)/2, size(proj,1)/2, size(proj,1)).';
I_filter = ones(size(proj));  % Identity filter (None)
rl_filter = repmat(abs(freqs), [1 size(proj,2)]);
h_filter = repmat(hann(size(proj,1)), [1 size(proj,2)]);

b_image = zeros(im_size);  % b: backprojected image

for i=1:size(proj, 2)
    P(:, i) = fftshift(fft(proj(:, i)));
end

if strcmp(filter, "ramlak")
    P_filtered = P .* rl_filter;
elseif strcmp(filter, "hann")
    P_filtered = P .* rl_filter .* h_filter;
elseif strcmp(filter, "none")
    P_filtered = P .* I_filter;
else
    disp("Input error: Wrong filter name.");
end
figure,
subplot(121), imshow(abs(P),[]), title('P(k,\theta)');
subplot(122), imshow(abs(P_filtered),[]), title(['P(k,\theta) with', filter]);

for j=1:size(proj, 2)
    p_filtered(:, j) = real(ifft(ifftshift(P_filtered(:, j))));
end
figure, imshow(p_filtered, []), title(['p(r,\theta) with', filter]);

for t=1:length(theta)
    p_theta = p_filtered(:, t)' .* ones(im_size);  % Why transpose sinogram ?? (90 degrees rotation w/o transpose)
    pt_rot = my_rotate(p_theta, theta(t));
    pt_int = KNN_interpolation_4(pt_rot);
    b_image = b_image + pt_int;
end
figure, imshow(b_image, []), title(['b(x,y) with', filter]);
end