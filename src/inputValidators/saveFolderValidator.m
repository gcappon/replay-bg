function valid = saveFolderValidator(saveFolder)
% function  saveFolderValidator(saveFolder)
% Validates the input parameter 'saveFolder'.
%
% Inputs:
%   - saveFolder;
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

    valid = ischar(saveFolder);
    if(~valid)
        error('Must be a vector of characters.');
    end
    
end