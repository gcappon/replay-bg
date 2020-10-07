function valid = BWValidator(BW)
% function  BWValidator(BW)
% Validates the input parameter 'BW'.
%
% Inputs:
%   - BW;
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

    valid = isnumeric(BW);
    if(~valid)
        error('Must be a number.');
    end
    
end