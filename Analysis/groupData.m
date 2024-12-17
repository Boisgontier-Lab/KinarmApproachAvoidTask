clearvars -except excelIn
close all

%be in the level above the ParticipantData folder

findFiles = dir([pwd, '\excelData']);
for (i = 3:length(findFiles))
    dataID = findFiles(i).name;
    [excelNums{i-2},~,excelIn{i-2}] = xlsread(dataID);
end

for (i = 1:length(excelIn))
    blockType = find(contains(excelIn{i}(1,:),'BlockType'));
    trialType = find(contains(excelIn{i}(1,:),'TrialType'));
    trialResult = find(contains(excelIn{i}(1,:),'TrialResult'));
    maxSpeed = find(contains(excelIn{i}(1,:),'MaxSpeed'));
    maxAccel = find(contains(excelIn{i}(1,:),'MaxAccel'));
    speedPeaks = find(contains(excelIn{i}(1,:),'SpeedPeaks'));
    reactionTime = find(contains(excelIn{i}(1,:),'ReactionTime'));
    
    rtArrayTemp = [cell2mat(excelIn{i}(2:end,reactionTime))];
    peaksArray = [cell2mat(excelIn{i}(2:end,speedPeaks))];
    speedArray = [cell2mat(excelIn{i}(2:end,maxSpeed))];
    accelArray = [cell2mat(excelIn{i}(2:end,maxAccel))];
    errorArray = [strcmp(excelIn{i}(2:end,trialResult),'ERROR')];
    rtArray = rtArrayTemp.*(1-errorArray); %remove error trials from analysis
    
	%% circ square
    blockCircle = strcmp(excelIn{i}(2:end,blockType),'CIRCLE');
    blockSquare = strcmp(excelIn{i}(2:end,blockType),'SQUARE');
    trialCircle = strcmp(excelIn{i}(2:end,trialType),'CIRCLE');
    trialSquare = strcmp(excelIn{i}(2:end,trialType),'SQUARE');
    
    %reaction time
    rtCircApp = rtArray.*(blockCircle+trialCircle>1);
    rtSquareApp = rtArray.*(blockSquare+trialSquare>1);
    rtCircAvoid = rtArray.*(blockCircle+trialSquare>1);
    rtSquareAvoid = rtArray.*(blockSquare+trialCircle>1);
    meanRTCircApp = mean(rtCircApp(rtCircApp>0),'omitnan');
    stdRTCircApp = nanstd(rtCircApp(rtCircApp>0));
    minRTCircApp = min(rtCircApp(rtCircApp>0));
    maxRTCircApp = max(rtCircApp(rtCircApp>0));
    meanRTSquareApp = mean(rtSquareApp(rtSquareApp>0),'omitnan');
    stdRTSquareApp = nanstd(rtSquareApp(rtSquareApp>0));
    minRTSquareApp = min(rtSquareApp(rtSquareApp>0));
    maxRTSquareApp = max(rtSquareApp(rtSquareApp>0));
    meanRTCircAvoid = mean(rtCircAvoid(rtCircAvoid>0),'omitnan');
    stdRTCircAvoid = nanstd(rtCircAvoid(rtCircAvoid>0));
    minRTCircAvoid = min(rtCircAvoid(rtCircAvoid>0));
    maxRTCircAvoid = max(rtCircAvoid(rtCircAvoid>0));
    meanRTSquareAvoid = mean(rtSquareAvoid(rtSquareAvoid>0),'omitnan');
    stdRTSquareAvoid = nanstd(rtSquareAvoid(rtSquareAvoid>0));
    minRTSquareAvoid = min(rtSquareAvoid(rtSquareAvoid>0));
    maxRTSquareAvoid = max(rtSquareAvoid(rtSquareAvoid>0));
    
    rtNeutApp = rtCircApp + rtSquareApp;
    rtNeutAvoid = rtCircAvoid + rtSquareAvoid;
    meanRTNeutApp = mean(rtNeutApp(rtNeutApp>0),'omitnan');
    stdRTNeutApp = nanstd(rtNeutApp(rtNeutApp>0));
    minRTNeutApp = min(rtNeutApp(rtNeutApp>0));
    maxRTNeutApp = max(rtNeutApp(rtNeutApp>0));
    meanRTNeutAvoid = mean(rtNeutAvoid(rtNeutAvoid>0),'omitnan');
    stdRTNeutAvoid = nanstd(rtNeutAvoid(rtNeutAvoid>0));
    minRTNeutAvoid = min(rtNeutAvoid(rtNeutAvoid>0));
    maxRTNeutAvoid = max(rtNeutAvoid(rtNeutAvoid>0));
    
    %max speed
    speedCircApp = speedArray.*(blockCircle+trialCircle>1);
    speedSquareApp = speedArray.*(blockSquare+trialSquare>1);
    speedCircAvoid = speedArray.*(blockCircle+trialSquare>1);
    speedSquareAvoid = speedArray.*(blockSquare+trialCircle>1);
    meanSpeedCircApp = mean(speedCircApp(speedCircApp>0),'omitnan');
    stdSpeedCircApp = nanstd(speedCircApp(speedCircApp>0));
    minSpeedCircApp = min(speedCircApp(speedCircApp>0));
    maxSpeedCircApp = max(speedCircApp(speedCircApp>0));
    meanSpeedSquareApp = mean(speedSquareApp(speedSquareApp>0),'omitnan');
    stdSpeedSquareApp = nanstd(speedSquareApp(speedSquareApp>0));
    minSpeedSquareApp = min(speedSquareApp(speedSquareApp>0));
    maxSpeedSquareApp = max(speedSquareApp(speedSquareApp>0));
    meanSpeedCircAvoid = mean(speedCircAvoid(speedCircAvoid>0),'omitnan');
    stdSpeedCircAvoid = nanstd(speedCircAvoid(speedCircAvoid>0));
    minSpeedCircAvoid = min(speedCircAvoid(speedCircAvoid>0));
    maxSpeedCircAvoid = max(speedCircAvoid(speedCircAvoid>0));
    meanSpeedSquareAvoid = mean(speedSquareAvoid(speedSquareAvoid>0),'omitnan');
    stdSpeedSquareAvoid = nanstd(speedSquareAvoid(speedSquareAvoid>0));
    minSpeedSquareAvoid = min(speedSquareAvoid(speedSquareAvoid>0));
    maxSpeedSquareAvoid = max(speedSquareAvoid(speedSquareAvoid>0));
    
    speedNeutApp = speedCircApp + speedSquareApp;
    speedNeutAvoid = speedCircAvoid + speedSquareAvoid;
    meanSpeedNeutApp = mean(speedNeutApp(speedNeutApp>0),'omitnan');
    stdSpeedNeutApp = nanstd(speedNeutApp(speedNeutApp>0));
    minSpeedNeutApp = min(speedNeutApp(speedNeutApp>0));
    maxSpeedNeutApp = max(speedNeutApp(speedNeutApp>0));
    meanSpeedNeutAvoid = mean(speedNeutAvoid(speedNeutAvoid>0),'omitnan');
    stdSpeedNeutAvoid = nanstd(speedNeutAvoid(speedNeutAvoid>0));
    minSpeedNeutAvoid = min(speedNeutAvoid(speedNeutAvoid>0));
    maxSpeedNeutAvoid = max(speedNeutAvoid(speedNeutAvoid>0));
    
    %max accel
    accelCircApp = accelArray.*(blockCircle+trialCircle>1);
    accelSquareApp = accelArray.*(blockSquare+trialSquare>1);
    accelCircAvoid = accelArray.*(blockCircle+trialSquare>1);
    accelSquareAvoid = accelArray.*(blockSquare+trialCircle>1);
    meanAccelCircApp = mean(accelCircApp(accelCircApp>0),'omitnan');
    stdAccelCircApp = nanstd(accelCircApp(accelCircApp>0));
    minAccelCircApp = min(accelCircApp(accelCircApp>0));
    maxAccelCircApp = max(accelCircApp(accelCircApp>0));
    meanAccelSquareApp = mean(accelSquareApp(accelSquareApp>0),'omitnan');
    stdAccelSquareApp = nanstd(accelSquareApp(accelSquareApp>0));
    minAccelSquareApp = min(accelSquareApp(accelSquareApp>0));
    maxAccelSquareApp = max(accelSquareApp(accelSquareApp>0));
    meanAccelCircAvoid = mean(accelCircAvoid(accelCircAvoid>0),'omitnan');
    stdAccelCircAvoid = nanstd(accelCircAvoid(accelCircAvoid>0));
    minAccelCircAvoid = min(accelCircAvoid(accelCircAvoid>0));
    maxAccelCircAvoid = max(accelCircAvoid(accelCircAvoid>0));
    meanAccelSquareAvoid = mean(accelSquareAvoid(accelSquareAvoid>0),'omitnan');
    stdAccelSquareAvoid = nanstd(accelSquareAvoid(accelSquareAvoid>0));
    minAccelSquareAvoid = min(accelSquareAvoid(accelSquareAvoid>0));
    maxAccelSquareAvoid = max(accelSquareAvoid(accelSquareAvoid>0));
    
    accelNeutApp = accelCircApp + accelSquareApp;
    accelNeutAvoid = accelCircAvoid + accelSquareAvoid;
    meanAccelNeutApp = mean(accelNeutApp(accelNeutApp>0),'omitnan');
    stdAccelNeutApp = nanstd(accelNeutApp(accelNeutApp>0));
    minAccelNeutApp = min(accelNeutApp(accelNeutApp>0));
    maxAccelNeutApp = max(accelNeutApp(accelNeutApp>0));
    meanAccelNeutAvoid = mean(accelNeutAvoid(accelNeutAvoid>0),'omitnan');
    stdAccelNeutAvoid = nanstd(accelNeutAvoid(accelNeutAvoid>0));
    minAccelNeutAvoid = min(accelNeutAvoid(accelNeutAvoid>0));
    maxAccelNeutAvoid = max(accelNeutAvoid(accelNeutAvoid>0));
    
    %speed peaks
    peaksCircApp = peaksArray.*(blockCircle+trialCircle>1);
    peaksSquareApp = peaksArray.*(blockSquare+trialSquare>1);
    peaksCircAvoid = peaksArray.*(blockCircle+trialSquare>1);
    peaksSquareAvoid = peaksArray.*(blockSquare+trialCircle>1);
    meanPeaksCircApp = mean(peaksCircApp(peaksCircApp>0),'omitnan');
    stdPeaksCircApp = nanstd(peaksCircApp(peaksCircApp>0));
    minPeaksCircApp = min(peaksCircApp(peaksCircApp>0));
    maxPeaksCircApp = max(peaksCircApp(peaksCircApp>0));
    meanPeaksSquareApp = mean(peaksSquareApp(peaksSquareApp>0),'omitnan');
    stdPeaksSquareApp = nanstd(peaksSquareApp(peaksSquareApp>0));
    minPeaksSquareApp = min(peaksSquareApp(peaksSquareApp>0));
    maxPeaksSquareApp = max(peaksSquareApp(peaksSquareApp>0));
    meanPeaksCircAvoid = mean(peaksCircAvoid(peaksCircAvoid>0),'omitnan');
    stdPeaksCircAvoid = nanstd(peaksCircAvoid(peaksCircAvoid>0));
    minPeaksCircAvoid = min(peaksCircAvoid(peaksCircAvoid>0));
    maxPeaksCircAvoid = max(peaksCircAvoid(peaksCircAvoid>0));
    meanPeaksSquareAvoid = mean(peaksSquareAvoid(peaksSquareAvoid>0),'omitnan');
    stdPeaksSquareAvoid = nanstd(peaksSquareAvoid(peaksSquareAvoid>0));
    minPeaksSquareAvoid = min(peaksSquareAvoid(peaksSquareAvoid>0));
    maxPeaksSquareAvoid = max(peaksSquareAvoid(peaksSquareAvoid>0));
    
    peaksNeutApp = peaksCircApp + peaksSquareApp;
    peaksNeutAvoid = peaksCircAvoid + peaksSquareAvoid;
    meanPeaksNeutApp = mean(peaksNeutApp(peaksNeutApp>0),'omitnan');
    stdPeaksNeutApp = nanstd(peaksNeutApp(peaksNeutApp>0));
    minPeaksNeutApp = min(peaksNeutApp(peaksNeutApp>0));
    maxPeaksNeutApp = max(peaksNeutApp(peaksNeutApp>0));
    meanPeaksNeutAvoid = mean(peaksNeutAvoid(peaksNeutAvoid>0),'omitnan');
    stdPeaksNeutAvoid = nanstd(peaksNeutAvoid(peaksNeutAvoid>0));
    minPeaksNeutAvoid = min(peaksNeutAvoid(peaksNeutAvoid>0));
    maxPeaksNeutAvoid = max(peaksNeutAvoid(peaksNeutAvoid>0));
    
    %error rate
    errorCircApp = errorArray.*(blockCircle+trialCircle>1);
    errorSquareApp = errorArray.*(blockSquare+trialSquare>1);
    errorCircAvoid = errorArray.*(blockCircle+trialSquare>1);
    errorSquareAvoid = errorArray.*(blockSquare+trialCircle>1);
    errRateCircApp = sum(errorCircApp(errorCircApp>0));
    errRateSquareApp = sum(errorSquareApp(errorSquareApp>0));
    errRateCircAvoid = sum(errorCircAvoid(errorCircAvoid>0));
    errRateSquareAvoid = sum(errorSquareAvoid(errorSquareAvoid>0));
    stdErrorCircApp = nanstd(errorCircApp(errorCircApp>0));
    stdErrorSquareApp = nanstd(errorSquareApp(errorSquareApp>0));
    stdErrorCircAvoid = nanstd(errorCircAvoid(errorCircAvoid>0));
    stdErrorSquareAvoid = nanstd(errorSquareAvoid(errorSquareAvoid>0));
    
    errorNeutApp = errorCircApp + errorSquareApp;
    errorNeutAvoid = errorCircAvoid + errorSquareAvoid;
    meanErrorNeutApp = sum(errorNeutApp(errorNeutApp>0),'omitnan')/(sum(blockCircle)+sum(blockSquare));
    stdErrorNeutApp = nanstd(errorNeutApp((blockCircle.*trialCircle+blockSquare.*trialSquare)>0));
    minErrorNeutApp = min(errorNeutApp(errorNeutApp>0));
    maxErrorNeutApp = max(errorNeutApp(errorNeutApp>0));
    meanErrorNeutAvoid = sum(errorNeutAvoid(errorNeutAvoid>0),'omitnan')/(sum(blockCircle)+sum(blockSquare));
    stdErrorNeutAvoid = nanstd(errorNeutAvoid((blockCircle.*trialSquare+blockSquare.*trialCircle)>0));
    minErrorNeutAvoid = min(errorNeutAvoid(errorNeutAvoid>0));
    maxErrorNeutAvoid = max(errorNeutAvoid(errorNeutAvoid>0));
    
    %% active seden
    blockActive = strcmp(excelIn{i}(2:end,blockType),'ACTIVE');
    blockSeden = strcmp(excelIn{i}(2:end,blockType),'SEDEN');
    trialActive = strcmp(excelIn{i}(2:end,trialType),'ACTIVE');
    trialSeden = strcmp(excelIn{i}(2:end,trialType),'SEDEN');
    
    %reaction time
    rtActiveApp = rtArray.*(blockActive+trialActive>1);
    rtSedenApp = rtArray.*(blockSeden+trialSeden>1);
    rtActiveAvoid = rtArray.*(blockActive+trialSeden>1);
    rtSedenAvoid = rtArray.*(blockSeden+trialActive>1);
    meanRTActiveApp = mean(rtActiveApp(rtActiveApp>0),'omitnan');
    stdRTActiveApp = nanstd(rtActiveApp(rtActiveApp>0));
    minRTActiveApp = min(rtActiveApp(rtActiveApp>0));
    maxRTActiveApp = max(rtActiveApp(rtActiveApp>0));
    meanRTSedenApp = mean(rtSedenApp(rtSedenApp>0),'omitnan');
    stdRTSedenApp = nanstd(rtSedenApp(rtSedenApp>0));
    minRTSedenApp = min(rtSedenApp(rtSedenApp>0));
    maxRTSedenApp = max(rtSedenApp(rtSedenApp>0));
    meanRTActiveAvoid = mean(rtActiveAvoid(rtActiveAvoid>0),'omitnan');
    stdRTActiveAvoid = nanstd(rtActiveAvoid(rtActiveAvoid>0));
    minRTActiveAvoid = min(rtActiveAvoid(rtActiveAvoid>0));
    maxRTActiveAvoid = max(rtActiveAvoid(rtActiveAvoid>0));
    meanRTSedenAvoid = mean(rtSedenAvoid(rtSedenAvoid>0),'omitnan');
    stdRTSedenAvoid = nanstd(rtSedenAvoid(rtSedenAvoid>0));
    minRTSedenAvoid = min(rtSedenAvoid(rtSedenAvoid>0));
    maxRTSedenAvoid = max(rtSedenAvoid(rtSedenAvoid>0));
    
    %max speed
    speedActiveApp = speedArray.*(blockActive+trialActive>1);
    speedSedenApp = speedArray.*(blockSeden+trialSeden>1);
    speedActiveAvoid = speedArray.*(blockActive+trialSeden>1);
    speedSedenAvoid = speedArray.*(blockSeden+trialActive>1);
    meanSpeedActiveApp = mean(speedActiveApp(speedActiveApp>0),'omitnan');
    stdSpeedActiveApp = nanstd(speedActiveApp(speedActiveApp>0));
    minSpeedActiveApp = min(speedActiveApp(speedActiveApp>0));
    maxSpeedActiveApp = max(speedActiveApp(speedActiveApp>0));
    meanSpeedSedenApp = mean(speedSedenApp(speedSedenApp>0),'omitnan');
    stdSpeedSedenApp = nanstd(speedSedenApp(speedSedenApp>0));
    minSpeedSedenApp = min(speedSedenApp(speedSedenApp>0));
    maxSpeedSedenApp = max(speedSedenApp(speedSedenApp>0));
    meanSpeedActiveAvoid = mean(speedActiveAvoid(speedActiveAvoid>0),'omitnan');
    stdSpeedActiveAvoid = nanstd(speedActiveAvoid(speedActiveAvoid>0));
    minSpeedActiveAvoid = min(speedActiveAvoid(speedActiveAvoid>0));
    maxSpeedActiveAvoid = max(speedActiveAvoid(speedActiveAvoid>0));
    meanSpeedSedenAvoid = mean(speedSedenAvoid(speedSedenAvoid>0),'omitnan');
    stdSpeedSedenAvoid = nanstd(speedSedenAvoid(speedSedenAvoid>0));
    minSpeedSedenAvoid = min(speedSedenAvoid(speedSedenAvoid>0));
    maxSpeedSedenAvoid = max(speedSedenAvoid(speedSedenAvoid>0));
    
    %max accel
    accelActiveApp = accelArray.*(blockActive+trialActive>1);
    accelSedenApp = accelArray.*(blockSeden+trialSeden>1);
    accelActiveAvoid = accelArray.*(blockActive+trialSeden>1);
    accelSedenAvoid = accelArray.*(blockSeden+trialActive>1);
    meanAccelActiveApp = mean(accelActiveApp(accelActiveApp>0),'omitnan');
    stdAccelActiveApp = nanstd(accelActiveApp(accelActiveApp>0));
    minAccelActiveApp = min(accelActiveApp(accelActiveApp>0));
    maxAccelActiveApp = max(accelActiveApp(accelActiveApp>0));
    meanAccelSedenApp = mean(accelSedenApp(accelSedenApp>0),'omitnan');
    stdAccelSedenApp = nanstd(accelSedenApp(accelSedenApp>0));
    minAccelSedenApp = min(accelSedenApp(accelSedenApp>0));
    maxAccelSedenApp = max(accelSedenApp(accelSedenApp>0));
    meanAccelActiveAvoid = mean(accelActiveAvoid(accelActiveAvoid>0),'omitnan');
    stdAccelActiveAvoid = nanstd(accelActiveAvoid(accelActiveAvoid>0));
    minAccelActiveAvoid = min(accelActiveAvoid(accelActiveAvoid>0));
    maxAccelActiveAvoid = max(accelActiveAvoid(accelActiveAvoid>0));
    meanAccelSedenAvoid = mean(accelSedenAvoid(accelSedenAvoid>0),'omitnan');
    stdAccelSedenAvoid = nanstd(accelSedenAvoid(accelSedenAvoid>0));
    minAccelSedenAvoid = min(accelSedenAvoid(accelSedenAvoid>0));
    maxAccelSedenAvoid = max(accelSedenAvoid(accelSedenAvoid>0));
    
    %speed peaks
    peaksActiveApp = peaksArray.*(blockActive+trialActive>1);
    peaksSedenApp = peaksArray.*(blockSeden+trialSeden>1);
    peaksActiveAvoid = peaksArray.*(blockActive+trialSeden>1);
    peaksSedenAvoid = peaksArray.*(blockSeden+trialActive>1);
    meanPeaksActiveApp = mean(peaksActiveApp(peaksActiveApp>0),'omitnan');
    stdPeaksActiveApp = nanstd(peaksActiveApp(peaksActiveApp>0));
    minPeaksActiveApp = min(peaksActiveApp(peaksActiveApp>0));
    maxPeaksActiveApp = max(peaksActiveApp(peaksActiveApp>0));
    meanPeaksSedenApp = mean(peaksSedenApp(peaksSedenApp>0),'omitnan');
    stdPeaksSedenApp = nanstd(peaksSedenApp(peaksSedenApp>0));
    minPeaksSedenApp = min(peaksSedenApp(peaksSedenApp>0));
    maxPeaksSedenApp = max(peaksSedenApp(peaksSedenApp>0));
    meanPeaksActiveAvoid = mean(peaksActiveAvoid(peaksActiveAvoid>0),'omitnan');
    stdPeaksActiveAvoid = nanstd(peaksActiveAvoid(peaksActiveAvoid>0));
    minPeaksActiveAvoid = min(peaksActiveAvoid(peaksActiveAvoid>0));
    maxPeaksActiveAvoid = max(peaksActiveAvoid(peaksActiveAvoid>0));
    meanPeaksSedenAvoid = mean(peaksSedenAvoid(peaksSedenAvoid>0),'omitnan');
    stdPeaksSedenAvoid = nanstd(peaksSedenAvoid(peaksSedenAvoid>0));
    minPeaksSedenAvoid = min(peaksSedenAvoid(peaksSedenAvoid>0));
    maxPeaksSedenAvoid = max(peaksSedenAvoid(peaksSedenAvoid>0));
    
    %error rate
    errorActiveApp = errorArray.*(blockActive+trialActive>1);
    errorSedenApp = errorArray.*(blockSeden+trialSeden>1);
    errorActiveAvoid = errorArray.*(blockActive+trialSeden>1);
    errorSedenAvoid = errorArray.*(blockSeden+trialActive>1);
    errRateActiveApp = sum(errorActiveApp(errorActiveApp>0));
    errRateSedenApp = sum(errorSedenApp(errorSedenApp>0));
    errRateActiveAvoid = sum(errorActiveAvoid(errorActiveAvoid>0));
    errRateSedenAvoid = sum(errorSedenAvoid(errorSedenAvoid>0));
    stdErrorActiveApp = nanstd(errorActiveApp((blockActive.*trialActive)>0));
    stdErrorSedenApp = nanstd(errorSedenApp((blockSeden.*trialSeden)>0));
    stdErrorActiveAvoid = nanstd(errorActiveAvoid((blockActive.*trialSeden)>0));
    stdErrorSedenAvoid = nanstd(errorSedenAvoid((blockSeden.*trialActive)>0));
    
    meanErrorActiveApp = sum(errorActiveApp(errorActiveApp>0),'omitnan')/(sum(blockCircle)+sum(blockSquare));
    meanErrorActiveAvoid = sum(errorActiveAvoid(errorActiveAvoid>0),'omitnan')/(sum(blockCircle)+sum(blockSquare));
    meanErrorSedenApp = sum(errorSedenApp(errorSedenApp>0),'omitnan')/(sum(blockCircle)+sum(blockSquare));
    meanErrorSedenAvoid = sum(errorSedenAvoid(errorSedenAvoid>0),'omitnan')/(sum(blockCircle)+sum(blockSquare));
    
    %% output variable for excel
    groupAnalysis(i).ID = excelIn{i}{2,1};
    
    %rt approach 
    groupAnalysis(i).RTActiveApp = meanRTActiveApp;
    groupAnalysis(i).RTActiveAppSD = stdRTActiveApp;
    groupAnalysis(i).RTActiveAppMin = minRTActiveApp;
    groupAnalysis(i).RTActiveAppMax = maxRTActiveApp;
    groupAnalysis(i).RTSedenApp = meanRTSedenApp;
    groupAnalysis(i).RTSedenAppSD = stdRTSedenApp;
    groupAnalysis(i).RTSedenAppMin = minRTSedenApp;
    groupAnalysis(i).RTSedenAppMax = maxRTSedenApp;
    groupAnalysis(i).RTNeutApp = meanRTNeutApp;
    groupAnalysis(i).RTNeutAppSD = stdRTNeutApp;
    groupAnalysis(i).RTNeutAppMin = minRTNeutApp;
    groupAnalysis(i).RTNeutAppMax = maxRTNeutApp;
    groupAnalysis(i).RTActiveAppRelative = meanRTActiveApp-meanRTNeutApp;
    groupAnalysis(i).RTSedenAppRelative = meanRTSedenApp-meanRTNeutApp;
