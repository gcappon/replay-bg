function valid = choSourceValidator(choSource,data,modality,scenario)
% function  choSourceValidator(choSource,data, modality)
% Validates the input parameter 'choSource'.
%
% Inputs:
%   - choSource;
%   - data;
%   - modality;
%   - scenario.
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
    
    expectedCHOSources = {'data','generated'};

    valid = any(validatestring(choSource,expectedCHOSources));
    if(~valid)
        error("'choSource' must be 'data' or 'generated'.");
    end
    
    %Check that the user is not trying to set choSource during
    %identification
    if(strcmp(modality,'identification'))
        
        valid = strcmp(choSource,'data');
        if(~valid)
            error("'choSource' cannot be set in 'identification' modality.");
        end
        
    end
    
    %If modality is identification or the bolus is coming from data during replay check that data is ok
    if(strcmp(modality,'identification') || strcmp(choSource,'data'))

        valid = istimetable(data);

        if(~valid)
            error("'data' must be a timetable.");
        end

        valid = any(strcmp(data.Properties.VariableNames,'CHO'));

        if(~valid)
            error("'data' must contain a column named 'CHO'.");
        end
        
        valid = ~any(isnan(data.CHO));

        if(~valid)
            error("'CHO' column of 'data' must not contain NaN values.");
        end

    end
    
    %If modality is identification, bolus must contain something 
    if(strcmp(modality,'identification'))
        
        valid = (sum(data.CHO) > 0);

        if(~valid)
            error("'CHO' column must not contain only 0 values during identification.");
        end
        
    end
    
    %If  scenario is multi-meal and the choSource is 'data' there must be a
    %column in data named choLabel with valid labels for every CHO > 0
    if(strcmp(scenario,'multi-meal') && strcmp(choSource,'data'))
        
        okLabels = ["B","L","D","S","H"];
        labels = data.choLabel(data.CHO > 0);
        valid = any(strcmp(data.Properties.VariableNames,'choLabel'));

        if(~valid)
            error("'data' must contain a column named 'choLabel'.");
        end

        valid = all(contains(labels,okLabels));
        if(~valid)
            error("'data' must contain a label for every CHO and they must be 'B', 'L', 'D', 'S', or 'H'.");
        end

    end
    
end