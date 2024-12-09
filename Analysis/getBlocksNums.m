function getBlocksNums

for (j = 1:length(data{i}))
    if (find(contains(data{i}(j).EVENTS.LABELS,'BLOCK_1')))
        block1Start = j;
    elseif (find(contains(data{i}(j).EVENTS.LABELS,'BLOCK_2')))
        block2Start = j;
    elseif (find(contains(data{i}(j).EVENTS.LABELS,'BLOCK_3')))
        block3Start = j;
    elseif (find(contains(data{i}(j).EVENTS.LABELS,'BLOCK_4')))
        block4Start = j;
    end
end

%get trial numbers in blocks
% for (j = (block1Start:block2Start-1))
%     blockArray{1}(j) = data{i}(j).TRIAL.TRIAL_NUM;
% end
% for (j = (block2Start:block3Start-1))
%     blockArray{2}(j-block2Start+1) = data{i}(j).TRIAL.TRIAL_NUM;
% end
% for (j = (block3Start:block4Start-1))
%     blockArray{3}(j-block3Start+1) = data{i}(j).TRIAL.TRIAL_NUM;
% end
% for (j = block4Start:length(data))
%     blockArray{4}(j-block4Start+1) = data{i}(j).TRIAL.TRIAL_NUM;
% end
blockArray{1} = (block1Start:block2Start-1);
blockArray{2} = (block2Start:block3Start-1);
blockArray{3} = (block3Start:block4Start-1);
blockArray{4} = (block4Start:length(data{i}));
blockError = cell(1,4);