%     groupAnalysis(i).RTCircApp = meanRTCircApp;
%     groupAnalysis(i).RTCircAppSD = stdRTCircApp;
%     groupAnalysis(i).RTCircAppMin = minRTCircApp;
%     groupAnalysis(i).RTCircAppMax = maxRTCircApp;
%     groupAnalysis(i).RTSquareApp = meanRTSquareApp;
%     groupAnalysis(i).RTSquareAppSD = stdRTSquareApp;
%     groupAnalysis(i).RTSquareAppMin = minRTSquareApp;
%     groupAnalysis(i).RTSquareAppMax = maxRTSquareApp;

    %rt avoid
    groupAnalysis(i).RTActiveAvoid = meanRTActiveAvoid;
    groupAnalysis(i).RTActiveAvoidSD = stdRTActiveAvoid;
    groupAnalysis(i).RTActiveAvoidMin = minRTActiveAvoid;
    groupAnalysis(i).RTActiveAvoidMax = maxRTActiveAvoid;
    groupAnalysis(i).RTSedenAvoid = meanRTSedenAvoid;
    groupAnalysis(i).RTSedenAvoidSD = stdRTSedenAvoid;
    groupAnalysis(i).RTSedenAvoidMin = minRTSedenAvoid;
    groupAnalysis(i).RTSedenAvoidMax = maxRTSedenAvoid;
    groupAnalysis(i).RTNeutAvoid = meanRTNeutAvoid;
    groupAnalysis(i).RTNeutAvoidSD = stdRTNeutAvoid;
    groupAnalysis(i).RTNeutAvoidMin = minRTNeutAvoid;
    groupAnalysis(i).RTNeutAvoidMax = maxRTNeutAvoid;
    groupAnalysis(i).RTActiveAvoidRelative = meanRTActiveAvoid-meanRTNeutAvoid;
    groupAnalysis(i).RTSedenAvoidRelative = meanRTSedenAvoid-meanRTNeutAvoid;
