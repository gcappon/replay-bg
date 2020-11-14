function valid = enableLogValidator(enableLog)
% function  enableLogValidator(enableLog)
% Validates the input parameter 'enableLog'.
%
% Inputs:
%   - enableLog;
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

    valid = enableLog == 0 || enableLog == 1;
    if(~valid)
        error('Must be 0 or 1.');
    end
    
end