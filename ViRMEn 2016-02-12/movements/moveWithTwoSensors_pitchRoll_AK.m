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
mvDataNorm = mvData - [1.685765, 1.685596, 1.683304]    ; 

% mvData
% 1: roll
% 2: pitch
% 3: yaw

% Update velocity

V = 0.33; % integral of voltage over one rotation of the ball

circum = 64; % circumference of the ball 
%calibrated AK 170308
gain = .45; % basically a fudge factor
% 100 unit is defined as 75 cm
alpha = -100/75*gain*circum/V;
flip = 1; % set to 1 if the mirror flips right and left in Virmen 

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
beta = 0.01*circum/V;
velocity(1) = -alpha*mvDataNorm(2)*sin(vr.position(4));
velocity(2) = alpha*mvDataNorm(2)*cos(vr.position(4));
velocity(4) = beta*mvDataNorm(1);
if flip
    velocity(4) = -beta*mvDataNorm(1);
end

end