function valid = correctionBolusesHandlerParamsValidator(correctionBolusesHandlerParams,modality)
% function  correctionBolusesHandlerParamsValidator(correctionBolusHandlerParams,modality)
% Validates the input parameter 'correctionBolusHandlerParams'.
%
% Inputs:
%   - correctionBolusesHandlerParams;
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
        error("Cannot set correction boluses handler parameters while identifying model parameters.");
    end
    
end