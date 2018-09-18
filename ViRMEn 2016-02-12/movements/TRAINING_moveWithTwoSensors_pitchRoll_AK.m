function velocity = moveWithTwoSensors_pitchRoll_AK(vr)
%global mvData
global mvData
velocity = [0 0 0 0];

if isempty(mvData)
    return
end

% Access global mvData
% Teensy can send voltage between 0 and 3.3V, so that ~1.65 V 
% corresponds to no movement. This voltage needs calibration 
% because there is subtle fluctuations from day to day.
mvDataNorm = mvData - [1.698306, 1.698282, 1.696332]    ; 

% mvData
% 1: roll
% 2: pitch
% 3: yaw

% Update velocity

V = 0.33; % integral of voltage over one rotation of the ball

circum = 64; % circumference of the ball 
%calibrated AK 170308
%recalibrated AK 180816
%recalibrated AK 180905, sensors were not working well (pitch)
gain = .4; % basically a fudge factor


% 100 unit is defined as 75 cm
alpha = -100/75*gain*circum/V;
flip = 0; % set to 1 if the mirror flips right and left in Virmen 

%{
 % this works!
% use yaw and pitch only
beta = 0.01*circum/V;
velocity(1) = -alpha*mvDataNorm(2)*sin(vr.position(4));
velocity(2) = alpha*mvDataNorm(2)*cos(vr.position(4));
%}

%{ 
% use all 3
% beta = 0.01*circum/V;
% velocity(1) = -alpha*(mvDataNorm(2)*sin(vr.position(4))-mvDataNorm(1)*cos(vr.position(4)));
% velocity(2) = alpha*(mvDataNorm(2)*cos(vr.position(4))+mvDataNorm(1)*sin(vr.position(4)));
% 
% velocity(4) = beta*mvDataNorm(3);
% 
% if flip
%     velocity(4) = -beta*mvDataNorm(1);
% end
%}

% use roll and pitch only
% ATK calibrated 180816
rollgain = 1.8;
beta = 0.01*rollgain*circum/V;
velocity(1) = -alpha*mvDataNorm(2)*sin(vr.position(4));
velocity(2) = alpha*mvDataNorm(2)*cos(vr.position(4));
velocity(4) = beta*mvDataNorm(1);
if flip
    velocity(4) = -beta*mvDataNorm(1);
end

end