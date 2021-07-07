function valid = cfValidator(CF)
% function  cfValidator(CF)
% Validates the input parameter 'CF'.
%
% Inputs:
%   - CF;
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

    valid = isnumeric(CF) || isnan(CF);
    if(~valid)
        error('Must be a number.');
    end
    
end