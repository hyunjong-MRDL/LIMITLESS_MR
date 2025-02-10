load("mri.mat");
vol = squeeze(D);
slice = vol(:, :, 13);
 
full_kspace = fftshift(fft2(slice));
under_kspace = zeros(length(full_kspace)/2, length(full_kspace));
for i=1:size(under_kspace, 1)
    under_kspace(i, :) = full_kspace(2*i-1, :);
end
under_slice = ifft2(ifftshift(under_kspace));

figure,
subplot(121), imagesc(abs(full_kspace));
subplot(122), imagesc(abs(under_kspace));

figure,
subplot(121), imagesc(slice);
subplot(122), imagesc(abs(under_slice));