%     groupAnalysis(i).RTCircAvoid = meanRTCircAvoid;
%     groupAnalysis(i).RTCircAvoidSD = stdRTCircAvoid;
%     groupAnalysis(i).RTCircAvoidMin = minRTCircAvoid;
%     groupAnalysis(i).RTCircAvoidMax = maxRTCircAvoid;
%     groupAnalysis(i).RTSquareAvoid = meanRTSquareAvoid;
%     groupAnalysis(i).RTSquareAvoidSD = stdRTSquareAvoid;
%     groupAnalysis(i).RTSquareAvoidMin = minRTSquareAvoid;
%     groupAnalysis(i).RTSquareAvoidMax = maxRTSquareAvoid;
    
    %speed approach
    groupAnalysis(i).speedActiveApp = meanSpeedActiveApp;
    groupAnalysis(i).speedActiveAppSD = stdSpeedActiveApp;
    groupAnalysis(i).speedActiveAppMin = minSpeedActiveApp;
    groupAnalysis(i).speedActiveAppMax = maxSpeedActiveApp;
    groupAnalysis(i).speedSedenApp = meanSpeedSedenApp;
    groupAnalysis(i).speedSedenAppSD = stdSpeedSedenApp;
    groupAnalysis(i).speedSedenAppMin = minSpeedSedenApp;
    groupAnalysis(i).speedSedenAppMax = maxSpeedSedenApp;
    groupAnalysis(i).speedNeutApp = meanSpeedNeutApp;
    groupAnalysis(i).speedNeutAppSD = stdSpeedNeutApp;
    groupAnalysis(i).speedNeutAppMin = minSpeedNeutApp;
    groupAnalysis(i).speedNeutAppMax = maxSpeedNeutApp;
    groupAnalysis(i).speedActiveAppRelative = meanSpeedActiveApp-meanSpeedNeutApp;
    groupAnalysis(i).speedSedenAppRelative = meanSpeedSedenApp-meanSpeedNeutApp;
