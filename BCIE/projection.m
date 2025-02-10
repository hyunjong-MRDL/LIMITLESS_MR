function proj_im = projection(padded_im, del_theta)  % Forward projection
theta = 0:del_theta:180-del_theta;
proj_im = zeros(size(padded_im, 1), length(theta));

for t=1:length(theta)
    im_rot = my_rotate(padded_im, -theta(t));
    im_int = KNN_interpolation_4(im_rot);
    proj_im(:,t) = sum(im_int, 1);
end
figure, imshow(abs(proj_im), []); title('Sinogram');