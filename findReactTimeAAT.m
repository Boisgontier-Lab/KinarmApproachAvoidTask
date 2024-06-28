function reactTime = findReactTimeAAT(speed,accel)

% accel = dataAccel(targetOnTime(j):trialEndTime(j));
% speed = dataSpeed(targetOnTime(j):trialEndTime(j));

reactTime = 0;
counter = 1;

[peaks,peakTimes] = findpeaks(speed);
maxSpeed = max(speed);
if (maxSpeed > max(peaks))
    peakSpeed = maxSpeed;
    maxPeakTime = find(speed == peakSpeed);
else
    peakSpeed = max(peaks);
    maxPeakTime = peakTimes(find(peaks == peakSpeed));
end

reactTimeThresh = 0.1*maxSpeed;

for (i = maxPeakTime:-1:1)
    if (speed(i)<reactTimeThresh)
        reactTimeArray(counter) = i;
        counter = counter + 1;
    end
end
reactTime = reactTimeArray(1);
if (reactTime < 200)
    error()
end