%     groupAnalysis(i).speedCircApp = meanSpeedCircApp;
%     groupAnalysis(i).speedCircAppSD = stdSpeedCircApp;
%     groupAnalysis(i).speedCircAppMin = minSpeedCircApp;
%     groupAnalysis(i).speedCircAppMax = maxSpeedCircApp;
%     groupAnalysis(i).speedSquareApp = meanSpeedSquareApp;
%     groupAnalysis(i).speedSquareAppSD = stdSpeedSquareApp;
%     groupAnalysis(i).speedSquareAppMin = minSpeedSquareApp;
%     groupAnalysis(i).speedSquareAppMax = maxSpeedSquareApp;

    %speed avoid
    groupAnalysis(i).speedActiveAvoid = meanSpeedActiveAvoid;
    groupAnalysis(i).speedActiveAvoidSD = stdSpeedActiveAvoid;
    groupAnalysis(i).speedActiveAvoidMin = minSpeedActiveAvoid;
    groupAnalysis(i).speedActiveAvoidMax = maxSpeedActiveAvoid;
    groupAnalysis(i).speedSedenAvoid = meanSpeedSedenAvoid;
    groupAnalysis(i).speedSedenAvoidSD = stdSpeedSedenAvoid;
    groupAnalysis(i).speedSedenAvoidMin = minSpeedSedenAvoid;
    groupAnalysis(i).speedSedenAvoidMax = maxSpeedSedenAvoid;
    groupAnalysis(i).speedNeutAvoid = meanSpeedNeutAvoid;
    groupAnalysis(i).speedNeutAvoidSD = stdSpeedNeutAvoid;
    groupAnalysis(i).speedNeutAvoidMin = minSpeedNeutAvoid;
    groupAnalysis(i).speedNeutAvoidMax = maxSpeedNeutAvoid;
    groupAnalysis(i).speedActiveAvoidRelative = meanSpeedActiveAvoid-meanSpeedNeutAvoid;
    groupAnalysis(i).speedSedenAvoidRelative = meanSpeedSedenAvoid-meanSpeedNeutAvoid;
