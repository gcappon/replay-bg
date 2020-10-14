function valid = maxMCMCRunsWithMaxETAValidator(maxMCMCRunsWithMaxETA,modality)
% function  maxMCMCRunsWithMaxETAValidator(maxMCMCRunsWithMaxETA,modality)
% Validates the input parameter 'maxMCMCRunsWithMaxETA'.
%
% Inputs:
%   - maxMCMCRunsWithMaxETA;
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

    valid = isnumeric(maxMCMCRunsWithMaxETA) && ((maxMCMCRunsWithMaxETA - round(maxMCMCRunsWithMaxETA)) == 0);
    if(~valid)
        error("Must be an integer number.");
    end
    if(strcmp(modality,'replay'))
        warning("You are trying to set the parameter 'maxMCMCRunsWithMaxETA' while using the 'replay' modality. It won't be used.");
    end
    
end