function code = Level2new_Exp_AK_180705
% White - Right Black - Left - New rig parameters
% Note that all directions (RL) are from the code perspective


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

vr.debugMode = true;
vr.verbose = true;
vr.mouseNum = 999;
vr.adjustmentFactor = 0.01;
vr.lengthFactor = 0.2;
vr.timeout = 20;
vr.itiCorrect = 2;
vr.itiWrong = 4;
vr.breakFlag = 0;
vr.numRewPer = 1;
vr.armFac = 2; % pretty sure this never changes?
vr.greyFac = 0.5; %this is hardcoded in the maze
%initialize important cell information
% Note, these are pre-flip!
vr.conds = {'White Right Tower Hint','Black Left Tower Hint'};

% initialization functions
vr = initializePath_AK(vr); % set up paths for output
vr = initTextboxes(vr); % live textboxes
vr = initDAQ_AK(vr); % NI-DAQ, session based
vr = initCounters_AK(vr);

vr.Cues = [1 2];

% trial record
vr.numTrials = 1;
vr.trialRecord = struct('cueType',[],'mouseTurn',[],'success',[]);
vr.iterationNum = 0; % counts iterations of runtime code

%vr.cellWrite = 1; % write to cell as well
vr.STATE = 'INIT_TRIAL';

% need to define this variable for first iteration
vr.trialTime = 0;

% world object handles
vr.mazeLength = eval(vr.exper.variables.mazeLength);
vr.wallLength = str2double(vr.exper.variables.wallLength);
%vr.minMazeLength = eval(vr.exper.variables.minMazeLength);  % default is 143.8317
%vr.minWallLength = eval(vr.exper.variables.wallLengthMin);  % default is 143.8317
vr.startLocation = vr.worlds{1}.startLocation;          % Specified in the world
vr.startLocationCurrent = vr.startLocation;

%--- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr.iterationNum = vr.iterationNum+1;

vr = checkManualReward(vr);
vr = updateTextDisplay_AK(vr);

% send synchronization pulses
if ~vr.debugMode
    if vr.iterationNum == 1
        outputSingleScan(vr.ao,[0 10]);
    elseif mod(vr.iterationNum,1e4)==0 %should be 1e4?
        outputSingleScan(vr.ao,[0 vr.iterationNum/1e5]);
    else
        outputSingleScan(vr.ao,[0 -1]);
    end
    outputSingleScan(vr.ao,[0 -5]);
end

% states: INIT_TRIAL -> TRIAL -> INIT_ITI-> ITI -> INIT_TRIAL

switch vr.STATE
    case 'INIT_TRIAL'
     
        vr.cuePos = randsample(vr.Cues,1);
        vr.currentWorld = vr.cuePos;

        disp([string('cueType = ') + num2str(vr.cuePos)]);
        vr.trialRecord(vr.numTrials).cueType=vr.cuePos;
        
     
        vr.worlds{vr.cuePos}.surface.visible(:) = 1;
        vr.position = vr.worlds{vr.cuePos}.startLocation;
       
        vr.dp = 0; %prevents movement
        vr.trialStartTime = rem(now,1);                
        vr.numTrials = vr.numTrials+1; %increment trial counters
        vr.trialStartClk = vr.iterationNum;
        vr.trialStart = tic;
        vr.STATE = 'TRIAL';
        if vr.verbose; disp('TRIAL state'); end
                
        % if mouse completed in less than 20 sec, make the map longer
        % otherwise make it shorter
        if vr.trialTime < vr.timeout
            vr.lengthFactor = vr.lengthFactor + vr.adjustmentFactor;
        else
            vr.lengthFactor = vr.lengthFactor - vr.adjustmentFactor;
        end
        
        % but always within bounds
        if vr.lengthFactor > 1
            vr.lengthFactor = 1;
        elseif vr.lengthFactor < 0
            vr.lengthFactor = 0;
        end
        
        disp(['vr.lengthFactor = ' num2str(vr.lengthFactor)]);
        % set up world
        
        vr.startLocationCurrent(2) = vr.mazeLength - (vr.mazeLength * vr.lengthFactor);
        
        % ATK - not happy with this, but a quick fix isn't easy
        %length_temp = vr.minWallLength + (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
        %vr.startLocationCurrent(2) = vr.startLocation(2) - length_temp;
        %vr.exper.variables.wallLengthMin = num2str(length_temp); %this actually changes the back wall
        % note that vr.minWallLength is always 40, even though the
        % exper var changes
        
        %vr.worlds{1} = loadVirmenWorld(vr.exper.worlds{1});
        %vr.worlds{1}.surface.visible(:) = 0;
        vr.position = vr.startLocationCurrent;  % teleports the mouse
        %disp(['vr.startLocation = ' num2str(vr.position)]);
        vr.dp = 0;
        %vr.worlds{1}.surface.visible(:) = 1;
        
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
                if ismember(vr.cuePos,[2]) %correct Left
                    if vr.verbose; disp('Correct Left Turn Detected'); end
                    vr.isReward = 1;                   
                    vr=giveReward_AK(vr,vr.numRewPer);
                elseif ismember(vr.cuePos,[1]) %incorrect Left
                    vr.isReward = 0;
                    if vr.verbose; disp('Wrong Left Turn Detected'); end;
                else
                    disp('Cue Type Error!');
                end                
            elseif  vr.position(1) > 0 %Right turn
                vr.trialRecord(vr.numTrials).mouseTurn='Right';
                if ismember(vr.cuePos,[2]) %incorrect Right
                    vr.isReward=0;
                    if vr.verbose; disp('Wrong Right Turn Detected');end
                elseif ismember(vr.cuePos,[1]) %correct Right
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
            vr.trialTime = toc(vr.trialStart);
            vr.STATE = 'INIT_ITI'; % signal trial end
            if vr.verbose; disp('INIT_ITI state'); end;
            
        elseif toc(vr.trialStart) > vr.timeout
            vr.numTrials = vr.numTrials + 1;
            vr.trialTime = vr.timeout;
            vr.success = 0;
            vr.STATE = 'INIT_ITI';
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
        vr.worlds{vr.cuePos}.surface.visible(:) = 0; %do we need this?
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