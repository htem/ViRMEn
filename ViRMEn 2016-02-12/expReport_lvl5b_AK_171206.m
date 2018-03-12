% Continuous data is
% fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI vr.greyFac vr.breakFlag],'float');
% Row 1: Current time as serial time number (fraction of day)
% Row 2,3: X and Y position
% Row 4: Heading direction
% Row 5,6: X and Y Velocity
% Row 7: Cue Type (2 is Black Right, 3 is White Left)
% Row 8: Reward Flag (
clear a;
a = struct2cell(dataCell);


towerTrials = 0;
noTowerTrials = 0;
rewardsTower = 0;
rewardsNoTower = 0;
leftDotTrials = 0;
rewardsLeftDot = 0;
rewardsLeftGrating = 0;
rightDotTrials = 0;
leftGratingTrials = 0;
rightGratingTrials = 0;
rewardsRightDot = 0;
rewardsRightGrating = 0;
rewardRec = zeros(length(a)-1,1);
rewardsAll = 0;

for i = 1:length(a)-1 % first entry is conds (should fix)
    trial=cell2mat(a(i+1));
    if isfield(trial, 'conds')
        switch(trial.conds)
            case 1
                leftDotTrials = leftDotTrials+1;
                if trial.success
                    rewardsLeftDot = rewardsLeftDot+1;
                    rewardsAll = rewardsAll+1;
                    rewardRec(i) = 1;
                end
            case 2
                rightDotTrials = rightDotTrials+1;
                if trial.success
                    rewardsRightDot = rewardsRightDot+1;
                    rewardsAll = rewardsAll+1;
                    rewardRec(i) = 1;
                end
                
            case 3
                leftGratingTrials = leftGratingTrials+1;
                if trial.success
                    rewardsLeftGrating = rewardsLeftGrating+1;
                    rewardsAll = rewardsAll+1;
                    rewardRec(i) = 1;
                end
            case 4
                rightGratingTrials = rightGratingTrials+1;
                if trial.success
                    rewardsRightGrating = rewardsRightGrating+1;
                    rewardsAll = rewardsAll+1;
                    rewardRec(i) = 1;
                end
        end
    else
        if trial.success
            rewardsAll = rewardsAll+1;
            rewardRec(i) = 1;
        end
    end
end
numTrials = length(a)-1;

disp(['Dot:' num2str((rewardsLeftDot+rewardsRightDot)/(leftDotTrials+rightDotTrials))]);
disp(['Grating:' num2str((rewardsLeftGrating+rewardsRightGrating)/(leftGratingTrials+rightGratingTrials))]);

disp(['Overall: ' num2str(rewardsAll) '/'  num2str(numTrials) '  ' num2str(rewardsAll/numTrials)]);
disp(['Left Dot:' num2str(rewardsLeftDot) '/' num2str(leftDotTrials)]);
disp(['Right Dot:' num2str(rewardsRightDot) '/' num2str(rightDotTrials)]);
disp(['Left Grating:' num2str(rewardsLeftGrating) '/' num2str(leftGratingTrials)]);
disp(['Right Grating:' num2str(rewardsRightGrating) '/' num2str(rightGratingTrials)]);


cumRewards = cumsum(rewardRec);
trialDummy = 1:length(a)-1;
figure; plot(trialDummy,cumRewards,'b',trialDummy,trialDummy/2,'r--');
axis square; grid on;