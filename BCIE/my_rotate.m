function rotated_image = my_rotate(image, theta)
[x_size, y_size] = size(image);
rotated_image = zeros(x_size, y_size);
x0 = x_size/2; y0 = y_size/2;

radian = deg2rad(theta);
R_matrix = [cos(radian) -sin(radian); sin(radian) cos(radian)];

for i=1:x_size
    for j=1:y_size
        curr_pixel = image(i,j);
        rotated_pos = int64((R_matrix*[i-x0; j-y0]+ [x0; y0]));
        x_r = rotated_pos(1); y_r = rotated_pos(2);
        if x_r > 0 && y_r > 0 && x_r < x_size+1 && y_r < y_size+1
            rotated_image(x_r, y_r) = curr_pixel;
        end
    end
end
end