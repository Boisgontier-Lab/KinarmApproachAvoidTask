function speedPeaks = findSpeedPeaks(speed,j)
%get the number of peaks in hand speed
%there is a 25% max speed threshold to identify peaks in hand speed and
%filter out very small speed peaks
%a reach to a single target should only have 1 peak in hand speed

[peaks] = findpeaks(speed); %get speed peaks
maxSpeed = max(speed);
if (maxSpeed>max(peaks)) %check if max speed is not a peak
    peaks = [peaks; maxSpeed]; %add max speed as a peak if it is not one
end
speedThresh = 0.25*maxSpeed; %set a threshold for speed peaks
speedPeaks = sum(peaks>speedThresh); %get the total speed peaks count
if (speedPeaks == 0) %there should be at least one speed peak
    error()
end