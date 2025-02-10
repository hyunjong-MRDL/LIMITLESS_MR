% Parameters
r1 = 3; % Radius of first circle
r2 = 3; % Radius of second circle
omega = 2 * pi; % Angular velocity
t = linspace(0, 2*pi, 1000); % Time vector

% Circle 1 (counterclockwise)
x1 = r1 * cos(omega * t);
y1 = r1 * sin(omega * t);

% Circle 2 (clockwise)
x2 = r2 * cos(omega * t);
y2 = -r2 * sin(omega * t);

% Resulting motion
x = x1 + x2;
y = y1 + y2;

% Plot
figure;
plot(x, y, 'b', 'LineWidth', 2); hold on;
plot(x1, y1, 'r--', 'LineWidth', 1); % Circle 1
plot(x2, y2, 'g--', 'LineWidth', 1); % Circle 2
legend('Ellipse', 'Circle 1', 'Circle 2');
axis equal;
grid on;
title('Summation of Two Rotating Circles Forming an Ellipse');
xlabel('X-axis');
ylabel('Y-axis');