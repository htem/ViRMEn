% calibrateReward 
% ATK 180109

vr2 = struct;
vr2.debugMode = false;
% initialize NI-DAQ, session based
daqreset; %reset DAQ in case it's still in use by a previous Matlab program
vr2.ao = daq.createSession('ni');
% ao0 for reward delivery
vr2.ao.addAnalogOutputChannel('dev1','ao0','Voltage');
% ao1 for synchronizing pulses
vr2.ao.addAnalogOutputChannel('dev1','ao1','Voltage');
vr2.ao.Rate = 1e4;

for j = 1:250
    vr2 = giveReward_AK(vr2,1);   % dispense 250 rewards instead of 1 reward at longer duration.
end