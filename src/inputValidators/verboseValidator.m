function valid = verboseValidator(verbose)
% function  verboseValidator(verbose)
% Validates the input parameter 'verbose'.
%
% Inputs:
%   - verbose;
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

    valid = verbose == 0 || verbose == 1;
    if(~valid)
        error('Must be 0 or 1.');
    end
    
end