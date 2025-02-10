function im_inter = KNN_interpolation_4(image)
x_size = size(image, 1);
y_size = size(image, 2);

int_arr = find(image == 0);  % Interpolation array
im_inter = image;

for i = 1:size(int_arr, 1)  % Interpolation array 길이만큼 반복
    int_idx = int_arr(i);  % Interpolation이 필요한 인덱스 (1D)
    x_inter = mod(int_idx-1, x_size) + 1;
    y_inter = (int_idx - x_inter)/x_size + 1;
    
    if x_inter == 1 || y_inter == 1 || x_inter == x_size || y_inter == y_size
        continue
    else
    im_inter(x_inter, y_inter) = ...
        (im_inter(x_inter-1,y_inter)+...
        im_inter(x_inter,y_inter-1)+...
        im_inter(x_inter,y_inter+1)+...
        im_inter(x_inter+1,y_inter)...
        )/4;
    end
end