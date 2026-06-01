function initDir = findInitDir(xPos,yPos,speed,reachSpot,appAvoid,i,j)
%get the angle of the first instance of hand movement which is the first
%large peak

if (~isnan(appAvoid))
    angles = rad2deg([0:pi/6:2*pi-pi/6]);
    reachAngle = (angles(reachSpot));
    if (appAvoid == 1)
        if (reachAngle < 180)
            reachAngle = reachAngle+180;
        else
            reachAngle = reachAngle-180;
        end
    end

    [peaks,peakTimes] = findpeaks(speed);
    tempPeakTime = peakTimes(find(peaks > max(peaks)*0.1));
    highPeakTime = tempPeakTime(tempPeakTime<(max(peakTimes)+1));
    
    for (i = 1:length(highPeakTime))
        peakLocX(i) = xPos(highPeakTime(i))-xPos(1);
        peakLocY(i) = yPos(highPeakTime(i))-yPos(1);
    end

    if (~isempty(length(highPeakTime)))
        dirX = peakLocX(1);
        dirY = peakLocY(1);
    else
        dirX = nan;
        dirY = nan;
    end

    initAngle = atan2d(dirY,dirX);
    if (initAngle < 0)
        initAngle = 360+initAngle;
    end

    initDir = abs(initAngle-reachAngle);
    if (initDir > 180)
        initDir = 360 - initDir;
    end
else
    initDir = nan;
end