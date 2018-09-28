function code = Level2new_Exp_AK_180705_mod

% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

%%%%% These variables should be checked each run %%%%%
vr.debugMode = false;
vr.verbose = true;
vr.mouseNum = 033;
vr.adjustmentFactor = 0.01;
vr.initialLengthFactor = 0.25;
%%%%%%%%%%%

vr.timeout = 30;
vr.itiCorrect = 1;
vr.itiWrong = 4;
vr.numRewPer = 1;
vr.armFac = 2; % pretty sure this never changes?

% define possible cue values
vr.Cues = [1 2];
vr.conds = {'White Right Tower Hint','Black Left Tower Hint'};

% initialization functions
vr = initializePath_AK(vr); % set up paths for output
vr = initTextboxes(vr); % live textboxes
vr = initDAQ_AK(vr); % NI-DAQ, session based
vr = initCounters_AK(vr);

% trial record
vr.numTrials = 1;
vr.trialRecord = struct('cueType',[],'mouseTurn',[],'success',[]);
vr.iterationNum = 0; % counts iterations of runtime code
vr.success = 0;
vr.trialTime = 0;
%vr.cellWrite = 1; % write to cell as well
vr.STATE = 'INIT_TRIAL';

% world object handles
vr.mazeLength = eval(vr.exper.variables.mazeLength);
vr.wallLength = str2double(vr.exper.variables.wallLength);
vr.startLocationCurrent = vr.worlds{1}.startLocation; % Specified in the world
vr.lengthFactor = vr.initialLengthFactor;

%--- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr.iterationNum = vr.iterationNum+1;

vr = checkManualReward(vr);
vr = updateTextDisplay_AK(vr);

% states: INIT_TRIAL -> TRIAL -> INIT_ITI-> ITI -> INIT_TRIAL

switch vr.STATE
    case 'INIT_TRIAL'    
        %  if previous trial correct and fast, make the map longer
        % otherwise make it shorter
        if vr.trialTime < vr.timeout % && vr.success == 1
        % atk 180725 dont want maze to get shorter if he gets wrong
            vr.lengthFactor = vr.lengthFactor + vr.adjustmentFactor;
        else
            vr.lengthFactor = vr.lengthFactor - vr.adjustmentFactor;
        end
        % but always within bounds
        if vr.lengthFactor > 1
            vr.lengthFactor = 1;
        elseif vr.lengthFactor < vr.initialLengthFactor
            vr.lengthFactor = vr.initialLengthFactor;
        end
        
        if vr.verbose 
            disp(['vr.lengthFactor = ' num2str(vr.lengthFactor)]);
        end
         
        % Choose cue for next trial
        vr.cuePos = randsample(vr.Cues,1);
        vr.currentWorld = vr.cuePos;

        if vr.verbose; disp([string('cueType = ') + num2str(vr.cuePos)]); end
        vr.trialRecord(vr.numTrials).cueType=vr.cuePos;

        % Set up world
        vr.currentLength = vr.mazeLength * vr.lengthFactor;
        vr.startLocationCurrent(2) = vr.mazeLength - vr.currentLength;
        vr.position = vr.startLocationCurrent;  % teleports the mouse
        vr.worlds{vr.cuePos}.surface.visible(:) = 1;
        vr.dp = 0;
        
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
                    vr.success = 1;                   
                    vr=giveReward_AK(vr,vr.numRewPer);
                elseif ismember(vr.cuePos,[1]) %incorrect Left
                    vr.success = 0;
                    if vr.verbose; disp('Wrong Left Turn Detected'); end;
                else
                    disp('Cue Type Error!');
                end                
            elseif  vr.position(1) > 0 %Right turn
                vr.trialRecord(vr.numTrials).mouseTurn='Right';
                if ismember(vr.cuePos,[2]) %incorrect Right
                    vr.success=0;
                    if vr.verbose; disp('Wrong Right Turn Detected');end
                elseif ismember(vr.cuePos,[1]) %correct Right
                    if vr.verbose; disp('Correct Right Turn Detected'); end;
                    vr.success=1;
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
            vr.trialLength = toc(vr.trialStart);
            vr.trialTime = vr.timeout;
            vr.success = 0;
            vr.STATE = 'INIT_ITI';
        else
            vr.success = 0;
        end
        
    case 'INIT_ITI'
        % Set iti time based on correct/incorrect
        if vr.success
            vr.itiDur = vr.itiCorrect;
        else
            vr.itiDur = vr.itiWrong;
        end
        
        % Save trial data
        if vr.verbose; disp('writing cell data'); end
        vr.frameRate = vr.trialLength/(vr.trialEndClk-vr.trialStartClk+1)*1000;
        dataStruct=struct('success',vr.success,'conds',vr.cuePos,...
            'trialStart',vr.trialStartClk,'trialEnd',vr.trialEndClk,...
            'trialLength',vr.trialLength,'FrameRate',vr.frameRate,...
            'mazeLength',vr.currentLength); 
        eval(['data',num2str(vr.numTrials),'=dataStruct;']);
        %save datastruct
        if exist(vr.pathTempMatCell,'file')
            save(vr.pathTempMatCell,['data',num2str(vr.numTrials)],'-append');
        else
            save(vr.pathTempMatCell,['data',num2str(vr.numTrials)]);
        end
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

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
if(vr.verbose); disp(['Session Ending: clk #' num2str(vr.iterationNum)]); end
commonTerminationVIRMEN(vr);