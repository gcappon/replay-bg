function valid = maxMCMCRunsValidator(maxMCMCRuns,modality)
% function  maxMCMCRunsValidator(maxMCMCRuns,modality)
% Validates the input parameter 'maxMCMCRuns'.
%
% Inputs:
%   - maxMCMCRuns;
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

    valid = isnumeric(maxMCMCRuns) && ((maxMCMCRuns - round(maxMCMCRuns)) == 0);
    if(~valid)
        error("Must be an integer number.");
    end
    if(strcmp(modality,'replay'))
        warning("You are trying to set the parameter 'maxMCMCRuns' while using the 'replay' modality. It won't be used.");
    end
    
end