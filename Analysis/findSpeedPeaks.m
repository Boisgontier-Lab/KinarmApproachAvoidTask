function speedPeaks = findSpeedPeaks(speed,j)

[peaks] = findpeaks(speed);
maxSpeed = max(speed);
if (maxSpeed>max(peaks))
    peaks = [peaks; maxSpeed];
end
speedThresh = 0.25*maxSpeed;
speedPeaks = sum(peaks>speedThresh);
if(speedPeaks == 0)
    error()
end