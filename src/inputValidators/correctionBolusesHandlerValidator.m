function valid = correctionBolusesHandlerValidator(correctionBolusesHandler,modality)
% function  correctionBolusesHandlerValidator(correctionBolusesHandler,modality)
% Validates the input parameter 'correctionBolusesHandler'.
%
% Inputs:
%   - correctionBolusesHandler;
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
        error("Cannot set an correction bolus handler while identifying model parameters.");
    end
    
    valid = valid && exist(correctionBolusesHandler) == 2; %#ok<EXIST>
    if(~valid)
        error("Handler does not exist or it is not a function.");
    end
    
    valid = valid && nargout(correctionBolusesHandler) == 1;
    if(~valid)
        error("Handler does not have the proper number of inputs (must be 1).");
    end
    
    valid = valid && nargin(correctionBolusesHandler) == 7;
    if(~valid)
        error("Handler does not have the proper number of outputs (must be 7).");
    end
    
end

