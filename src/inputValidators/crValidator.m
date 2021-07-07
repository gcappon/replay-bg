function valid = crValidator(CR)
% function  crValidator(CR)
% Validates the input parameter 'CR'.
%
% Inputs:
%   - CR;
% Outputs:
%   - valid: a boolean defining if the input parameter is valid. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2021 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    valid = isnumeric(CR) || isnan(CR);
    if(~valid)
        error('Must be a number.');
    end
    
end