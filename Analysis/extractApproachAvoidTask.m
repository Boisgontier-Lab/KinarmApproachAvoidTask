clearvars -except data loaded nameList excelName
close all

%Script developed to get parameters for the Kinarm Approach Avoid Task.
%Set the current folder to the participant data and run the script.
%The script will load in all kinarm data for each participant and identify
%their ID, sex, handedness, block type, hand assessed, reach location,
%trial type, trial result, movement time, max speed, speedpeaks, error
%distance, reaction time.
%Then the data will be exported to excel files in the folder containing the
%participant data folder.

plotOn = 0;
%% load in data
%search through the current directory and load in all .kinarm files
if (~exist('loaded','var')) %only loads in once
    findFiles = dir(pwd); %get the file names
    for (i = 3:length(findFiles)) %go through each participant
        dataID = findFiles(i).name;
        dataPre = exam_load(dataID); %load in kinarm data from each participant
        dataPre = KINARM_add_hand_kinematics(dataPre);
        dataFilt = filter_double_pass(dataPre, 'enhanced', 'fc', 10); %filter the data
        data{i-2} = dataFilt.c3d;
        nameList{i-2,1} = extractBefore(dataID,'_'); %get the name of participants
        excelName{i-2,1} = [nameList{i-2},'.xlsx'];
    end
    clear dataPre dataFilt
    loaded = 1; %stop loading in data to reduce script rerun time
end

