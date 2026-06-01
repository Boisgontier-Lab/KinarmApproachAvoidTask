function xFlips = findXFlips(speedX,speedY,reachSpot,appAvoid,i,j)

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
    
    startX = speedX(1);
    startY = speedY(1);

    endX = speedX(end);
    endY = speedY(end);

    lineRot = [linspace(startX,endX,size(speedX,1))' linspace(startY,endY,size(speedY,1))']*[cosd(reachAngle) -sind(reachAngle) ;sind(reachAngle) cosd(reachAngle)];
    dataRot = [speedX speedY]*[cosd(reachAngle) -sind(reachAngle) ;sind(reachAngle) cosd(reachAngle)];
    diffLine = abs(dataRot(:,2)-lineRot(1,2));

    xFlips = size(find((dataRot(1:end-1,1)>0) == (dataRot(2:end,1)<0)),1);
    if (i == 1 && j == 65)
        k = 1;
    end
else
    xFlips = nan;
end