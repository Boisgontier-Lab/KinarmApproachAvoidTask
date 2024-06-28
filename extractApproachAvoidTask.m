clearvars -except data loaded nameList
close all

plotOn = 1;
%% load in data
if (~exist('loaded','var'))
    findFiles = dir('C:\Users\User\Documents\Matlab\Analysis\ParticipantData');
    for (i = 3:length(findFiles))
        dataID = findFiles(i).name;
        dataPre = exam_load(dataID);
        dataPre = KINARM_add_hand_kinematics(dataPre);
        dataFilt = filter_double_pass(dataPre, 'enhanced', 'fc', 10);
        data{i-2} = dataFilt.c3d;
        nameList{i-2,1} = extractBefore(dataID,'_');
    end
    clear dataPre dataFilt
    loaded = 1;
end

%% initialize
%% find length of blocks
% data{1} = [];
% i = 2;
for (i = 1:length(nameList))
    
    partInfo{i} = struct('ID',[],'Sex',[],'Handedness',[],'BlockType',[],'BlockAppAvoid',[],'HandTested',[],'ReachLocation',[],'TrialType',[],'TrialResult',[],...
        'TrialStartTime',[],'TargetAppearTime',[],'TrialEndTime',[],'StartDelay',[],'MovementTime',[],'MaxSpeed',[],'SpeedPeaks',[],'ReactionTime',[]);
    
    for (j = 1:length(data{i}))
        if (find(contains(data{i}(j).EVENTS.LABELS,'BLOCK_1')))
            block1Start = j;
        elseif (find(contains(data{i}(j).EVENTS.LABELS,'BLOCK_2')))
            block2Start = j;
        elseif (find(contains(data{i}(j).EVENTS.LABELS,'BLOCK_3')))
            block3Start = j;
        elseif (find(contains(data{i}(j).EVENTS.LABELS,'BLOCK_4')))
            block4Start = j;
        end
    end

    %get trial numbers in blocks
    % for (j = (block1Start:block2Start-1))
    %     blockArray{1}(j) = data{i}(j).TRIAL.TRIAL_NUM;
    % end
    % for (j = (block2Start:block3Start-1))
    %     blockArray{2}(j-block2Start+1) = data{i}(j).TRIAL.TRIAL_NUM;
    % end
    % for (j = (block3Start:block4Start-1))
    %     blockArray{3}(j-block3Start+1) = data{i}(j).TRIAL.TRIAL_NUM;
    % end
    % for (j = block4Start:length(data))
    %     blockArray{4}(j-block4Start+1) = data{i}(j).TRIAL.TRIAL_NUM;
    % end
    blockArray{1} = (block1Start:block2Start-1);
    blockArray{2} = (block2Start:block3Start-1);
    blockArray{3} = (block3Start:block4Start-1);
    blockArray{4} = (block4Start:length(data{i}));
    blockError = cell(1,4);

    %% find block conditions and order
    findSeq = extractAfter(data{i}(1).EVENTS.LABELS(1),'SEQ_');
    if (str2num(findSeq{1}) == 1) %sandwich sequence 1
        blockCond{1} = {'Circle','Approach'};
        blockCond{2} = {'Active','Approach'};
        blockCond{3} = {'Seden','Approach'};
        blockCond{4} = {'Square','Approach'};
    elseif (str2num(findSeq{1}) == 2) %sandwich sequence 2
        blockCond{1} = {'Square','Approach'};
        blockCond{2} = {'Active','Approach'};
        blockCond{3} = {'Seden','Approach'};
        blockCond{4} = {'Circle','Approach'};
    elseif (str2num(findSeq{1}) == 3) %sandwich sequence 3
        blockCond{1} = {'Circle','Approach'};
        blockCond{2} = {'Seden','Approach'};
        blockCond{3} = {'Active','Approach'};
        blockCond{4} = {'Square','Approach'};
    else %sandwich sequence 4
        blockCond{1} = {'Square','Approach'};
        blockCond{2} = {'Seden','Approach'};
        blockCond{3} = {'Active','Approach'};
        blockCond{4} = {'Circle','Approach'};
    end

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

    for (z = 1:4)
        if (plotOn == 1) %if plotting make a new figure for each trial block
            figure,
        end
        errorCount = 1;
        lostCount = 1;
        for (j = blockArray{z}) %go through each trial in each block
            %% get data from hand that was tested
            if (find(contains(data{i}(j).EVENTS.LABELS,'LEFT_TESTED')))
                dataXPos = data{i}(j).Left_HandX; %xpos
                dataYPos = data{i}(j).Left_HandY; %ypos
                dataSpeed = hypot(data{i}(j).Left_HandXVel,data{i}(j).Left_HandYVel); %hand speed
                dataAccel = hypot(data{i}(j).Left_HandXAcc,data{i}(j).Left_HandXAcc); %hand acceleration
            else
                dataXPos = data{i}(j).Right_HandX;
                dataYPos = data{i}(j).Right_HandY;
                dataSpeed = hypot(data{i}(j).Right_HandXVel,data{i}(j).Right_HandYVel);
                dataAccel = hypot(data{i}(j).Right_HandXAcc,data{i}(j).Right_HandYAcc);
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
                targetOnTime(j) = round(data{i}(j).EVENTS.TIMES(find(contains(data{i}(j).EVENTS.LABELS,'TARGET_ON')))*1000); %get target appearance time
                if (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'APPROACHED')))) %get index if approached target
                    endIndex = find(contains(data{i}(j).EVENTS.LABELS,'APPROACHED'));
                elseif (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'AVOIDED')))) %get index if avoided target
                    endIndex = find(contains(data{i}(j).EVENTS.LABELS,'AVOIDED'));
                elseif (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'ERROR_TRIAL')))) %get index if they made an error
                    endIndex = find(contains(data{i}(j).EVENTS.LABELS,'ERROR_TRIAL'));
                end
                trialEndTime(j) = round(data{i}(j).EVENTS.TIMES(endIndex)*1000); %time of approach/avoid/error
            else %empty the value if there was a time out
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
                partSex{j} = 'Female';
            else
                partSex{j} = 'Male';
            end

            %% get handedness
            if (strcmpi(data{i}(1).EXPERIMENT.SUBJECT_HANDEDNESS,'right'))
                partHand{j} = 'Right Handed';
            else
                partHand{j} = 'Left Handed';
            end

            %% get trial specific parameters

            reachCond1{j} = blockCond{z}{1}; %get block condition
            reachCond2{j} = blockCond{z}{2}; %get approach or avoid condition

            if (data{i}(j).TRIAL.TP < 7) %see if trial was active condition
                trialCond{j} = 'Active'; 
            elseif (data{i}(j).TRIAL.TP > 6 && data{i}(j).TRIAL.TP < 13) %see if trial was sedentary
                trialCond{j} = 'Seden';
            elseif (data{i}(j).TRIAL.TP > 12 && data{i}(j).TRIAL.TP < 19) %see if trial was circle
                trialCond{j} = 'Circle';
            else %see if trial was square
                trialCond{j} = 'Square';
            end

            reachTrialNum{j} = data{i}(j).TRIAL.TRIAL_NUM; %get trial number
            reachImage{j} = imageArray{data{i}(j).TRIAL.TP}; %get image name

            if (isempty(find(contains(data{i}(j).EVENTS.LABELS,'TIMED_OUT')))) %for non timed out trials

                whereLoc = (find(contains(data{i}(j).EVENTS.LABELS,'LOCATION_')));
                whatLoc = (extractAfter(data{i}(j).EVENTS.LABELS(whereLoc),'_'));
                reachLoc(j) = str2num(whatLoc{1}); %get reach location

                whereHand = (find(contains(data{i}(j).EVENTS.LABELS,'_TESTED')));
                whatHand = (extractBefore(data{i}(j).EVENTS.LABELS(whereHand),'_'));
                reachHand{j} = whatHand{1}; %get tested arm

                if (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'ERROR_TRIAL')))) %check if error trial
                    reachERR{j} = 'ERROR';
                else
                    reachERR{j} = 'SUCCESS';
                end

                reachTO{j} = 'REACH MADE'; %not timed out

            else

                if (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'LOCATION_'))))
                    whereLoc = (find(contains(data{i}(j).EVENTS.LABELS,'LOCATION_')));
                    whatLoc = (extractAfter(data{i}(j).EVENTS.LABELS(whereLoc),'_'));
                    reachLoc(j) = str2num(whatLoc{1}); % get reach location
                else
                    reachLoc(j) = nan;
                end

                if (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'_TESTED'))))
                    whereHand = (find(contains(data{i}(j).EVENTS.LABELS,'_TESTED')));
                    whatHand = (extractBefore(data{i}(j).EVENTS.LABELS(whereHand),'_'));
                    reachHand{j} = whatHand{1}; %get tested arm
                else
                    reachHand{j} = 'UNTESTED';
                end

                reachERR{j} = 'TIMED OUT'; %no error can be made just timed out

                reachTO{j} = 'TIMED OUT'; %timed out
            end

            %% get variables dependent on times
            if (strcmpi(reachTO{j},'TIMED OUT'))
                startDelay(j) = nan;
                movementTime(j) = nan;
                maxSpeed(j) = nan;
                speedPeaks(j) = nan;
                reactTime(j) = nan;
                moveVigour(j) = nan;
            else
                startDelay(j) = targetOnTime(j) - trialStartTime(j); %get start delay
                reactTime(j) = findReactTimeAAT(dataSpeed(targetOnTime(j):trialEndTime(j)),dataAccel(targetOnTime(j):trialEndTime(j))); %get reaction time
                movementTime(j) = trialEndTime(j) - trialStartTime(j) - reactTime(j); %get movement time
                maxSpeed(j) = findMaxSpeed(dataSpeed(targetOnTime(j):trialEndTime(j))); %get max speed
                speedPeaks(j) = findSpeedPeaks(dataSpeed(targetOnTime(j):trialEndTime(j)));
                moveVigour(j) = nan; %get vigour
            end

            %% make struct and output excel file
            partInfo{i}(j).ID = nameList{i};
            partInfo{i}(j).Sex = partSex{i};
            partInfo{i}(j).Handedness = partHand{i};
            partInfo{i}(j).BlockType = reachCond1{j};
            partInfo{i}(j).BlockAppAvoid = reachCond2{j};
            partInfo{i}(j).HandTested = reachHand{j};
            partInfo{i}(j).ReachLocation = reachLoc(j);
            partInfo{i}(j).TrialType = trialCond{j};
            partInfo{i}(j).TrialResult = reachERR{j};
            partInfo{i}(j).TrialStartTime = trialStartTime(j);
            partInfo{i}(j).TargetAppearTime = targetOnTime(j);
            partInfo{i}(j).TrialEndTime = trialEndTime(j);
            partInfo{i}(j).StartDelay = startDelay(j);
            partInfo{i}(j).MovementTime = movementTime(j);
            partInfo{i}(j).MaxSpeed = maxSpeed(j);
            partInfo{i}(j).SpeedPeaks = speedPeaks(j);
            partInfo{i}(j).ReactionTime = reactTime(j);

            %% plot left and right arms
            if (plotOn == 1)
                if (strcmpi(blockCond{z}{1},trialCond{j})) %if trial type is same as block type, assumes this block and trial is approach
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
                    title(['Hand Paths ' blockCond{z}{1} ' Approach']);
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
end

