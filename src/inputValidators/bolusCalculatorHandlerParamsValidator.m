function valid = bolusCalculatorHandlerParamsValidator(bolusCalculatorHandlerParams,modality)
% function  bolusCalculatorHandlerParamsValidator(bolusCalculatorHandlerParams,modality)
% Validates the input parameter 'bolusCalculatorHandlerParams'.
%
% Inputs:
%   - bolusCalculatorHandlerParams;
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
        error("Cannot set bolus calculator handler parameters while identifying model parameters.");
    end
    
end