clearvars -except data loaded nameList excelName
close all

%run this script to analyze the KAAT run at 200Hz 
%Put all .kinarm files in a folder and run this script while inside the created folder
%The script can be adjusted for KAAT run at 1000Hz by modifying runFreq

runFreq = 200; %sampling rate the task was run at

plotPathSpeed = 0; %set to 0 not to trial by trial data, 1 to plot data of individual's hand paths, 2 for individual's hand speeds

%% image and trial number association
%reference for image names but unused in code

%active
imageArray{1} = 'ap-cour';
imageArray{2} = 'ap-escal';
imageArray{3} = 'ap-foot';
imageArray{4} = 'ap-nat';
imageArray{5} = 'ap-rando';
imageArray{6} = 'ap-vel';

%sedentary
imageArray{7} = 'sed-canap';
imageArray{8} = 'sed-hamac';
imageArray{9} = 'sed-jvid';
imageArray{10} = 'sed-lect';
imageArray{11} = 'sed-ordi';
imageArray{12} = 'sed-tv';

%circle
imageArray{13} = 'ap-natr';
imageArray{14} = 'ap-randor';
imageArray{15} = 'ap-velr';
imageArray{16} = 'sed-canapr';
imageArray{17} = 'sed-hamacr';
imageArray{18} = 'sed-lectr';

%square
imageArray{19} = 'ap-natc';
imageArray{20} = 'ap-randoc';
imageArray{21} = 'ap-velc';
imageArray{22} = 'sed-canapc';
imageArray{23} = 'sed-hamacc';
imageArray{24} = 'sed-lectc';
    
%% initialize

findFiles = dir(pwd); %get the current directory
findFiles = findFiles(3:end); %omit first 2 files as they are not .kinarm by default

