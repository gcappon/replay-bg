function valid = saveNameValidator(saveName)
% function  saveNameValidator(saveName)
% Validates the input parameter 'saveName'.
%
% Inputs:
%   - saveName;
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

    valid = ischar(saveName);
    if(~valid)
        error("Must be a vector of characters.");
    end
    
end