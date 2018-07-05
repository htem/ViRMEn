function code = SAK_tExtending
%T-maze with extending length, error block mouse at start position

% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

% set parameters
vr.debugMode = true;
vr.mouseNum = 999;
vr.adjustmentFactor = 0.01;
vr.lengthFactor = 0;
vr.trialTimeout = 120;
vr.itiDur = 2;  % increased itiDur from 1 to 3 to discourage initial running of mice at start
vr.friction = 0.3; % define friction that will reduce velocity by 70% during collisions

% experimental condition labeel
vr.conds = {'tExtending'};

% initialization funcions
vr = initializePath_AK(vr); % set up paths for output
vr = initTextboxes(vr); % live textboxes
vr = initDAQ_AK(vr); % NI-DAQ, session based
vr = initCounters_AK(vr); 

% Initialize world object handles
vr.adjustmentFactor = 0.01;
vr.wallLength = str2double(vr.exper.variables.wallLength);
vr.minWallLength = eval(vr.exper.variables.wallLengthMin);  % default is 143.8317
vr.lengthFactor = 0;
vr.startLocation = vr.worlds{1}.startLocation;          % Specified in the world
vr.startLocationCurrent = vr.startLocation;

%Define tower color
vr.towerRight = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.towerRight,:);
vr.towerLeft = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.towerLeft,:);

% experiment start parameters
vr.cuePos = randi([1 2],1); % random draw between 1 and 2
if vr.cuePos == 1 
   %White Tower on Right
   vr.worlds{1}.surface.visible(vr.towerLeft(1):vr.towerLeft(2))= 0;
else
   %White Tower on Left
   vr.worlds{1}.surface.visible(vr.towerRight(1):vr.towerRight(2))= 0;
end
vr.position = vr.startLocationCurrent;
vr.dp = 0;
vr.startTime = now;
vr.trialTimer = tic;
vr.trialTime = 0;
vr.success = 0;
vr.isStimR = 0;
vr.STATE = 'TRIAL';

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr = checkManualReward(vr);
vr = updateTextDisplay_AK(vr);

% states: TRIAL -> INIT_ITI-> ITI -> INIT_TRIAL -> TRIAL (State Machines)
switch vr.STATE
    case 'TRIAL'

        if abs(vr.position(1)) > eval(vr.exper.variables.armLength)/2 && ...
                vr.position(2) > (eval(vr.exper.variables.wallLength) + eval(vr.exper.variables.delayLength))    % delayLength? default value is 0
            
            if (vr.position(1) > 0 && vr.cuePos == 1) || ...
                    (vr.position(1) < 0 && vr.cuePos == 2)
                vr = giveReward_AK(vr,1);
                vr.numRewards = vr.numRewards + 1;
                vr.numTrials = vr.numTrials + 1;
                vr.success = 1;
                vr.trialTime = toc(vr.trialTimer);
                vr.STATE = 'INIT_ITI';
            else
                vr.numTrials = vr.numTrials + 1;
                vr.trialTime = toc(vr.trialTimer);
                vr.success = 0;
                vr.STATE = 'INIT_ITI';
            end
        elseif toc(vr.trialTimer) > vr.trialTimeout
                
                vr.numTrials = vr.numTrials + 1;
                vr.trialTime = vr.trialTimeout;
                vr.success = 0;
                vr.STATE = 'INIT_ITI';
        end
    
        if vr.collision % test if the animal is currently in collision
            % reduce the x and y components of displacement
            vr.dp(1:2) = vr.dp(1:2) * vr.friction;
        end

        % Decrease velocity by friction coefficient (can be zero)
%         if vr.collision
%             % Friction is proportional to the velocity parpendicular to the wall (i.e. x velocity)
%             theta = atan(vr.position(2)/vr.position(1));
%             vr.dp(1) = 0;
%             vr.dp(2) = vr.dp(2) * abs(sin(theta)).^10;
%         end
        
        if vr.cuePos == 1
           vr.isStimR = 1;   % 1(true) if stimulus was R  
        end
    
    case 'INIT_ITI'
        % blackout screen and start timer
        vr.worlds{1}.surface.visible(:) = 0;
        vr.itiStartTime = tic;

        % Summary: Success | Trial Time 
        % One cell per trial
        dataStruct=struct('success',vr.success,'trialTime',vr.trialTime,...
            'pathLength',vr.exper.variables.wallLengthMin,'isStimR',vr.isStimR);
        eval(['trial',num2str(vr.numTrials),'=dataStruct;']);
        % save to temp .mat file
        if exist(vr.pathTempMatCell,'file')
            save(vr.pathTempMatCell,['trial',num2str(vr.numTrials)],'-append');
        else
            save(vr.pathTempMatCell,['trial',num2str(vr.numTrials)]);
        end
        vr.STATE = 'ITI';
    case 'ITI'
        vr.itiTime = toc(vr.itiStartTime);
        if vr.itiTime > vr.itiDur 
            vr.STATE = 'INIT_TRIAL';
        end
    case 'INIT_TRIAL'
        % if mouse completed in less than 20 sec, make the map longer
        % otherwise make it shorter
        if vr.trialTime < 20
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
        
         % set up world
            % ATK - not happy with this, but a quick fix isn't easy
            length_temp = vr.minWallLength + (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
            vr.startLocationCurrent(2) = vr.startLocation(2) - (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
            vr.exper.variables.wallLengthMin = num2str(length_temp); %this actually changes the back wall
            % note that vr.minWallLength is always 40, even though the
            % exper var changes
            vr.worlds{1} = loadVirmenWorld(vr.exper.worlds{1});
            vr.worlds{1}.surface.visible(:) = 0;
            vr.position = vr.startLocationCurrent;  % teleports the mouse
            vr.dp = 0;
            vr.worlds{1}.surface.visible(:) = 1;
            vr.cuePos = 1;
            vr.cuePos = randi([1 2],1); % random draw between 1 and 2

            if vr.cuePos == 1 
            %White Tower on Right
               vr.worlds{1}.surface.visible(vr.towerLeft(1):vr.towerLeft(2))= 0;
            else
            %White Tower on Left
               vr.worlds{1}.surface.visible(vr.towerRight(1):vr.towerRight(2))= 0;
            end

         % start timer and begin trial
            vr.trialTimer = tic;
            vr.STATE = 'TRIAL';
        otherwise
        disp('state error!');
        return;
    end

% fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI],'float');

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
if ~vr.debugMode
    stop(vr.ai),
    delete(vr.ai),
    delete(vr.ao),
end
vr.exper.variables.wallLengthMin = num2str(vr.minWallLength);
commonTerminationVIRMEN(vr);