%     groupAnalysis(i).speedCircAvoid = meanSpeedCircAvoid;
%     groupAnalysis(i).speedCircAvoidSD = stdSpeedCircAvoid;
%     groupAnalysis(i).speedCircAvoidMin = minSpeedCircAvoid;
%     groupAnalysis(i).speedCircAvoidMax = maxSpeedCircAvoid;
%     groupAnalysis(i).speedSquareAvoid = meanSpeedSquareAvoid;
%     groupAnalysis(i).speedSquareAvoidSD = stdSpeedSquareAvoid;
%     groupAnalysis(i).speedSquareAvoidMin = minSpeedSquareAvoid;
%     groupAnalysis(i).speedSquareAvoidMax = maxSpeedSquareAvoid;

	%accel approach
    groupAnalysis(i).accelActiveApp = meanAccelActiveApp;
    groupAnalysis(i).accelActiveAppSD = stdAccelActiveApp;
    groupAnalysis(i).accelActiveAppMin = minAccelActiveApp;
    groupAnalysis(i).accelActiveAppMax = maxAccelActiveApp;
    groupAnalysis(i).accelSedenApp = meanAccelSedenApp;
    groupAnalysis(i).accelSedenAppSD = stdAccelSedenApp;
    groupAnalysis(i).accelSedenAppMin = minAccelSedenApp;
    groupAnalysis(i).accelSedenAppMax = maxAccelSedenApp;
    groupAnalysis(i).accelNeutApp = meanAccelNeutApp;
    groupAnalysis(i).accelNeutAppSD = stdAccelNeutApp;
    groupAnalysis(i).accelNeutAppMin = minAccelNeutApp;
    groupAnalysis(i).accelNeutAppMax = maxAccelNeutApp;
    groupAnalysis(i).accelActiveAppRelative = meanAccelActiveApp-meanAccelNeutApp;
    groupAnalysis(i).accelSedenAppRelative = meanAccelSedenApp-meanAccelNeutApp;
