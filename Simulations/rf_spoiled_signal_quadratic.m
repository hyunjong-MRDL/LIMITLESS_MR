% RF_spoiled signal
% Step 1 : Multiple spin case / with simple spoiling assumption
% Ideal SSI
% Spin Phase Cycling + Spin Frequency Distribution

clear; clc; close all;
% M : single isochromat

M0 = 1;
N_rf = 200; % Number of RF pulses (including excitation pulse)
M_i = [0;0;M0]; % Initial magnetization
del_t = 15; % TR[ms]
T1 = 600; T2 = 100;
FA = pi*0.2;% FA : 36deg
phi = pi*0; theta = pi*0.5; % pulses are applied along x-axis

% Multiple case
Mf = 1000/del_t; % max frequency : after TR --> 2pi
N_spin = 100;
dfs = 0:Mf/(N_spin):(Mf-Mf/N_spin); % Instead of f

zexp = exp(1i*dfs*2*pi);
zs = sum(zexp,2);


% Rf Phase Cycling Angle
    
cycle_angle_deg = zeros(180,N_rf);

for a = 1:1:360

    for b = 1:1:N_rf

        phi = 0.5*a*((b-1)^2+(b-1)+2);
        cycle_angle_deg(a,b) = mod(phi,360);

    end

end

cycle_angle_rad = (cycle_angle_deg/180)*pi;



% Excitation & Free precession



% SI = zeros(N_spin, N_rf);
M = zeros(N_spin, N_rf, 3);
% RFrep = 1:1:N_rf;

spoiled_SI = zeros(1, 180);% Defining Parameter

for k = 1:1:180 % RF Phase Cycling degree 1deg -> 180deg 반복

    for b = 1:1:N_spin
    
        M_fp = M_i; % Defining Parameter
        for a = 1:1:N_rf
           
            M_fl = RF_excite(FA, cycle_angle_rad(k,a), theta)*M_fp;
            M_sam = fp(M_fl(1), M_fl(2), M_fl(3), del_t, T1, T2, dfs(b), M0);
            M_fp = fp(M_fl(1), M_fl(2), M_fl(3), del_t, T1, T2, dfs(b), M0);
            % problem
            M(b,a,1) = M_sam(1);
            M(b,a,2) = M_sam(2);
            M(b,a,3) = M_sam(3);
            
            % About the result...
            % Right after each RF excitations, all spins are coherenced.
        
        end
    
    end

    M_total = mean(M, 1);
    M_total_SS = M_total(1,N_rf,:);
    spoiled_SI(1,k) = sqrt(M_total_SS(1,1,1)^2 + M_total_SS(1,1,2)^2);

    spoiled_Mz(k) = M_total_SS(1,1,3);

end


% Plotting

angle = 1:1:180;

reference = zeros(1,180);
for j = 1:1:180

    reference(j) = 0.0688;
    % 0.0688 : signal level of single spin with spoiling assumption

end


subplot(1,1,1);
% plot(angle, spoiled_SI); grid on
plot(angle, spoiled_Mz); grid on
hold on
plot(angle, reference);
xlabel('angle (in degrees)')


