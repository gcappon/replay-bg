function valid = basalHandlerParamsValidator(basalHandlerParams,modality)
% function  basalHandlerParamsValidator(basalHandlerParams,modality)
% Validates the input parameter 'basalHandlerParams'.
%
% Inputs:
%   - basalHandlerParams;
%   - modality;
% Outputs:
%   - valid: a boolean defining if the input parameter is valid. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2022 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    valid = strcmp(modality,'replay');
    if(~valid)
        error("Cannot set basal handler parameters while identifying model parameters.");
    end
    
end