function valid = basalSourceValidator(basalSource,data,modality)
% function  basalSourceValidator
% Validates the input parameter 'basalSource'.
%
% Inputs:
%   - basalSource;
%   - data;
%   - modality.
% Outputs:
%   - valid: a boolean defining if the input parameter is valid. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2022 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    expectedBasalSource = {'data','dss'};

    valid = any(validatestring(basalSource,expectedBasalSource));
    if(~valid)
        error("'basalSource' must be 'data' or 'dss'.");
    end
    
    %Check that the user is not trying to set basalSource during
    %identification
    if(strcmp(modality,'identification'))
        
        valid = strcmp(basalSource,'data');
        if(~valid)
            error("'basalSource' cannot be set in 'identification' modality.");
        end
        
    end
    
    %If modality is identification or the bolus is coming from data during replay check that data is ok
    if(strcmp(modality,'identification') || strcmp(basalSource,'data'))

        valid = istimetable(data);

        if(~valid)
            error("'data' must be a timetable.");
        end

        valid = any(strcmp(data.Properties.VariableNames,'basal'));

        if(~valid)
            error("'data' must contain a column named 'basal'.");
        end
        
        valid = ~any(isnan(data.basal));

        if(~valid)
            error("'basal' column of 'data' must not contain NaN values.");
        end

    end
    
end