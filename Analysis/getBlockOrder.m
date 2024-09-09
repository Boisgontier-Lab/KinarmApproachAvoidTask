function getBlockOrder

findSeq = extractAfter(data{i}(1).EVENTS.LABELS(1),'SEQ_');
if (str2num(findSeq{1}) == 1) %sandwich sequence 1
    blockCond{1} = {'Circle','Approach'};
    blockCond{2} = {'Active','Approach'};
    blockCond{3} = {'Seden','Approach'};
    blockCond{4} = {'Square','Approach'};
elseif (str2num(findSeq{1}) == 2) %sandwich sequence 2
    blockCond{1} = {'Square','Approach'};
    blockCond{2} = {'Active','Approach'};
    blockCond{3} = {'Seden','Approach'};
    blockCond{4} = {'Circle','Approach'};
elseif (str2num(findSeq{1}) == 3) %sandwich sequence 3
    blockCond{1} = {'Circle','Approach'};
    blockCond{2} = {'Seden','Approach'};
    blockCond{3} = {'Active','Approach'};
    blockCond{4} = {'Square','Approach'};
else %sandwich sequence 4
    blockCond{1} = {'Square','Approach'};
    blockCond{2} = {'Seden','Approach'};
    blockCond{3} = {'Active','Approach'};
    blockCond{4} = {'Circle','Approach'};
end