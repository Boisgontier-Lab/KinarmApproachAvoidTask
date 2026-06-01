function [maxSpeed maxSpeedTime] = findMaxSpeed(speed)
%get maximum speed and time at maximum speed

[maxSpeedTemp, maxSpeedTime] = max(speed);
maxSpeed = round(maxSpeedTemp*100);