function valid = mealGeneratorHandlerValidator(mealGeneratorHandler,modality)
% function  mealGeneratorHandlerValidator(mealGeneratorHandler,modality)
% Validates the input parameter 'mealGeneratorHandler'.
%
% Inputs:
%   - mealGeneratorHandler;
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
        error("Cannot set a basal handler while identifying model parameters.");
    end
    
    valid = valid && exist(mealGeneratorHandler) == 2; %#ok<EXIST>
    if(~valid)
        error("Handler does not exist or it is not a function.");
    end
    
    valid = valid && nargout(mealGeneratorHandler) == 4;
    if(~valid)
        error("Handler does not have the proper number of outputs (must be 4).");
    end
    
    valid = valid && nargin(mealGeneratorHandler) == 8;
    if(~valid)
        error("Handler does not have the proper number of outputs (must be 8).");
    end
    
end