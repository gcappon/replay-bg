function valid = bolusSourceValidator(bolusSource,data,modality)
% function  bolusSourceValidator(data)
% Validates the input parameter 'bolusSource'.
%
% Inputs:
%   - bolusSource;
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
    
    expectedBolusSources = {'data','dss'};

    valid = any(validatestring(bolusSource,expectedBolusSources));
    if(~valid)
        error("'bolusSource' must be 'data' or 'dss'.");
    end
    
    %Check that the user is not trying to set bolusSource during
    %identification
    if(strcmp(modality,'identification'))
        
        valid = strcmp(bolusSource,'data');
        if(~valid)
            error("'bolusSource' cannot be set in 'identification' modality.");
        end
        
    end
    
    %If modality is identification or the bolus is coming from data during replay check that data is ok
    if(strcmp(modality,'identification') || strcmp(bolusSource,'data'))

        valid = istimetable(data);

        if(~valid)
            error("'data' must be a timetable.");
        end

        valid = any(strcmp(data.Properties.VariableNames,'bolus'));

        if(~valid)
            error("'data' must contain a column named 'bolus'.");
        end
        
        valid = ~any(isnan(data.bolus));

        if(~valid)
            error("'bolus' column of 'data' must not contain NaN values.");
        end

    end
    
    %If modality is identification, bolus must contain something 
    if(strcmp(modality,'identification'))
        
        valid = (sum(data.bolus) > 0);

        if(~valid)
            error("'bolus' column must not contain only 0 values during identification.");
        end
        
    end
    
end