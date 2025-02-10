% Result of Free precession & Relaxation

% Input : del_t, T1, T2, M0, f
    % del_t : Time interval [ms]
    % T1 [ms], T2 [ms]
    % M0 : Longitudinal magnetization at thermal equilibrium
    % f : Resonance frequency [Hz = 1/s]
    % Mx0, My0, Mz0

% Output : result of free precession

    % Output : Afp, Bfp
        % Afp : 3x3 matrix
        % Bfp : 3x1 matrix 

% Other Parameters : phi [rad]

function M_f = fp(Mxi, Myi, Mzi, del_t,T1,T2,f,M0)

% phi : Total phase shift [rad]
% 2*pi*f : angular frequency
phi=2*pi*f*del_t*(1/1000); % 1/1000 : for [ms] --> [s] conversion

Afp = [cos(phi)*exp(-del_t/T2) sin(phi)*exp(-del_t/T2) 0 ; 
    -sin(phi)*exp(-del_t/T2) cos(phi)*exp(-del_t/T2) 0 ; 
    0 0 exp(-del_t/T1)];

% [t/t] --> [ms] --> [s] conversion is unnecessary

Bfp = [0 ; 0 ; M0*(1-exp(-del_t/T1))];

M_i = [Mxi;Myi;Mzi];

M_f = Afp*M_i + Bfp;

end