function speedPeaks = findSpeedPeaks(speed,i,j,reactTime,onTime,maxSpeedTime)
%get the number of speed peaks greater than 10% of maximum speed
if (isempty(speed))
    kk = 1;
end

[peaks] = findpeaks(speed);
maxSpeed = max(speed);
if (maxSpeed>max(peaks))
    peaks = [peaks; maxSpeed];
end
if (isempty(peaks))
    peaks = maxSpeed;
end
speedThresh = 0.10*maxSpeed;
speedPeaks = sum(peaks>speedThresh);
% if (i == 1 && j == 104)
%     kk = 1;
% end
if (speedPeaks == 0)
    error()
end