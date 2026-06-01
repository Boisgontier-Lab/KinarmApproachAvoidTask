function oppDist = findOppDistAAT(dataX,dataY,reachSpot,appAvoid,i,j)

oppDist = 0;

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

    dataRot = [dataX dataY]*[cosd(reachAngle) -sind(reachAngle) ;sind(reachAngle) cosd(reachAngle)];
    
    oppDist = (dataRot(1,1)-min(dataRot(:,1)))*100;
    if (i == 1 && j == 11)
        k = 1;
    end
else
    oppDist = nan;
end
