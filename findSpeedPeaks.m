function speedPeaks = findSpeedPeaks(speed)

[peaks] = findpeaks(speed);

speedPeaks = length(peaks);