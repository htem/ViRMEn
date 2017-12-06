function code = Level5_Exp_AK_170510_TwoChoiceDelay
% White - Left Black - Right
% Note that all directions (RL) are from the code perspective
% Usually the mouse will see a flipped version, so the opposite
% Gradually increases delay length up to maximum

% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

vr.debugMode = false;
vr.verbose = true;
vr.mouseNum = 015;
vr.greyFac = 0.5; %goes from 0 to 1 to signify the amount of maze which is grey
vr.itiCorrect = 2;
vr.itiWrong = 4;
vr.breakFlag = 0;
vr.numRewPer = 1;
vr.armFac = 2; % pretty sure this never changes?

%initialize important cell information
% Note, these are pre-flip!
vr.conds = {'Black Left','Black Right','White Left','White Right'};

% initialization functions
vr = initializePath_AK(vr); % set up paths for output
vr = initTextboxes(vr); % live textboxes
vr = initDAQ_AK(vr); % NI-DAQ, session based
vr = initCounters_AK(vr);

% Define indices of walls
vr.LeftWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftWallBlack,:);
vr.RightWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightWallBlack,:);
vr.BackWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.BackWallBlack,:);
vr.RightArmWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightArmWallBlack,:);
vr.LeftArmWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftArmWallBlack,:);
vr.LeftEndWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftEndWallBlack,:);
vr.RightEndWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightEndWallBlack,:);
vr.TTopWallLeftBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopWallLeftBlack,:);
vr.TTopWallRightBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopWallRightBlack,:);
vr.LeftWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftWallWhite,:);
vr.RightWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightWallWhite,:);
vr.BackWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.BackWallWhite,:);
vr.RightArmWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightArmWallWhite,:);
vr.LeftArmWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftArmWallWhite,:);
vr.LeftEndWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftEndWallWhite,:);
vr.RightEndWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightEndWallWhite,:);
vr.TTopWallLeftWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopWallLeftWhite,:);
vr.TTopWallRightWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopWallRightWhite,:);
vr.LeftWallDelay = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftWallDelay,:);
vr.RightWallDelay = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightWallDelay,:);
vr.TTopMiddle = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopMiddle,:);
vr.blackLeftTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.blackLeftTower,:);
vr.blackRightTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.blackRightTower,:);
vr.whiteLeftTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.whiteLeftTower,:);
vr.whiteRightTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.whiteRightTower,:);
vr.greyLeftTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.greyLeftTower,:);
vr.greyRightTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.greyRightTower,:);

%Define groups for mazes
beginBlack = [vr.LeftWallBlack(1):vr.LeftWallBlack(2) vr.RightWallBlack(1):vr.RightWallBlack(2)];
beginWhite = [vr.LeftWallWhite(1):vr.LeftWallWhite(2) vr.RightWallWhite(1):vr.RightWallWhite(2)];
vr.whiteLeft = [vr.RightArmWallBlack(1):vr.RightArmWallBlack(2) vr.RightEndWallBlack(1):vr.RightEndWallBlack(2)...
    vr.TTopWallRightBlack(1):vr.TTopWallRightBlack(2) vr.LeftArmWallWhite(1):vr.LeftArmWallWhite(2)...
    vr.LeftEndWallWhite(1):vr.LeftEndWallWhite(2) vr.TTopWallLeftWhite(1):vr.TTopWallLeftWhite(2)];
vr.whiteRight = [vr.RightArmWallWhite(1):vr.RightArmWallWhite(2) vr.RightEndWallWhite(1):vr.RightEndWallWhite(2)...
    vr.TTopWallRightWhite(1):vr.TTopWallRightWhite(2) vr.LeftArmWallBlack(1):vr.LeftArmWallBlack(2)...
    vr.LeftEndWallBlack(1):vr.LeftEndWallBlack(2) vr.TTopWallLeftBlack(1):vr.TTopWallLeftBlack(2)];
