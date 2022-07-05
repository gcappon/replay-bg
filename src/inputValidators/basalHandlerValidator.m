function valid = basalHandlerValidator(basalHandler,modality)
% function  basalHandlerValidator(basalHandler,modality)
% Validates the input parameter 'basalHandler'.
%
% Inputs:
%   - basalHandler;
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
    
    valid = valid && exist(basalHandler) == 2; %#ok<EXIST>
    if(~valid)
        error("Handler does not exist or it is not a function.");
    end
    
    valid = valid && nargout(basalHandler) == 2;
    if(~valid)
        error("Handler does not have the proper number of outputs (must be 2).");
    end
    
    valid = valid && nargin(basalHandler) == 7;
    if(~valid)
        error("Handler does not have the proper number of outputs (must be 7).");
    end
    
end