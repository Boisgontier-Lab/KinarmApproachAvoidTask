function trial_out = record_analysis( trials )
%RECORD_ANALYSIS Summary of this function goes here
%   Detailed explanation goes here

    trial_out = trials;
    stack = dbstack;   
    method_name = stack(2).name;
    
    for ii=1:length(trials)
        if isfield(trials(ii), 'methods')
            index = find(strcmp(trials(ii).methods, method_name), 1);
            if ~isempty(index)
                warning('%s has already been performed on the given trial data.', method_name);
%                 break;
            end
        end

        if isfield(trials(ii), 'methods')
            trial_out(ii).methods{end+1} = method_name;
        else
            trial_out(ii).methods = {method_name};
        end  
    end
end

