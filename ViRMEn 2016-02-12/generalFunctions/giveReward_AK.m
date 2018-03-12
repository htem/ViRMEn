function [vr] = giveReward_AK(vr,nRew)
%giveReward Function which delivers rewards using the Master-8 system
%(instantaneous pulses)
%   nRew - number of rewards to deliver

sinDur = .064; %Calibrated every day to give 1 mL for 250 rewards
% equiv to 4 uL each.

disp(['Reward Given at ' datestr(now, 'HH:MM:SS')]);

if ~vr.debugMode
    wait(vr.ao,1);
    actualRate = vr.ao.Rate; %get sample rate
    pulselength=round(actualRate*sinDur*nRew); %find duration (rate*duration in seconds *numRew)
    pulsedata=5.0*ones(pulselength,1); %5V amplitude
    pulsedata(pulselength)=0; %reset to 0V at last time point
    vr.ao.queueOutputData([pulsedata repmat(-1,length(pulsedata),1)]);
    startForeground(vr.ao);
end

vr.isReward = nRew;

end

