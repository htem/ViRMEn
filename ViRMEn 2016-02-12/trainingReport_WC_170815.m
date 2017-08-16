
clear a;
a = struct2cell(dataCell);

towerTrials = 0;
noTowerTrials = 0;
rewardsTower = 0;
rewardsNoTower = 0;
leftTrials = 0;
rewardsLeft = 0;
rightTrials = 0;
rewardsRight = 0;
rewardRec = zeros(length(a)-1,1);
rewardsAll = 0;

if isfield(a{2},'Tower')
    for i = 1:length(a)-1 % first entry is conds (should fix)
        trial=cell2mat(a(i+1));
        if trial.Tower
            towerTrials = towerTrials+1;
            if trial.success
                rewardsTower = rewardsTower+1;
                rewardsAll = rewardsAll+1;
                rewardRec(i) = 1;
            end
        else
            noTowerTrials = noTowerTrials+1;
            if trial.success
                rewardsNoTower = rewardsNoTower+1;
                rewardsAll = rewardsAll+1;
                rewardRec(i) = 1;
            end
        end
         if trial.conds == 3 || trial.conds == 4 %left? could be opposite
            leftTrials = leftTrials+1;
            if trial.success
                rewardsLeft = rewardsLeft+1;
                rewardsAll = rewardsAll+1;
                rewardRec(i) = 1;
            end
        else
            rightTrials = rightTrials+1;
            if trial.success
                rewardsRight = rewardsRight+1;
                rewardsAll = rewardsAll+1;
                rewardRec(i) = 1;
            end
        end
    end
    numTrials = length(a)-1;
    rewardsAll = rewardsTower+rewardsNoTower;
    disp([num2str(rewardsAll) '/'  num2str(numTrials)]);
    disp(['Tower Percentage:' num2str(rewardsTower/towerTrials)]);
    disp(['No Tower Percentage:' num2str(rewardsNoTower/noTowerTrials)]);
    disp(['Left:' num2str(rewardsLeft) '/' num2str(leftTrials)]);
    disp(['Right:' num2str(rewardsRight) '/' num2str(rightTrials)]);
    disp(['Overall:' num2str(rewardsAll/numTrials)]);
else 
     for i = 1:length(a)-1 % first entry is conds (should fix)
        trial=cell2mat(a(i+1));
        if isfield(trial, 'conds')
            if trial.conds == 2  %black right = left for mouse
                leftTrials = leftTrials+1;
                if trial.success
                    rewardsLeft = rewardsLeft+1;
                    rewardsAll = rewardsAll+1;
                    rewardRec(i) = 1;
                end
            else
                rightTrials = rightTrials+1;
                if trial.success
                    rewardsRight = rewardsRight+1;
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
    disp([num2str(rewardsAll) '/'  num2str(numTrials)]);
    disp(['Left:' num2str(rewardsLeft) '/' num2str(leftTrials)]);
    disp(['Right:' num2str(rewardsRight) '/' num2str(rightTrials)]);
    disp(['Overall:' num2str(rewardsAll/numTrials)]);
end

cumRewards = cumsum(rewardRec);
trialDummy = 1:length(a)-1;
figure; plot(trialDummy,cumRewards,'b',trialDummy,trialDummy/2,'r--');
axis square; 