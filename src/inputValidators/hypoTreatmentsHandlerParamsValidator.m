function valid = hypoTreatmentsHandlerParamsValidator(hypoTreatmentsHandlerParams,modality)
% function  hypoTreatmentsHandlerParamsValidator(hypoTreatmentsHandlerParams,modality)
% Validates the input parameter 'hypoTreatmentsHandlerParams'.
%
% Inputs:
%   - hypoTreatmentsHandlerParams;
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
        error("Cannot set hypotreatments handler parameters while identifying model parameters.");
    end
    
end