vr.greyTowers = [vr.greyLeftTower(1):vr.greyLeftTower(2) vr.greyRightTower(1):vr.greyRightTower(2)];
vr.whiteRightTowers = [vr.whiteRightTower(1):vr.whiteRightTower(2) vr.blackLeftTower(1):vr.blackLeftTower(2)];
vr.whiteLeftTowers = [vr.whiteLeftTower(1):vr.whiteLeftTower(2) vr.blackRightTower(1):vr.blackRightTower(2)];
backBlack = vr.BackWallBlack(1):vr.BackWallBlack(2);
backWhite = vr.BackWallWhite(1):vr.BackWallWhite(2);
TTopMiddle = vr.TTopMiddle(1):vr.TTopMiddle(2);

vr.blackLeftOn = [beginBlack vr.whiteRight vr.greyTowers backBlack TTopMiddle];
vr.blackRightOn = [beginBlack vr.whiteLeft vr.greyTowers backBlack TTopMiddle];
vr.whiteLeftOn = [beginWhite vr.whiteLeft vr.greyTowers backWhite TTopMiddle];
vr.whiteRightOn = [beginWhite vr.whiteRight vr.greyTowers backWhite TTopMiddle];

% trial record
vr.numTrials = 1;
vr.trialRecord = struct('cueType',[],'mouseTurn',[],'success',[]);
vr.iterationNum = 0; % counts iterations of runtime code

     

%vr.cellWrite = 1; % write to cell as well
vr.STATE = 'INIT_TRIAL';

%--- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr.iterationNum = vr.iterationNum+1;

vr = checkManualReward(vr);
vr = updateTextDisplay_AK(vr);

% send synchronization pulses
if ~vr.debugMode
     %actualRate = vr.ao.Rate; %get sample rate
     %pulselength = round(actualRate*.002);% 2 ms pulse 
    if vr.iterationNum == 1
        outputSingleScan(vr.ao,[0 10]);
        %putsample(vr.aoCOUNT,10),
    elseif mod(vr.iterationNum,1e4)==0 %should be 1e4?
        outputSingleScan(vr.ao,[0 vr.iterationNum/1e5]);
        %putsample(vr.aoCOUNT,vr.iterationNum/1e5),
    else
        %putsample(vr.aoCOUNT,-1),
        outputSingleScan(vr.ao,[0 -1]);
    end
    outputSingleScan(vr.ao,[0 -5]);
end


% states: INIT_TRIAL -> TRIAL -> INIT_ITI-> ITI -> INIT_TRIAL

