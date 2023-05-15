function valid = exerciseValidator(exercise,data)
% function  exerciseValidator(exercise,data)
% Validates the input parameter 'exercise'.
%
% Inputs:
%   - exercise;
% Outputs:
%   - valid: a boolean defining if the input parameter is valid. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2023 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    valid = exercise == 0 || exercise == 1;
    if(~valid)
        error('Must be 0 or 1.');
    end
    
    valid = exercise == 0  | any(strcmp(data.Properties.VariableNames,'exercise'));
    if(~valid)
        error("data timetable must contain a column named 'exercise'");
    end
    
end