%     groupAnalysis(i).accelCircApp = meanAccelCircApp;
%     groupAnalysis(i).accelCircAppSD = stdAccelCircApp;
%     groupAnalysis(i).accelCircAppMin = minAccelCircApp;
%     groupAnalysis(i).accelCircAppMax = maxAccelCircApp;
%     groupAnalysis(i).accelSquareApp = meanAccelSquareApp;
%     groupAnalysis(i).accelSquareAppSD = stdAccelSquareApp;
%     groupAnalysis(i).accelSquareAppMin = minAccelSquareApp;
%     groupAnalysis(i).accelSquareAppMax = maxAccelSquareApp;

    %accel avoid
    groupAnalysis(i).accelActiveAvoid = meanAccelActiveAvoid;
    groupAnalysis(i).accelActiveAvoidSD = stdAccelActiveAvoid;
    groupAnalysis(i).accelActiveAvoidMin = minAccelActiveAvoid;
    groupAnalysis(i).accelActiveAvoidMax = maxAccelActiveAvoid;
    groupAnalysis(i).accelSedenAvoid = meanAccelSedenAvoid;
    groupAnalysis(i).accelSedenAvoidSD = stdAccelSedenAvoid;
    groupAnalysis(i).accelSedenAvoidMin = minAccelSedenAvoid;
    groupAnalysis(i).accelSedenAvoidMax = maxAccelSedenAvoid;
    groupAnalysis(i).accelNeutAvoid = meanAccelNeutAvoid;
    groupAnalysis(i).accelNeutAvoidSD = stdAccelNeutAvoid;
    groupAnalysis(i).accelNeutAvoidMin = minAccelNeutAvoid;
    groupAnalysis(i).accelNeutAvoidMax = maxAccelNeutAvoid;
    groupAnalysis(i).accelActiveAvoidRelative = meanAccelActiveAvoid-meanAccelNeutAvoid;
    groupAnalysis(i).accelSedenAvoidRelative = meanAccelSedenAvoid-meanAccelNeutAvoid;