%% initialize
%% find length of blocks
%initialize block values
for (i = 1:length(nameList))
    
    %set up structure for outputting excel data
    partInfo{i} = struct('ID',[],'Sex',[],'Handedness',[],'HandTested',[],'ReachLocation',[],'BlockType',[],'TrialType',[],'TrialImage',[],'TrialGoal',[],'TrialResult',[],...
        'MovementTime',[],'MaxSpeed',[],'SpeedPeaks',[],'ErrorDistance',[],'ReactionTime',[]);
    
    %go through task to find when each block started
    blockCount = 1;
    for (j = 1:length(data{i}))
        if (find(contains(data{i}(j).EVENTS.LABELS,'_APP'))) %find the trial number that started the block
            blockStart(blockCount) = j;
            findBlock = extractBefore(data{i}(j).EVENTS.LABELS(1),'_APP');
            blockCond{blockCount} = findBlock; %record the type of block condition (circle, square, etc)
            blockCount = blockCount + 1;
        end
    end
    
    %get the trial numbers for each block
    blockArray{1} = (blockStart(1):blockStart(2)-1);
    blockArray{2} = (blockStart(2):blockStart(3)-1);
    blockArray{3} = (blockStart(3):blockStart(4)-1);
    blockArray{4} = (blockStart(4):length(data{i}));
    blockError = cell(1,4);

    %% get image and trial number association
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

    %% start processing
    %start getting data for analysis
    
    successDelay(i) = data{i}(1).TASK_WIDE_PARAMS.Success_Delay/2; %time after target was reached/avoided
    reachDist = data{i}(1).TASK_WIDE_PARAMS.Target_Distance; %distance of peripheral target from centre
    for (z = 1:4) %go through each block
        errorCount = 1;
        lostCount = 1;
        for (j = blockArray{z}) %go through each trial in each block
            %% get data from hand that was tested
            %finds which hand was tested
            if (find(contains(data{i}(j).EVENTS.LABELS,'LEFT_TARG_ON')))
                dataXPos = data{i}(j).Left_HandX; %xpos
                dataYPos = data{i}(j).Left_HandY; %ypos
                dataSpeed = hypot(data{i}(j).Left_HandXVel,data{i}(j).Left_HandYVel); %hand speed
            else
                dataXPos = data{i}(j).Right_HandX;
                dataYPos = data{i}(j).Right_HandY;
                dataSpeed = hypot(data{i}(j).Right_HandXVel,data{i}(j).Right_HandYVel);
            end

            %% get important trial times
            if (isempty(find(contains(data{i}(j).EVENTS.LABELS,'TIMED_OUT')))) %if the trial is not timed out
                if (length(find(contains(data{i}(j).EVENTS.LABELS,'HAND_IN_START')))>1) %check if person was unable to hold in start
                    startArray = find(contains(data{i}(j).EVENTS.LABELS,'HAND_IN_START'));
                    startIndex = startArray(end);
                else
                    startIndex = find(contains(data{i}(j).EVENTS.LABELS,'HAND_IN_START'));
                end
                trialStartTime(j) = round(data{i}(j).EVENTS.TIMES(startIndex)*1000); %get start of trial time
                
                whereLoc = (find(contains(data{i}(j).EVENTS.LABELS,'LOCATION_')));
                whatLoc = (extractAfter(data{i}(j).EVENTS.LABELS(whereLoc),'_'));
                reachLoc(j) = str2num(whatLoc{1}); %get reach location
                targetOnTime(j) = round(data{i}(j).EVENTS.TIMES(whereLoc)*1000); %get target appearance time
                
                whereHand = (find(contains(data{i}(j).EVENTS.LABELS,'_TARG_ON')));
                whatHand = (extractBefore(data{i}(j).EVENTS.LABELS(whereHand),'_'));
                reachHand{j} = whatHand{1}; %get tested arm
                
                if (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'APPROACHED')))) %get index if approached target
                    endIndex = find(contains(data{i}(j).EVENTS.LABELS,'APPROACHED'));
                elseif (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'AVOIDED')))) %get index if avoided target
                    endIndex = find(contains(data{i}(j).EVENTS.LABELS,'AVOIDED'));
                elseif (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'ERROR_TRIAL')))) %get index if they made an error
                    endIndex = find(contains(data{i}(j).EVENTS.LABELS,'ERROR_TRIAL'));
                end
                trialEndTime(j) = round(data{i}(j).EVENTS.TIMES(endIndex)*1000); %time of approach/avoid/error
            else %empty the value if there was a time out
                reachLoc(j) = nan;
                reachHand{j} = 'UNTESTED';
                trialStartTime(j) = nan;
                targetOnTime(j) = nan;
                trialEndTime(j) = nan;
            end

            %% record the trials that were errors
            if (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'ERROR_TRIAL'))))
                blockError{z}(errorCount) = j;
                errorCount = errorCount + 1;
            end

            %% get sex
            if (strcmpi(data{i}(1).EXPERIMENT.SUBJECT_SEX,'f'))
                partSex{j} = 'FEMALE';
            else
                partSex{j} = 'MALE';
            end

            %% get handedness
            if (strcmpi(data{i}(1).EXPERIMENT.SUBJECT_HANDEDNESS,'right'))
                partHand{j} = 'RIGHT HANDED';
            else
                partHand{j} = 'LEFT HANDED';
            end

            %% get trial specific parameters
            if (data{i}(j).TRIAL.TP < 7) %see if trial was active condition
                trialCond{j} = 'ACTIVE'; 
            elseif (data{i}(j).TRIAL.TP > 6 && data{i}(j).TRIAL.TP < 13) %see if trial was sedentary
                trialCond{j} = 'SEDEN';
            elseif (data{i}(j).TRIAL.TP > 12 && data{i}(j).TRIAL.TP < 19) %see if trial was circle
                trialCond{j} = 'CIRCLE';
            else %see if trial was square
                trialCond{j} = 'SQUARE';
            end
            
            if (strcmp(blockCond{z},trialCond{j})) %check if the trial should be approached or avoided
                trialGoal{j} = 'APPROACH';
            else
                trialGoal{j} = 'AVOID';
            end

            reachTrialNum{j} = data{i}(j).TRIAL.TRIAL_NUM; %get trial number
            reachImage{j} = imageArray{data{i}(j).TRIAL.TP}; %get image name

            if (isempty(find(contains(data{i}(j).EVENTS.LABELS,'TIMED_OUT')))) %for non timed out trials
                if (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'ERROR_TRIAL')))) %check if trial was error
                    reachERR{j} = 'ERROR';
                else
                    reachERR{j} = 'SUCCESS';
                end
                reachTO{j} = 'REACH MADE'; %not timed out
            else
                reachERR{j} = 'TIMED OUT'; %no error can be made just timed out
                reachTO{j} = 'TIMED OUT'; %timed out
            end

            %% get variables dependent on times
            if (strcmpi(reachTO{j},'TIMED OUT')||max(dataSpeed(targetOnTime(j):(trialEndTime(j)+successDelay(i))))<0.1) %check if timed out or they moved very slow
                startDelay(j) = nan;
                movementTime(j) = nan;
                maxSpeed(j) = nan;
                speedPeaks(j) = nan;
                reactTime(j) = nan;
                errorDist(j) = nan;
            else
                startDelay(j) = targetOnTime(j) - trialStartTime(j); %get time betwee trial start and target on
                reactTime(j) = findReactTimeAAT(dataSpeed(targetOnTime(j):(trialEndTime(j)+successDelay(i))),i,j); %get reaction time
                movementTime(j) = trialEndTime(j) - targetOnTime(j) - reactTime(j); %get time from movement onset to trial end
                maxSpeed(j) = findMaxSpeed(dataSpeed(targetOnTime(j):(trialEndTime(j)+successDelay(i)))); %get max speed
                speedPeaks(j) = findSpeedPeaks(dataSpeed(targetOnTime(j):(trialEndTime(j)+successDelay(i))),j); %get speed peaks
                errorDist(j) = findErrorDist(dataXPos(targetOnTime(j):trialEndTime(j)),dataYPos(targetOnTime(j):trialEndTime(j)),reachLoc(j),reachDist,blockCond{z},trialCond{j}); %get error distance
            end

            %% fill in the structure
            partInfo{i}(j).ID = nameList{i};
            partInfo{i}(j).Sex = partSex{i};
            partInfo{i}(j).Handedness = partHand{i};
            partInfo{i}(j).HandTested = reachHand{j};
            partInfo{i}(j).ReachLocation = reachLoc(j);
            partInfo{i}(j).BlockType = blockCond{z};
            partInfo{i}(j).TrialType = trialCond{j};
            partInfo{i}(j).TrialImage = reachImage{j};
            partInfo{i}(j).TrialGoal = trialGoal{j};
            partInfo{i}(j).TrialResult = reachERR{j};
            partInfo{i}(j).MovementTime = movementTime(j);
            partInfo{i}(j).MaxSpeed = maxSpeed(j);
            partInfo{i}(j).SpeedPeaks = speedPeaks(j);
            partInfo{i}(j).ErrorDistance = errorDist(j);
            partInfo{i}(j).ReactionTime = reactTime(j);

            %% plot left and right arms
            if (plotOn == 1)
                figure,
                if (strcmpi(blockCond{z},trialCond{j})) %if trial type is same as block type, assumes this block and trial is approach
                    subplot(2,1,1)
                    hold on
                    if (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'APPROACHED')))) %check if correctly approached
                        plot(dataXPos,dataYPos,'color','b');
                    elseif (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'TIMED_OUT'))))
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
                    subplot(2,1,2)
                    hold on
                    if (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'AVOIDED')))) %check if correctly avoided
                        plot(dataXPos,dataYPos,'color','b');
                    elseif (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'TIMED_OUT'))))
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
            end
        end
    end
    
    %% save data
    %get the folder that is one directory above the current one
    preSaveFolder = pwd;
    saveFolder = fullfile(preSaveFolder,'..');
    folderPath = fullfile(saveFolder,excelName{i});
    writetable(struct2table(partInfo{i}),folderPath); %save the struct as an excel file
end

