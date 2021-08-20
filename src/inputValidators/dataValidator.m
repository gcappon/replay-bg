function valid = dataValidator(data)
% function  dataValidator(data)
% Validates the input parameter 'data'.
%
% Inputs:
%   - data;
% Outputs:
%   - valid: a boolean defining if the input parameter is valid. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    valid = istimetable(data);
    
    if(~valid)
        error('Must be a timetable.');
    end
    
    valid = valid && any(strcmp(data.Properties.VariableNames,'glucose'));
    
    if(~valid)
        error("Must contain a column named 'glucose'.");
    end
    
    valid = valid && any(strcmp(data.Properties.VariableNames,'basal'));
    
    if(~valid)
        error("Must contain a column named 'basal'.");
    end
    
    valid = valid && any(strcmp(data.Properties.VariableNames,'bolus'));
    
    if(~valid)
        error("Must contain a column named 'bolus'.");
    end
    
    valid = valid && any(strcmp(data.Properties.VariableNames,'CHO'));
    
    if(~valid)
        error("Must contain a column named 'CHO'.");
    end
    
    valid = valid && ~any(isnan(data.basal));
    
    if(~valid)
        error("'basal' column must not contain NaN values.");
    end
    
    valid = valid && ~any(isnan(data.bolus));
    
    if(~valid)
        error("'bolus' column must not contain NaN values.");
    end
    
    valid = valid && ~any(isnan(data.CHO));
    
    if(~valid)
        error("'CHO' column must not contain NaN values.");
    end
    
    valid = valid && (sum(data.CHO) > 0);
    
    if(~valid)
        error("'CHO' column must not contain only 0 values.");
    end
    
    valid = valid && (sum(data.bolus) > 0);
    
    if(~valid)
        error("'bolus' column must not contain only 0 values.");
    end
    
    %Generate a warning if nan values are present in the glucose column
    if(any(isnan(data.glucose)))
        warning("'glucose' column contains nan values.");
    end
    
end