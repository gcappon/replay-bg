function valid = enableHypoTreatmentsValidator(enableHypoTreatments,modality)
% function  enableHypoTreatmentsValidator(enableHypoTreatments,modality)
% Validates the input parameter 'enableHypoTreatments'.
%
% Inputs:
%   - enableHypoTreatments;
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

    valid = strcmp(modality,'replay');
    if(~valid)
        error("Cannot enable hypotreatments while identifying model parameters.");
    end
    
    valid = enableHypoTreatments == 0 || enableHypoTreatments == 1;
    if(~valid)
        error("Must be 0 or 1.");
    end
    
    if(strcmp(modality,'identification'))
        warning("You are trying to set the parameter 'enableHypoTreatments' to 0 while using the 'identification' modality. It won't be used.");
    end
    
end