clearvars -except data loaded nameList excelName
close all

%be in the ParticipantData folder

plotPathSpeed = 2; %set to 1 for data of exemplars path, 2 is exemplar speed
%% load in data
if (~exist('loaded','var'))
    findFiles = dir(pwd);
    for (i = 3:length(findFiles))
        dataID = findFiles(i).name;
        dataPre = exam_load(dataID);
        dataPre = KINARM_add_hand_kinematics(dataPre);
        dataFilt = filter_double_pass(dataPre, 'enhanced', 'fc', 10);
        data{i-2} = dataFilt.c3d;
        nameList{i-2,1} = extractBefore(dataID,'_');
        excelName{i-2,1} = [nameList{i-2},'.xlsx'];
    end
    clear dataPre dataFilt
    loaded = 1;
end

%% initialize
%% find length of blocks
% data{1} = [];
% i = 2;
for (i = 1:length(nameList))
% for (i = 1)
    
    partInfo{i} = struct('ID',[],'Sex',[],'Handedness',[],'BlockType',[],'HandTested',[],'ReachLocation',[],'TrialType',[],'TrialResult',[],...
        'MovementTime',[],'MaxSpeed',[],'MaxAccel',[],'SpeedPeaks',[],'ReactionTime',[]);
        
    blockCount = 1;
    for (j = 1:length(data{i}))
        if (find(contains(data{i}(j).EVENTS.LABELS,'BLOCK_')))
            blockStart(blockCount) = j;
            blockCount = blockCount + 1;
        elseif (find(contains(data{i}(j).EVENTS.LABELS,'_APP')))
            blockStart(blockCount) = j;
            findBlock = extractBefore(data{i}(j).EVENTS.LABELS(1),'_APP');
            blockCond{blockCount} = findBlock;
            blockCount = blockCount + 1;
        end
    end
    
    blockArray{1} = (blockStart(1):blockStart(2)-1);
    blockArray{2} = (blockStart(2):blockStart(3)-1);
    blockArray{3} = (blockStart(3):blockStart(4)-1);
    blockArray{4} = (blockStart(4):length(data{i}));
    blockError = cell(1,4);

    %% find block conditions and order
    if (~isempty(find(contains(data{i}(1).EVENTS.LABELS(1),'SEQ_'))))
        findSeq = extractAfter(data{i}(1).EVENTS.LABELS(1),'SEQ_');
        if (str2num(findSeq{1}) == 1) %sandwich sequence 1
            blockCond{1} = {'CIRCLE'};
            blockCond{2} = {'ACTIVE'};
            blockCond{3} = {'SEDEN'};
            blockCond{4} = {'SQUARE'};
        elseif (str2num(findSeq{1}) == 2) %sandwich sequence 2
            blockCond{1} = {'SQUARE'};
            blockCond{2} = {'ACTIVE'};
            blockCond{3} = {'SEDEN'};
            blockCond{4} = {'CIRCLE'};
        elseif (str2num(findSeq{1}) == 3) %sandwich sequence 3
            blockCond{1} = {'CIRCLE'};
            blockCond{2} = {'SEDEN'};
            blockCond{3} = {'ACTIVE'};
            blockCond{4} = {'SQUARE'};
        else %sandwich sequence 4
            blockCond{1} = {'SQUARE'};
            blockCond{2} = {'SEDEN'};
            blockCond{3} = {'ACTIVE'};
            blockCond{4} = {'CIRCLE'};
        end
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
    successDelay(i) = data{i}(1).TASK_WIDE_PARAMS.Success_Delay/2;
    for (z = 1:4)
        if (plotPathSpeed > 0) %if plotting make a new figure for each trial block
            a = figure,
        end
        errorCount = 1;
        lostCount = 1;
        for (j = blockArray{z}) %go through each trial in each block
            %% get data from hand that was tested
            if (find(contains(data{i}(j).EVENTS.LABELS,'LEFT_TARG')))
                dataXPos = data{i}(j).Left_HandX; %xpos
                dataYPos = data{i}(j).Left_HandY; %ypos
                dataSpeed = hypot(data{i}(j).Left_HandXVel,data{i}(j).Left_HandYVel); %hand speed
                dataAccel = hypot(data{i}(j).Left_HandXAcc,data{i}(j).Left_HandYAcc); %hand acceleration
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
                targetOnTime(j) = round(data{i}(j).EVENTS.TIMES(find(contains(data{i}(j).EVENTS.LABELS,'LOCATION_')))*1000); %get target appearance time
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

            reachCond1{j} = blockCond{z}; %get block condition

            if (data{i}(j).TRIAL.TP < 7) %see if trial was active condition
                trialCond{j} = 'ACTIVE'; 
            elseif (data{i}(j).TRIAL.TP > 6 && data{i}(j).TRIAL.TP < 13) %see if trial was sedentary
                trialCond{j} = 'SEDEN';
            elseif (data{i}(j).TRIAL.TP > 12 && data{i}(j).TRIAL.TP < 19) %see if trial was circle
                trialCond{j} = 'CIRCLE';
            else %see if trial was square
                trialCond{j} = 'SQUARE';
            end

            reachTrialNum{j} = data{i}(j).TRIAL.TRIAL_NUM; %get trial number
            reachImage{j} = imageArray{data{i}(j).TRIAL.TP}; %get image name

            if (isempty(find(contains(data{i}(j).EVENTS.LABELS,'TIMED_OUT')))) %for non timed out trials

                whereLoc = (find(contains(data{i}(j).EVENTS.LABELS,'LOCATION_')));
                whatLoc = (extractAfter(data{i}(j).EVENTS.LABELS(whereLoc),'_'));
                reachLoc(j) = str2num(whatLoc{1}); %get reach location

                whereHand = (find(contains(data{i}(j).EVENTS.LABELS,'_TARG_ON')));
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

                if (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'_TARG_ON'))))
                    whereHand = (find(contains(data{i}(j).EVENTS.LABELS,'_TARG_ON')));
                    whatHand = (extractBefore(data{i}(j).EVENTS.LABELS(whereHand),'_'));
                    reachHand{j} = whatHand{1}; %get tested arm
                else
                    reachHand{j} = 'UNTESTED';
                end

                reachERR{j} = 'TIMED OUT'; %no error can be made just timed out

                reachTO{j} = 'TIMED OUT'; %timed out
            end

            %% get variables dependent on times
            if (strcmpi(reachTO{j},'TIMED OUT')||max(dataSpeed(targetOnTime(j):(trialEndTime(j)+successDelay(i))))<0.1)
                startDelay(j) = nan;
                movementTime(j) = nan;
                maxSpeed(j) = nan;
                maxAccel(j) = nan;
                speedPeaks(j) = nan;
                reactTime(j) = nan;
                moveVigour(j) = nan;
            else
                startDelay(j) = targetOnTime(j) - trialStartTime(j); %get start delay
                reactTime(j) = findReactTimeAAT(dataSpeed(targetOnTime(j):(trialEndTime(j)+successDelay(i))),dataAccel(targetOnTime(j):(trialEndTime(j)+successDelay(i)))); %get reaction time
                movementTime(j) = trialEndTime(j) - targetOnTime(j) - reactTime(j); %get movement time
                maxSpeed(j) = findMaxSpeed(dataSpeed(targetOnTime(j):(trialEndTime(j)+successDelay(i)))); %get max speed
                maxAccel(j) = findMaxAccel(dataAccel(targetOnTime(j):(trialEndTime(j)+successDelay(i)))); %get max speed
                speedPeaks(j) = findSpeedPeaks(dataSpeed(targetOnTime(j):(trialEndTime(j)+successDelay(i))),j);
                moveVigour(j) = nan; %get vigour
            end

            %% make struct and output excel file
            partInfo{i}(j).ID = nameList{i};
            partInfo{i}(j).Sex = partSex{i};
            partInfo{i}(j).Handedness = partHand{i};
            partInfo{i}(j).BlockType = reachCond1{j};
            partInfo{i}(j).HandTested = reachHand{j};
            partInfo{i}(j).ReachLocation = reachLoc(j);
            partInfo{i}(j).TrialType = trialCond{j};
            partInfo{i}(j).TrialResult = reachERR{j};
            partInfo{i}(j).MovementTime = movementTime(j);
            partInfo{i}(j).MaxSpeed = maxSpeed(j);
            partInfo{i}(j).MaxAccel = maxAccel(j);
            partInfo{i}(j).SpeedPeaks = speedPeaks(j);
            partInfo{i}(j).ReactionTime = reactTime(j);

            %% plot left and right arms
            if (plotPathSpeed == 1)
                typePlot = 'Path';
                if (strcmpi(blockCond{z},trialCond{j})) %if trial type is same as block type, assumes this block and trial is approach
                    subplot(2,2,1)
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
                    subplot(2,2,3)
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
            elseif (plotPathSpeed == 2)
                typePlot = 'Speed';
                if (strcmpi(blockCond{z},trialCond{j})) %if trial type is same as block type, assumes this block and trial is approach
                    subplot(2,2,1)
                    hold on
                    if (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'APPROACHED')))) %check if correctly approached
                        plot((0:length(dataSpeed)-targetOnTime(j)),dataSpeed(targetOnTime(j):end),'color','b');
                    elseif (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'TIMED_OUT'))))
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
                    if (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'AVOIDED')))) %check if correctly avoided
                        plot((0:length(dataSpeed)-targetOnTime(j)),dataSpeed(targetOnTime(j):end),'color','b');
                    elseif (~isempty(find(contains(data{i}(j).EVENTS.LABELS,'TIMED_OUT'))))
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
        mydir  = pwd;
        idcs   = strfind(mydir,'\');
        newdir = mydir(1:idcs(end)-1);
        set(gcf,'renderer','painters')
        orient(a,'landscape')
        print(a,'-fillpage',fullfile(newdir,['exemplar plot', typePlot, num2str(z)]),'-dpdf');
    end
    set(gcf,'renderer','painters')
    folderPath = fullfile(newdir,excelName{i});
    writetable(struct2table(partInfo{i}),folderPath);
end