switch vr.STATE
    case 'INIT_TRIAL'
        
        vr.Cues=[2 3]; % This task has no matching, so only cues 2 and 3 are used
        % cues: 'Black Left','Black Right','White Left','White Right'
        vr.cuePos = randsample(vr.Cues,1);
        vr.trialRecord(vr.numTrials).cueType=vr.cuePos;
        vr.worlds{1}.surface.visible(:) = 0;
        switch vr.cuePos
            case 2
                vr.worlds{1}.surface.visible(vr.blackRightOn) = 1;
                vr.worlds{1}.surface.visible(vr.LeftWallBlack(1) + ceil((1-vr.greyFac)*(vr.LeftWallBlack(2)-vr.LeftWallBlack(1))):vr.LeftWallBlack(2)) = 0;
                vr.worlds{1}.surface.visible(vr.RightWallBlack(1) + ceil((1-vr.greyFac)*(vr.RightWallBlack(2)-vr.RightWallBlack(1))):vr.RightWallBlack(2)) = 0;
                vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil((1-vr.greyFac)*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(2)) = 1;
                vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil((1-vr.greyFac)*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(2)) = 1;
            case 3
                vr.worlds{1}.surface.visible(vr.whiteLeftOn) = 1;
                vr.worlds{1}.surface.visible(vr.LeftWallWhite(1) + ceil((1-vr.greyFac)*(vr.LeftWallWhite(2)-vr.LeftWallWhite(1))):vr.LeftWallWhite(2)) = 0;
                vr.worlds{1}.surface.visible(vr.RightWallWhite(1) + ceil((1-vr.greyFac)*(vr.RightWallWhite(2)-vr.RightWallWhite(1))):vr.RightWallWhite(2)) = 0;
                vr.worlds{1}.surface.visible(vr.LeftWallDelay(1) + ceil((1-vr.greyFac)*(vr.LeftWallDelay(2)-vr.LeftWallDelay(1))):vr.LeftWallDelay(2)) = 1;
                vr.worlds{1}.surface.visible(vr.RightWallDelay(1) + ceil((1-vr.greyFac)*(vr.RightWallDelay(2)-vr.RightWallDelay(1))):vr.RightWallDelay(2)) = 1;
            otherwise
                error('No World');
        end
        vr.position = vr.worlds{1}.startLocation;
        
        vr.dp = 0; %prevents movement
        vr.trialStartTime = rem(now,1);                
        vr.numTrials = vr.numTrials+1; %increment trial counters
        vr.trialStartClk = vr.iterationNum;
        vr.trialStart = tic;
        vr.STATE = 'TRIAL';
        if vr.verbose; disp('TRIAL state'); end;
        
    case 'TRIAL'
        % check for trial end condition: in arm of T
        if abs(vr.position(1)) > eval(vr.exper.variables.armLength)/vr.armFac            
            if vr.position(1) < 0 %left turn
                vr.trialRecord(vr.numTrials).mouseTurn='Left';
                if ismember(vr.cuePos,[1 3]) %correct L
                    if vr.verbose; disp('Correct Left Turn Detected'); end
                    vr.isReward = 1;                   
                    vr=giveReward_AK(vr,vr.numRewPer);
                elseif ismember(vr.cuePos,[2 4]) %incorrect L
                    vr.isReward = 0;
                    if vr.verbose; disp('Wrong Left Turn Detected'); end;
                else
                    disp('Cue Type Error!');
                end                
            elseif  vr.position(1) > 0 %R turn
                vr.trialRecord(vr.numTrials).mouseTurn='Right';
                if ismember(vr.cuePos,[1,3]) %incorrect R
                    vr.isReward=0;
                    if vr.verbose; disp('Wrong Right Turn Detected');end
                elseif ismember(vr.cuePos,[2 4]) %correct R
                    if vr.verbose; disp('Correct Right Turn Detected'); end;
                    vr.isReward=1;
                    vr=giveReward_AK(vr,vr.numRewPer);
                else
                    disp('Cue Type Error!');
                end                
            else % wrong turn
                disp('Position Error!');
            end
            vr.trialRecord(vr.numTrials).success=1;
            vr.trialLength = toc(vr.trialStart);
            vr.trialEndClk = vr.iterationNum;
            vr.STATE = 'INIT_ITI'; % signal trial end
            if vr.verbose; disp('INIT_ITI state'); end;
        else
            vr.isReward = 0;
        end
        
    case 'INIT_ITI'
        % Set iti time based on correct/incorrect
        if vr.isReward
            vr.itiDur = vr.itiCorrect;
        else
            vr.itiDur = vr.itiWrong;
        end
        
        % Save trial data
        if vr.verbose; disp('writing cell data'); end
        vr.frameRate = vr.trialLength/(vr.trialEndClk-vr.trialStartClk+1)*1000;
        dataStruct=struct('success',vr.isReward,'conds',vr.cuePos,...
            'greyFac',vr.greyFac,'trialStart',vr.trialStartClk,'trialEnd',vr.trialEndClk,...
            'trialLength',vr.trialLength,'FrameRate',vr.frameRate); 
        eval(['data',num2str(vr.numTrials),'=dataStruct;']);
        %save datastruct
        if exist(vr.pathTempMatCell,'file')
            save(vr.pathTempMatCell,['data',num2str(vr.numTrials)],'-append');
        else
            save(vr.pathTempMatCell,['data',num2str(vr.numTrials)]);
        end
        
        vr.isReward = 0; % turn off isReward flag (for GLM?)
        vr.inITI = 1;
        vr.worlds{1}.surface.visible(:) = 0;
        vr.itiStartTime = tic; % start ITI timer
        vr.STATE = 'ITI';
        if vr.verbose; disp('ITI state'); end
        
    case 'ITI'
        % ITI runcode
        vr.itiTime = toc(vr.itiStartTime);
      
        if vr.itiTime > vr.itiDur
            vr.STATE='INIT_TRIAL';
              if vr.verbose; disp(['ITI time:' num2str(vr.itiDur) ' sec']); end
            if vr.verbose; disp('INIT_TRIAL state'); end
            vr.inITI=0;
        end
        
    otherwise
        disp('state error!');
        return;
end

% write continuous data
fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI vr.greyFac vr.breakFlag],'float');


% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
if(vr.verbose); disp(['Session Ending: clk #' num2str(vr.iterationNum)]); end
commonTerminationVIRMEN(vr);