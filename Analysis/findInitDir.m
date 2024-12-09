% function initDir = ...
%     findInitDir(xPos,yPos,speed,reachSpot)
j = 7;
dataXPos = data(j).Left_HandX;
dataYPos = data(j).Left_HandY;
speed = dataSpeed(targetOnTime(j):trialEndTime(j));
xPos = dataXPos(targetOnTime(j):trialEndTime(j));
yPos = dataYPos(targetOnTime(j):trialEndTime(j));
reachSpot = reachLoc(j);

angles = [pi/6:pi/6:2*pi];
reachAngle = angles(reachSpot);

[peaks,peakTimes] = findpeaks(speed);
maxPeakTime = peakTimes(find(peaks == max(peaks)));