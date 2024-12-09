function reactTime = findReactTimeAAT(speed,i,j)
%function calculates reaction time based on maximum speed
%function finds the highest speed and moves backwards in time
%the first point in time that the speed is below 10% max speed is the
%reaction time in ms.
%minimum reaction time set to 200ms.

reactTime = 0;
counter = 1;

[peaks,peakTimes] = findpeaks(speed);
maxSpeed = max(speed);
if (maxSpeed > max(peaks)) %check if max speed is not a peak
    peakSpeed = maxSpeed; %set max speed to this non peak time
    maxPeakTime = find(speed == peakSpeed);
else %if maxspeed is a peak
    peakSpeed = max(peaks); %set max speed to this peak
    maxPeakTime = peakTimes(find(peaks == peakSpeed));
end

reactTimeThresh = 0.1*maxSpeed; %threshold

for (z = maxPeakTime:-1:1) %move back in time
    if (speed(z)<reactTimeThresh) %find points when speed is less than threshold
        reactTimeArray(counter) = z;
        counter = counter + 1;
    end
end
reactTime = reactTimeArray(1); %use first instance of speed below threshold to be reaction time
if (reactTime < 200) %reaction time should not be under 200 or else participant anticipated movement
    reactTime = nan;
end