function mad = findMaxAbDev(dataX,dataY,reachSpot,appAvoid,i,j)
%flatten hand path to the x-axis and then check maximum vertical deviation

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
    maxReachDist = hypot(dataX(end)-dataX(1),dataY(end)-dataY(1));
    startX = dataX(1);
    startY = dataY(1);

    endX = startX+maxReachDist*cosd(reachAngle);
    endY = startY+maxReachDist*sind(reachAngle);

    lineRot = [linspace(startX,endX,size(dataX,1))' linspace(startY,endY,size(dataY,1))']*[cosd(reachAngle) -sind(reachAngle) ;sind(reachAngle) cosd(reachAngle)];
    dataRot = [dataX dataY]*[cosd(reachAngle) -sind(reachAngle) ;sind(reachAngle) cosd(reachAngle)];
    diffLine = abs(dataRot(:,2)-lineRot(1,2));
    mad = max(diffLine)*100;
else
    mad = nan;
end