%     groupAnalysis(i).accelCircAvoid = meanAccelCircAvoid;
%     groupAnalysis(i).accelCircAvoidSD = stdAccelCircAvoid;
%     groupAnalysis(i).accelCircAvoidMin = minAccelCircAvoid;
%     groupAnalysis(i).accelCircAvoidMax = maxAccelCircAvoid;
%     groupAnalysis(i).accelSquareAvoid = meanAccelSquareAvoid;
%     groupAnalysis(i).accelSquareAvoidSD = stdAccelSquareAvoid;
%     groupAnalysis(i).accelSquareAvoidMin = minAccelSquareAvoid;
%     groupAnalysis(i).accelSquareAvoidMax = maxAccelSquareAvoid;
    
    %peaks approach
    groupAnalysis(i).peaksActiveApp = meanPeaksActiveApp;
    groupAnalysis(i).peaksActiveAppSD = stdPeaksActiveApp;
    groupAnalysis(i).peaksActiveAppMin = minPeaksActiveApp;
    groupAnalysis(i).peaksActiveAppMax = maxPeaksActiveApp;
    groupAnalysis(i).peaksSedenApp = meanPeaksSedenApp;
    groupAnalysis(i).peaksSedenAppSD = stdPeaksSedenApp;
    groupAnalysis(i).peaksSedenAppMin = minPeaksSedenApp;
    groupAnalysis(i).peaksSedenAppMax = maxPeaksSedenApp;
    groupAnalysis(i).peaksNeutApp = meanPeaksNeutApp;
    groupAnalysis(i).peaksNeutAppSD = stdPeaksNeutApp;
    groupAnalysis(i).peaksNeutAppMin = minPeaksNeutApp;
    groupAnalysis(i).peaksNeutAppMax = maxPeaksNeutApp;
    groupAnalysis(i).peaksActiveAppRelative = meanPeaksActiveApp-meanPeaksNeutApp;
    groupAnalysis(i).peaksSedenAppRelative = meanPeaksSedenApp-meanPeaksNeutApp;
