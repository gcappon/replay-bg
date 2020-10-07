function valid = sampleTimeValidator(sampleTime)
% function  sampleTimeValidator(sampleTime)
% Validates the input parameter 'sampleTime'.
%
% Inputs:
%   - sampleTime;
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

    valid = isnumeric(sampleTime) && ((sampleTime - round(sampleTime)) == 0);
    if(~valid)
        error("Must be an integer number.");
    end
    
end