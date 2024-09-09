function errorDist = findErrorDist(xPos,yPos,location,targDist,blockType,trialType)
%get the distance the hand travelled in the wrong direction
%find the start point of the hand and the correct target location
%get the maximum distance between the start point and the distance in the
%incorrect direction (i.e if the reach target is at location 1 (east), find
%the distance away from this target (any movement to the west)

radians = [0 pi/6 pi/3 pi/2 2*pi/3 5*pi/6 pi 7*pi/6 4*pi/3 3*pi/2 5*pi/3 11*pi/6];

%check where the hand should move towards
if (strcmp(blockType,trialType) == 1) %check if the trial direction is aligned with block
    reachLoc = location; %get the reach location
else %check if trial direction is misaligned with block
    reachLoc = location+6; %get the avoid location
    if (reachLoc > 12)
        reachLoc = location-6;
    end
end

xStart = xPos(1)*100; %get the start point of the hand once the target shows up
yStart = yPos(1)*100;
xTarg = xStart+targDist*cos(radians(reachLoc)); %get the location of the target on appearance
yTarg = yStart+targDist*sin(radians(reachLoc));

xDif = xPos*100-xTarg; %get the difference between the hand and target
yDif = yPos*100-yTarg;

errorDist = round(max(hypot(xDif,yDif))-targDist,2); %error distance is the distance between hand and target in the wrong direction
