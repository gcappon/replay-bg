function valid = maxMCMCIterationsValidator(maxMCMCIterations,modality)
% function  maxMCMCIterationsValidator(maxMCMCIterations,modality)
% Validates the input parameter 'maxMCMCIterations'.
%
% Inputs:
%   - maxMCMCIterations;
%   - modality;
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

    valid = isnumeric(maxMCMCIterations) && ((maxMCMCIterations - round(maxMCMCIterations)) == 0);
    if(~valid)
        error("Must be an integer number.");
    end
    if(strcmp(modality,'replay'))
        warning("You are trying to set the parameter 'maxMCMCIterations' while using the 'replay' modality. It won't be used.");
    end
    
end