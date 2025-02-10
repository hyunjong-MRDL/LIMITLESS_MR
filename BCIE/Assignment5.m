%% Question 1
im = imread('HJ_headshot.jpg');
im = imcrop(im, [1,1,425,424]);
im = double(rgb2gray(im));  % Normalization 수행하기 위해 double로 변환
im = im/max(im(:));
im_size = max(size(im,1), size(im,2));

del_theta = 1;
theta = 0:del_theta:180-del_theta;

proj = zeros(im_size, length(theta));
for t=1:length(theta)
    proj(:,t) = sum(imrotate(im, -theta(t), 'bilinear', 'crop'), 1);
end
figure, imshow(proj, []); title('Sinogram');

recon_im = iradon(proj, theta, 'none', im_size);
mse = mean((recon_im(:)-im(:)).^2);
figure, imshow(recon_im, []); title(strcat('no filter; MSE = ', num2str(mse)));

recon_RamLak = iradon(proj, theta, 'Ram-Lak', im_size);
mse_RamLak = mean((recon_RamLak(:)-im(:)).^2);
figure, imshow(recon_RamLak, []); title(strcat('Ram-Lak filter; MSE = ', num2str(mse_RamLak)));

recon_Hann = iradon(proj, theta, 'Hann', im_size);
mse_Hann = mean((recon_Hann(:)-im(:)).^2);
figure, imshow(recon_Hann, []); title(strcat('Hann filter; MSE = ', num2str(mse_Hann)));