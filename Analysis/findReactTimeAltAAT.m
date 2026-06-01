function reactTime = findReactTimeAltAAT(accel,i,j)
%reaction time based on first instance that acceleration went from
%1000mm/sec^2 to 200mm/sec^2

accelMax = 1;
accelMin = 0.2;

accelCheck = find(accel>accelMax);
if (isempty(accelCheck))
    [~,accelCheck] = max(accel);
end
firstAcc = accelCheck(1);

accelBot = find(accel<accelMin);
minAcc = accelBot(max(find(accelBot<firstAcc)));

if (i == 2 && j == 6)
    kk = 1;
end

reactTime = minAcc;
if (reactTime < 200)
    reactTime = nan;
end