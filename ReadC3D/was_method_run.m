function was_run=was_method_run(trials, method_name, required)

    was_run = false;
    
    if isfield(trials(1), 'methods')
        index = find(strcmp(trials(1).methods, method_name), 1);
        was_run = ~isempty(index);
    end
    
    if required ~= was_run
        
        stack = dbstack;   
        calling_method_name = stack(2).name;
        
        if required
            warning('%s requires %s to be run first, but it was not.', calling_method_name, method_name);
        else
            warning('%s should not have %s run first, but it was.', calling_method_name, method_name);
        end
    end
end