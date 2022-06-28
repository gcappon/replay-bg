function valid = dataValidator(data,modality)
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

    
    %Check data when modality is identification
    if(strcmp(modality,'identification'))
        
        valid = istimetable(data);
    
        if(~valid)
            error("'data' must be a timetable.");
        end
    
        valid = valid && any(strcmp(data.Properties.VariableNames,'glucose'));

        if(~valid)
            error("'data' must contain a column named 'glucose'.");
        end
        
        %Generate an error if the glucose column has only nans
        if(all(isnan(data.glucose)))
            error("'glucose' column of 'data' contains only nan values.");
        end
        
        %Generate a warning if nan values are present in the glucose column
        if(any(isnan(data.glucose)))
            warning("'glucose' column of 'data' contains nan values.");
        end
    
    end
    
end