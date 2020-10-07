function valid = saveSuffixValidator(saveSuffix)
% function  saveSuffixValidator(saveSuffix)
% Validates the input parameter 'saveSuffix'.
%
% Inputs:
%   - saveSuffix;
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

    valid = ischar(saveSuffix);
    if(~valid)
        error('Must be a vector of characters.');
    end
    
end