for (i = 1:length(findFiles)) %go through each file
    dataID = findFiles(i).name;
    dataPre = exam_load(dataID); %load in kinarm file
    dataPre = KINARM_add_hand_kinematics_Kayne(dataPre.c3d); %add in hand kinematics modified
    dataPre = KINARM_add_jerk(dataPre); %add in hand jerk
    dataFilt = filter_double_pass(dataPre, 'enhanced', 'fc', 10); %filter data
    data = dataFilt;
    nameList{i,1} = extractBefore(dataID,'_'); %get names of data files
    excelName{i,1} = [nameList{i},'.xlsx'];
    
    %set a couple of variables for later
    wrongDir = zeros;
    catchCount = 1; 
    
    %set up output structure to convert data into excel file
    partInfo{i} = struct('ID',[],'Sex',[],'Handedness',[],'BlockType',[],'HandTested',[],'ReachLocation',[],'TrialType',[],'ImageName',[],'AppAvoid',[],...
        'TrialResult',[],'CumTrialTime',[],'MovementTime',[],'MaxAbDev',[],'MaxSpeed',[],'MaxSpeedTime',[],'MaxAccel',[],'SpeedPeaks',[],'XFlips',[],'OppDist',[],'ReactionTime',[],'InitDir',[],'WrongDir',[]);
        
    blockCount = 1;
    for (j = 1:length(data)) %go through data to get number of trials in each block
        if (find(contains(data(j).EVENTS.LABELS,'BLOCK_'))) %get block number
            blockStart(blockCount) = j;
            blockCount = blockCount + 1;
        elseif (find(contains(data(j).EVENTS.LABELS,'_APP'))) %get block type
            blockStart(blockCount) = j;
            findBlock = extractBefore(data(j).EVENTS.LABELS(1),'_APP');
            blockCount = blockCount + 1;
        end
    end
    
    %put number of trial in each block into blockArray
    blockArray{1} = (blockStart(1):blockStart(2)-1);
    blockArray{2} = (blockStart(2):blockStart(3)-1);
    blockArray{3} = (blockStart(3):blockStart(4)-1);
    blockArray{4} = (blockStart(4):length(data));
    blockError = cell(1,4);

    %% start processing
    for (z = 1:4) %go through blocks
        whereBlock = (find(contains(data(blockArray{z}(1)).EVENTS.LABELS,'_APP'))); %get target location (1 - east, 4 - north, 7 - west, 10 - south)
        whatBlock = (extractBefore(data(blockArray{z}(1)).EVENTS.LABELS(whereBlock),'_'));
        blockCond{z} = whatBlock; %get the block name
        if (plotPathSpeed > 0) %if plotting make a new figure for each trial block
            a = figure,
        end
        errorCount = 1;
        lostCount = 1;
        for (j = blockArray{z}) %go through each trial in each block

            %% get important trial times
            if (isempty(find(contains(data(j).EVENTS.LABELS,'TIMED_OUT')))) %if the trial is not timed out
                if (length(find(contains(data(j).EVENTS.LABELS,'HAND_IN_START')))>1) %check if person was unable to hold hand in start
                    startArray = find(contains(data(j).EVENTS.LABELS,'HAND_IN_START'));
                    startIndex = startArray(end); %last time the participant held their hand in the start
                else
                    startIndex = find(contains(data(j).EVENTS.LABELS,'HAND_IN_START')); %time the participant held there hand in the start
                end
                trialStartTime(j) = round(data(j).EVENTS.TIMES(startIndex)*200); %get start of trial time
                targetOnTime(j) = round(data(j).EVENTS.TIMES(find(contains(data(j).EVENTS.LABELS,'LOCATION_')))*200); %get target appearance time
                if (~isempty(find(contains(data(j).EVENTS.LABELS,'APPROACHED')))) %get index if approached target
                    endIndex = find(contains(data(j).EVENTS.LABELS,'APPROACHED'));
                elseif (~isempty(find(contains(data(j).EVENTS.LABELS,'AVOIDED')))) %get index if avoided target
                    endIndex = find(contains(data(j).EVENTS.LABELS,'AVOIDED'));
                elseif (~isempty(find(contains(data(j).EVENTS.LABELS,'ERROR_TRIAL')))) %get index if they made an error
                    endIndex = find(contains(data(j).EVENTS.LABELS,'ERROR_TRIAL'));
                end
                trialEndTime(j) = round(data(j).EVENTS.TIMES(endIndex)*200); %time of approach/avoid/error
            else %empty the value if there was a time out
                trialStartTime(j) = nan;
                targetOnTime(j) = nan;
                trialEndTime(j) = nan;
            end

            %% get data from hand that was tested
            catchArm = 0;
            if (find(contains(data(j).EVENTS.LABELS,'LEFT_TARG'))) %left hand
                dataXPos = data(j).Left_HandX; %xpos
                dataYPos = data(j).Left_HandY; %ypos
                dataXSpeed = data(j).Left_HandXVel;
                dataYSpeed = data(j).Left_HandYVel;
                dataSpeed = hypot(data(j).Left_HandXVel,data(j).Left_HandYVel); %hand speed
                dataAccel = hypot(data(j).Left_HandXAcc,data(j).Left_HandYAcc); %hand acceleration
            elseif (find(contains(data(j).EVENTS.LABELS,'RIGHT_TARG'))) %right hand
                dataXPos = data(j).Right_HandX;
                dataYPos = data(j).Right_HandY;
                dataXSpeed = data(j).Right_HandXVel;
                dataYSpeed = data(j).Right_HandYVel;
                dataSpeed = hypot(data(j).Right_HandXVel,data(j).Right_HandYVel);
                dataAccel = hypot(data(j).Right_HandXAcc,data(j).Right_HandYAcc);
            else %sometimes the event didn't write so this checks which hand had the highest speed during the trial (this statement SHOULD NOT be true any more)
                catchArm = 1;
                if (max(hypot(data(j).Right_HandXVel(trialStartTime(j):end),data(j).Right_HandYVel(trialStartTime(j):end))) > max(hypot(data(j).Left_HandXVel(trialStartTime(j):end),data(j).Left_HandYVel(trialStartTime(j):end))))
                    whatHand{1} = 'RIGHT';
                    dataXPos = data(j).Right_HandX;
                    dataYPos = data(j).Right_HandY;
                    dataXSpeed = data(j).Right_HandXVel;
                    dataYSpeed = data(j).Right_HandYVel;
                    dataSpeed = hypot(data(j).Right_HandXVel,data(j).Right_HandYVel);
                    dataAccel = hypot(data(j).Right_HandXAcc,data(j).Right_HandYAcc);
                else
                    whatHand{1} = 'LEFT';
                    dataXPos = data(j).Left_HandX; %xpos
                    dataYPos = data(j).Left_HandY; %ypos
                    dataXSpeed = data(j).Left_HandXVel;
                    dataYSpeed = data(j).Left_HandYVel;
                    dataSpeed = hypot(data(j).Left_HandXVel,data(j).Left_HandYVel); %hand speed
                    dataAccel = hypot(data(j).Left_HandXAcc,data(j).Left_HandYAcc); %hand acceleration
                end
                catchList(catchCount,1) = i; %identify person that had the missed event
                catchList(catchCount,2) = j; %identify trial number of the missed event
                catchCount = catchCount + 1;
            end

            %% record the trials that were errors
            if (~isempty(find(contains(data(j).EVENTS.LABELS,'ERROR_TRIAL'))))
                blockError{z}(errorCount) = j;
                errorCount = errorCount + 1;
            end

            %% get sex
            if (strcmpi(data(1).EXPERIMENT.SUBJECT_SEX,'f'))
                partSex{j} = 'FEMALE';
            elseif (strcmpi(data(1).EXPERIMENT.SUBJECT_SEX,'m'))
                partSex{j} = 'MALE';
            else
                error();
            end

            %% get handedness
            if (strcmpi(data(1).EXPERIMENT.SUBJECT_HANDEDNESS,'right'))
                partHand{j} = 'RIGHT HANDED';
            elseif (strcmpi(data(1).EXPERIMENT.SUBJECT_HANDEDNESS,'left'))
                partHand{j} = 'LEFT HANDED';
            else
                error()
            end

            %% get trial specific parameters
            reachCond1{j} = blockCond{z}; %get block condition

            if (data(j).TRIAL.TP < 7) %see if trial was active condition
                trialCond{j} = 'ACTIVE'; 
            elseif (data(j).TRIAL.TP > 6 && data(j).TRIAL.TP < 13) %see if trial was sedentary
                trialCond{j} = 'SEDEN';
            elseif (data(j).TRIAL.TP > 12 && data(j).TRIAL.TP < 19) %see if trial was circle
                trialCond{j} = 'CIRCLE';
            else %see if trial was square
                trialCond{j} = 'SQUARE';
            end

            reachTrialNum{j} = data(j).TRIAL.TRIAL_NUM; %get trial number
            reachImage{j} = imageArray{data(j).TRIAL.TP}; %get image name

            if (isempty(find(contains(data(j).EVENTS.LABELS,'TIMED_OUT')))) %for non timed out trials

                whereLoc = (find(contains(data(j).EVENTS.LABELS,'LOCATION_'))); %get target location (1 - east, 4 - north, 7 - west, 10 - south)
                whatLoc = (extractAfter(data(j).EVENTS.LABELS(whereLoc),'_'));
                reachLoc(j) = str2num(whatLoc{1}); %get reach location
                whereHand = (find(contains(data(j).EVENTS.LABELS,'_TARG_ON'))); %get the hand required for task
                if (catchArm == 0)
                    whatHand = (extractBefore(data(j).EVENTS.LABELS(whereHand),'_'));
                end
                reachHand{j} = whatHand{1}; %get tested arm

                if (~isempty(find(contains(data(j).EVENTS.LABELS,'ERROR_TRIAL')))) %check if error trial
                    reachERR{j} = 'ERROR';
                else
                    reachERR{j} = 'SUCCESS';
                end
                
                approached = (find(contains(data(j).EVENTS.LABELS,'APPROACHED'))>0); %check if the trial is approach 
                avoided = (find(contains(data(j).EVENTS.LABELS,'AVOIDED'))>0); %check if trial is avoid

                if (~isempty(approached) || ~isempty(avoided)) %get a label for the approach or avoid
                    if (approached)
                        appAvoid(j) = 0; %0 = approach
                        appAvoidText{j} = 'APPROACHED';
                    end
                    if (avoided)
                        appAvoid(j) = 1; %1 = avoid
                        appAvoidText{j} = 'AVOIDED';
                    end
                else %trial was incorrect
                    appAvoid(j) = 2;
                    appAvoidText{j} = 'INCORRECT';
                end

                if (strcmp(reachERR{j},'ERROR')) %if the trial was error then force output to be incorrect
                    appAvoid(j) = 2;
                    appAvoidText{j} = 'INCORRECT';
                end

                reachTO{j} = 'REACH MADE'; %not timed out

            else %nan out everything else
                if (~isempty(find(contains(data(j).EVENTS.LABELS,'LOCATION_'))))
                    whereLoc = (find(contains(data(j).EVENTS.LABELS,'LOCATION_')));
                    whatLoc = (extractAfter(data(j).EVENTS.LABELS(whereLoc),'_'));
                    reachLoc(j) = str2num(whatLoc{1}); % get reach location
                else
                    reachLoc(j) = nan;
                end
                
                appAvoid(j) = nan;
                appAvoidText{j} = 'TIMED OUT';

                if (~isempty(find(contains(data(j).EVENTS.LABELS,'_TARG_ON'))))
                    whereHand = (find(contains(data(j).EVENTS.LABELS,'_TARG_ON')));
                    whatHand = (extractBefore(data(j).EVENTS.LABELS(whereHand),'_'));
                    reachHand{j} = whatHand{1}; %get tested arm
                else
                    reachHand{j} = 'UNTESTED';
                end

                reachERR{j} = 'TIMED OUT'; %no error can be made just timed out

                reachTO{j} = 'TIMED OUT'; %timed out
            end

            %% get variables dependent on times
            minReactTime = 50/(1000/runFreq); %should be 50ms threshold but task is sampled at 200hz instead of 1000hz
            if (strcmpi(reachTO{j},'TIMED OUT'))
                startDelay(j) = nan;
                movementTime(j) = nan;
                maxAbDev(j) = nan;
                maxSpeed(j) = nan;
                maxSpeedTime(j) = nan;
                maxAccel(j) = nan;
                speedPeaks(j) = nan;
                xFlips(j) = nan;
                oppDist(j) = nan;
                reactTime(j) = nan;
                % reactTimeAlt(j) = nan;
                initDir(j) = nan;
                wrongDir(j) = nan;
            else
                startDelay(j) = targetOnTime(j) - trialStartTime(j); %get start delay
                % reactTime(j) = findReactTimeAAT200Hz(dataSpeed(targetOnTime(j):trialEndTime(j)),dataAccel(targetOnTime(j):trialEndTime(j))); %get reaction time based on 10% max vel
                reactTime(j) = findReactTimeAltAAT200Hz(dataAccel(targetOnTime(j):trialEndTime(j)),i,j,runFreq); %get alternate reaction time based on 1000mm/sec^2 to 200mm/sec^2 threshold
                movementTime(j) = trialEndTime(j) - targetOnTime(j) - reactTime(j); %get movement time
                maxAbDev(j) = findMaxAbDev(dataXPos(targetOnTime(j):trialEndTime(j)),dataYPos(targetOnTime(j):trialEndTime(j)),reachLoc(j),appAvoid(j),i,j); %get maximum hand deviation from a straight line to the target
                [maxSpeed(j) maxSpeedTime(j)] = findMaxSpeed(dataSpeed(targetOnTime(j):trialEndTime(j))); %get max speed and time
                maxAccel(j) = findMaxAccel(dataAccel(targetOnTime(j):trialEndTime(j))); %get max accel
                if (~isnan(reactTime(j))) %if reaction time alt is not a nan
                    if (maxSpeedTime(j) > reactTime(j))
                        speedPeaks(j) = findSpeedPeaks(dataSpeed(targetOnTime(j)+reactTime(j):targetOnTime(j)+maxSpeedTime(j)+1),i,j, reactTime(j),targetOnTime(j),maxSpeedTime(j))-1; %get # of hand hesitations
                        xFlips(j) = findXFlips(dataXPos(targetOnTime(j)+reactTime(j)+minReactTime:targetOnTime(j)+maxSpeedTime(j)+1),...
                            dataYPos(targetOnTime(j)+reactTime(j)+minReactTime:targetOnTime(j)+maxSpeedTime(j)+1),...
                            dataXSpeed(targetOnTime(j)+reactTime(j)+minReactTime:targetOnTime(j)+maxSpeedTime(j)+1),...
                            dataYSpeed(targetOnTime(j)+reactTime(j)+minReactTime:targetOnTime(j)+maxSpeedTime(j)+1),reachLoc(j),appAvoid(j),i,j);
                    else
                        speedPeaks(j) = findSpeedPeaks(dataSpeed(targetOnTime(j)+reactTime(j):trialEndTime(j)),i,j, reactTime(j),targetOnTime(j),maxSpeedTime(j))-1;
                        xFlips(j) = findXFlips(dataXPos(targetOnTime(j)+reactTime(j)+minReactTime:trialEndTime(j)),...
                            dataYPos(targetOnTime(j)+reactTime(j)+minReactTime:trialEndTime(j)),...
                            dataXSpeed(targetOnTime(j)+reactTime(j)+minReactTime:trialEndTime(j)),...
                            dataYSpeed(targetOnTime(j)+reactTime(j)+minReactTime:trialEndTime(j)),reachLoc(j),appAvoid(j),i,j);
                    end
                else
                    speedPeaks(j) = nan;
                    xFlips(j) = nan;
                end
                oppDist(j) = findOppDistAAT(dataXPos(targetOnTime(j):trialEndTime(j)),dataYPos(targetOnTime(j):trialEndTime(j)),reachLoc(j),appAvoid(j),i,j);
                initDir(j) = findInitDir(dataXPos(targetOnTime(j):trialEndTime(j)),dataYPos(targetOnTime(j):trialEndTime(j)),dataSpeed(targetOnTime(j):trialEndTime(j)),reachLoc(j),appAvoid(j),i,j); %get initial hand direction
                wrongDir(j) = (initDir(j)>90); %flag if the hand went 90degrees away from the target
            end
            
            if (j == 1)
                cumTrialTime(j) = 0;
            else
                cumTrialTime(j) = cumTrialTime(j-1)+size(data(j-1).Right_HandX,1)*5;
            end

            %% make struct and output excel file
            partInfo{i}(j).ID = nameList{i};
            partInfo{i}(j).Sex = partSex{j};
            partInfo{i}(j).Handedness = partHand{j};
            partInfo{i}(j).BlockType = reachCond1{j};
            partInfo{i}(j).HandTested = reachHand{j};
            partInfo{i}(j).ReachLocation = reachLoc(j);
            partInfo{i}(j).TrialType = trialCond{j};
            partInfo{i}(j).ImageName = reachImage{j};
            partInfo{i}(j).AppAvoid = appAvoidText{j};
            partInfo{i}(j).TrialResult = reachERR{j};
            partInfo{i}(j).CumTrialTime = cumTrialTime(j);
            partInfo{i}(j).MovementTime = movementTime(j)*(1000/runFreq);
            partInfo{i}(j).MaxAbDev = maxAbDev(j);
            partInfo{i}(j).MaxSpeed = maxSpeed(j);
            partInfo{i}(j).MaxSpeedTime = maxSpeedTime(j)*(1000/runFreq);
            partInfo{i}(j).MaxAccel = maxAccel(j);
            partInfo{i}(j).SpeedPeaks = speedPeaks(j);
            partInfo{i}(j).XFlips = xFlips(j);
            partInfo{i}(j).OppDist = oppDist(j);
            partInfo{i}(j).ReactionTime = reactTime(j)*(1000/runFreq);
            % partInfo{i}(j).ReactionTimeAlt = reactTimeAlt(j)*(1000/runFreq);
            partInfo{i}(j).InitDir = initDir(j);
            partInfo{i}(j).WrongDir = wrongDir(j);

            %% plot left and right arms
            if (plotPathSpeed == 1) %plot hand path
                typePlot = 'Path';
                if (strcmpi(blockCond{z},trialCond{j})) %if trial type is same as block type, assumes this block and trial is approach
                    subplot(2,2,1)
                    hold on
                    if (~isempty(find(contains(data(j).EVENTS.LABELS,'APPROACHED')))) %check if correctly approached
                        plot(dataXPos,dataYPos,'color','b');
                    elseif (~isempty(find(contains(data(j).EVENTS.LABELS,'TIMED_OUT'))))
                        plot(dataXPos,dataYPos,'color','r');
                        lostTrial(lostCount) = j;
                        lostCount = lostCount + 1;
                    else %error trial
                        plot(dataXPos,dataYPos,'color','r');
                        lostTrial(lostCount) = j;
                        lostCount = lostCount + 1;
                    end
                    title(['Hand Paths ' blockCond{z} ' Approach']);
                    ylabel('Y (m)');
                    xlabel('X (m)');
                else %plot the avoid condition for the other type of stimulus
                    subplot(2,2,3)
                    hold on
                    if (~isempty(find(contains(data(j).EVENTS.LABELS,'AVOIDED')))) %check if correctly avoided
                        plot(dataXPos,dataYPos,'color','b');
                    elseif (~isempty(find(contains(data(j).EVENTS.LABELS,'TIMED_OUT'))))
                        plot(dataXPos,dataYPos,'color','r');
                        lostTrial(lostCount) = j;
                        lostCount = lostCount + 1;
                    else %error trial
                        plot(dataXPos,dataYPos,'color','r');
                        lostTrial(lostCount) = j;
                        lostCount = lostCount + 1;
                    end
                    title(['Avoid']);
                end
            elseif (plotPathSpeed == 2) %plot hand speed
                typePlot = 'Speed';
                if (strcmpi(blockCond{z},trialCond{j})) %if trial type is same as block type, assumes this block and trial is approach
                    subplot(2,2,1)
                    hold on
                    if (~isempty(find(contains(data(j).EVENTS.LABELS,'APPROACHED')))) %check if correctly approached
                        plot((0:length(dataSpeed)-targetOnTime(j)),dataSpeed(targetOnTime(j):end),'color','b');
                    elseif (~isempty(find(contains(data(j).EVENTS.LABELS,'TIMED_OUT'))))
                        if (~isnan(targetOnTime(j)))
                            plot((0:length(dataSpeed)-targetOnTime(j)),dataSpeed(targetOnTime(j):end),'color','r');
                        end
                        lostTrial(lostCount) = j;
                        lostCount = lostCount + 1;
                    else %error trial
                        plot(dataXPos,dataYPos,'color','r');
                        lostTrial(lostCount) = j;
                        lostCount = lostCount + 1;
                    end
                    title(['Hand Speeds ' blockCond{z} ' Approach']);
                    xlim([400 1500])
                    ylim([0 0.80])
                    ylabel('Y (cm)');
                    xlabel('X (ms)');
                else %plot the avoid condition for the other type of stimulus
                    subplot(2,2,3)
                    hold on
                    if (~isempty(find(contains(data(j).EVENTS.LABELS,'AVOIDED')))) %check if correctly avoided
                        plot((0:length(dataSpeed)-targetOnTime(j)),dataSpeed(targetOnTime(j):end),'color','b');
                    elseif (~isempty(find(contains(data(j).EVENTS.LABELS,'TIMED_OUT'))))
                        if (~isnan(targetOnTime(j)))
                            plot((0:length(dataSpeed)-targetOnTime(j)),dataSpeed(targetOnTime(j):end),'color','r');
                        end
                        lostTrial(lostCount) = j;
                        lostCount = lostCount + 1;
                    else %error trial
                        plot(dataXPos,dataYPos,'color','r');
                        lostTrial(lostCount) = j;
                        lostCount = lostCount + 1;
                    end
                    ylim([0 0.80])
                    xlim([400 1500])
                    title(['Avoid']);
                end
            end
        end
        if (plotPathSpeed > 0)
            set(gcf,'renderer','painters')
            orient(a,'landscape')
            print(a,'-fillpage',fullfile(newdir,['exemplar plot', typePlot, num2str(z)]),'-dpdf');
        end
    end
    mydir = pwd;
    idcs = strfind(mydir,'\');
    newdir = [mydir(1:idcs(end)-1),'\excelSummaries'];
    folderPath = fullfile(newdir,excelName{i});
    writetable(struct2table(partInfo{i}),folderPath);
    justFinished = nameList{i}

    % clear data
    close all
end

% % %exemplar for francois proj
% i = 1;
% j = 1;
% g = figure,
% % plot(hypot(data(j).Left_HandXVel(targetOnTime(i,j):end),data(j).Left_HandYVel(targetOnTime(i,j):end)),'LineWidth',2.5,'Color','b') % get absolute velocity
% % plot((data(j).Left_HandXVel(targetOnTime(i,j):end)),'LineWidth',2.5,'Color','b') % get time to peak speed
% % plot((data(j).Left_HandX(targetOnTime(i,j):end)),'LineWidth',2.5,'Color','b') %get hand position
% plot((data(j).Left_HandX(targetOnTime(i,j):end)),(data{1}(j).Left_HandY(targetOnTime(i,j):end)),'LineWidth',2.5,'Color','b') %get hand trajectory
% set(gcf,'renderer','painters')