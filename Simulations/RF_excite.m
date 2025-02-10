% Excitation by RF Pulse (applied in arbitrary direction with arbitrary FA)

% Input : angles
% Output : Rotational Matrix

% alpha : FA
% phi : angle measured on transverse plane (about x-axis)
% theta : angle measured from z-axis

function R = RF_excite(alpha, phi, theta)
Rz=[cos(phi) sin(phi) 0 ; -sin(phi) cos(phi) 0 ; 0 0 1];
Rzr=[cos(phi) -sin(phi) 0 ; sin(phi) cos(phi) 0 ; 0 0 1];
Ry=[cos(pi*0.5-theta) 0 -sin(pi*0.5-theta) ; 0 1 0 ; sin(pi*0.5-theta) 0 cos(pi*0.5-theta)];
Ryr=[cos(pi*0.5-theta) 0 sin(pi*0.5-theta) ; 0 1 0 ; -sin(pi*0.5-theta) 0 cos(pi*0.5-theta)];
Rx=[1 0 0 ; 0 cos(alpha) sin(alpha) ; 0 -sin(alpha) cos(alpha)];
R = Rz*Ry*Rx*Ryr*Rzr;
end