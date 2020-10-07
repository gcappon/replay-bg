function valid = plotModeValidator(plotMode)
% function  plotModeValidator(plotModel)
% Validates the input parameter 'plotMode'.
%
% Inputs:
%   - plotMode;
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

    valid = plotMode == 0 || plotMode == 1;
    if(~valid)
        error('Must be 0 or 1.');
    end
    
end