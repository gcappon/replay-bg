function valid = bolusCalculatorHandlerValidator(bolusCalculatorHandler,modality)
% function  bolusCalculatorHandlerValidator(bolusCalculatorHandler,modality)
% Validates the input parameter 'bolusCalculatorHandler'.
%
% Inputs:
%   - bolusCalculatorHandler;
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
        error("Cannot set an bolus calculator handler while identifying model parameters.");
    end
    
    valid = valid && exist(bolusCalculatorHandler) == 2; %#ok<EXIST>
    if(~valid)
        error("Handler does not exist or it is not a function.");
    end
    
    valid = valid && nargout(bolusCalculatorHandler) == 2;
    if(~valid)
        error("Handler does not have the proper number of outputs (must be 2).");
    end
    
    valid = valid && nargin(bolusCalculatorHandler) == 11;
    if(~valid)
        error("Handler does not have the proper number of outputs (must be 7).");
    end
    
end