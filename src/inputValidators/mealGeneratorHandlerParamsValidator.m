function valid = mealGeneratorHandlerParamsValidator(mealGeneratorHandlerParams,modality)
% function  mealGeneratorHandlerParamsValidator(mealGeneratorHandlerParams,modality)
% Validates the input parameter 'mealGeneratorHandlerParams'.
%
% Inputs:
%   - mealGeneratorHandlerParams;
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
        error("Cannot set meal generator handler parameters while identifying model parameters.");
    end
    
end