function valid = enableCorrectionBolusesValidator(enableCorrectionBoluses,modality)
% function  enableCorrectionBolusesValidator(enableCorrectionBoluses,modality)
% Validates the input parameter 'enableCorrectionBoluses'.
%
% Inputs:
%   - enableCorrectionBoluses;
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
        error("Cannot enable correction boluses while identifying model parameters.");
    end
    
    valid = enableCorrectionBoluses == 0 || enableCorrectionBoluses == 1;
    if(~valid)
        error("Must be 0 or 1.");
    end
    
    if(strcmp(modality,'identification'))
        disp("WARNING: you are trying to set the parameter 'enableCorrectionBoluses' to 0 while using the 'identification' modality. It won't be used.");
    end
    
end