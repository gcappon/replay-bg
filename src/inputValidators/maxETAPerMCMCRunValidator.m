function valid = maxETAPerMCMCRunValidator(maxETAPerMCMCRun,modality)
% function  maxETAPerMCMCRunValidator(maxETAPerMCMCRun)
% Validates the input parameter 'maxETAPerMCMCRun'.
%
% Inputs:
%   - maxETAPerMCMCRun;
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

    valid = isnumeric(maxETAPerMCMCRun);
    if(~valid)
        error("Must be a number.");
    end
    if(strcmp(modality,'replay'))
        warning("You are trying to set the parameter 'maxETAPerMCMCRun' while using the 'replay' modality. It won't be used.");
    end
    
end