%     groupAnalysis(i).peaksCircApp = meanPeaksCircApp;
%     groupAnalysis(i).peaksCircAppSD = stdPeaksCircApp;
%     groupAnalysis(i).peaksCircAppMin = minPeaksCircApp;
%     groupAnalysis(i).peaksCircAppMax = maxPeaksCircApp;
%     groupAnalysis(i).peaksSquareApp = meanPeaksSquareApp;
%     groupAnalysis(i).peaksSquareAppSD = stdPeaksSquareApp;
%     groupAnalysis(i).peaksSquareAppMin = minPeaksSquareApp;
%     groupAnalysis(i).peaksSquareAppMax = maxPeaksSquareApp;
    %peaks avoid
    groupAnalysis(i).peaksActiveAvoid = meanPeaksActiveAvoid;
    groupAnalysis(i).peaksActiveAvoidSD = stdPeaksActiveAvoid;
    groupAnalysis(i).peaksActiveAvoidMin = minPeaksActiveAvoid;
    groupAnalysis(i).peaksActiveAvoidMax = maxPeaksActiveAvoid;
    groupAnalysis(i).peaksSedenAvoid = meanPeaksSedenAvoid;
    groupAnalysis(i).peaksSedenAvoidSD = stdPeaksSedenAvoid;
    groupAnalysis(i).peaksSedenAvoidMin = minPeaksSedenAvoid;
    groupAnalysis(i).peaksSedenAvoidMax = maxPeaksSedenAvoid;
    groupAnalysis(i).peaksNeutAvoid = meanPeaksNeutAvoid;
    groupAnalysis(i).peaksNeutAvoidSD = stdPeaksNeutAvoid;
    groupAnalysis(i).peaksNeutAvoidMin = minPeaksNeutAvoid;
    groupAnalysis(i).peaksNeutAvoidMax = maxPeaksNeutAvoid;
    groupAnalysis(i).peaksActiveAvoidRelative = meanPeaksActiveAvoid-meanPeaksNeutAvoid;
    groupAnalysis(i).peaksSedenAvoidRelative = meanPeaksSedenAvoid-meanPeaksNeutAvoid;
%     groupAnalysis(i).peaksCircAvoid = meanPeaksCircAvoid;
%     groupAnalysis(i).peaksCircAvoidSD = stdPeaksCircAvoid;
%     groupAnalysis(i).peaksCircAvoidMin = minPeaksCircAvoid;
%     groupAnalysis(i).peaksCircAvoidMax = maxPeaksCircAvoid;
%     groupAnalysis(i).peaksSquareAvoid = meanPeaksSquareAvoid;
%     groupAnalysis(i).peaksSquareAvoidSD = stdPeaksSquareAvoid;
%     groupAnalysis(i).peaksSquareAvoidMin = minPeaksSquareAvoid;
%     groupAnalysis(i).peaksSquareAvoidMax = maxPeaksSquareAvoid;
    
    %error numbers
    %approach
    groupAnalysis(i).errRateActiveApp = meanErrorActiveApp;
    groupAnalysis(i).errSDActiveApp = stdErrorActiveApp;
    groupAnalysis(i).errRateSedenApp = meanErrorSedenApp;
    groupAnalysis(i).errSDSedenApp = stdErrorSedenApp;
    groupAnalysis(i).errRateNeutApp = meanErrorNeutApp;
    groupAnalysis(i).errSDNeutApp = stdErrorNeutApp;
    
%     groupAnalysis(i).errRateCircApp = errRateCircApp/100;
%     groupAnalysis(i).errRateSquareApp = errRateSquareApp/100;
    
    groupAnalysis(i).errRateActiveAvoid = meanErrorActiveAvoid;
    groupAnalysis(i).errSDActiveAvoid = stdErrorActiveAvoid;
    groupAnalysis(i).errRateSedenAvoid = meanErrorSedenAvoid;
    groupAnalysis(i).errSDSedenAvoid = stdErrorSedenAvoid;
    groupAnalysis(i).errRateNeutAvoid = meanErrorNeutAvoid;
    groupAnalysis(i).errSDNeutAvoid = stdErrorNeutAvoid;
    
%     groupAnalysis(i).errRateCircAvoid = errRateCircAvoid/100;
%     groupAnalysis(i).errRateSquareAvoid = errRateSquareAvoid/100;
    
    %total trials
    groupAnalysis(i).totalTrials = length(excelIn{i})-1;

end

preSaveFolder = pwd;
folderPath = fullfile(preSaveFolder,'groupAnalysisUpdate.xlsx');
writetable(struct2table(groupAnalysis),folderPath);

%% todo

% something is weird with the error rate 
