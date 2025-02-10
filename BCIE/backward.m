function rotated_image = backward(input_image, angle_degrees)
    % Convert the angle to radians
    angle_radians = deg2rad(angle_degrees);

    % Get the dimensions of the input image
    [height, width, num_channels] = size(input_image);

    % Calculate the center of the image
    center_x = width / 2;
    center_y = height / 2;

    % Create an empty output image
    rotated_image = zeros(size(input_image), 'like', input_image);

    % Calculate the cosine and sine of the angle
    cos_theta = cos(angle_radians);
    sin_theta = sin(angle_radians);

    % Iterate over each pixel in the output image
    for x_prime = 1:width
        for y_prime = 1:height
            % Calculate the coordinates in the input image
            x = cos_theta * (x_prime - center_x) + sin_theta * (y_prime - center_y) + center_x;
            y = -sin_theta * (x_prime - center_x) + cos_theta * (y_prime - center_y) + center_y;

            % Check if the coordinates are within the input image bounds
            if x >= 1 && x <= width && y >= 1 && y <= height
                % Use bilinear interpolation to sample the input image
                x_floor = floor(x);
                y_floor = floor(y);
                x_ceil = min(x_floor + 1, width);
                y_ceil = min(y_floor + 1, height);

                if num_channels == 1
                    % Grayscale image
                    top_left = double(input_image(y_floor, x_floor));
                    top_right = double(input_image(y_floor, x_ceil));
                    bottom_left = double(input_image(y_ceil, x_floor));
                    bottom_right = double(input_image(y_ceil, x_ceil));
                else
                    % Color image
                    top_left = double(squeeze(input_image(y_floor, x_floor, :)));
                    top_right = double(squeeze(input_image(y_floor, x_ceil, :)));
                    bottom_left = double(squeeze(input_image(y_ceil, x_floor, :)));
                    bottom_right = double(squeeze(input_image(y_ceil, x_ceil, :)));
                end

                x_weight = x - x_floor;
                y_weight = y - y_floor;

                top = (1 - x_weight) * top_left + x_weight * top_right;
                bottom = (1 - x_weight) * bottom_left + x_weight * bottom_right;
                pixel_value = (1 - y_weight) * top + y_weight * bottom;

                rotated_image(y_prime, x_prime, :) = pixel_value;
            end
        end
    end
end