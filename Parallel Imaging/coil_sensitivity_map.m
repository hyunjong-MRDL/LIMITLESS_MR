sens_map = zeros(128);
filter = gausswin(64)*gausswin(128)';

sens_map(65:end, :) = filter;

freq_map = fftshift(fft2(sens_map));

subplot(121), imshow(sens_map);
subplot(122), imshow(abs(freq_map));
colormap(hot);