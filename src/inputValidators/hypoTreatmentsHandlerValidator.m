function valid = hypoTreatmentsHandlerValidator(hypoTreatmentsHandler,modality)
% function  hypoTreatmentsHandlerValidator(hypoTreatmentsHandler,modality)
% Validates the input parameter 'hypoTreatmentsHandler'.
%
% Inputs:
%   - hypoTreatmentsHandler;
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
        error("Cannot set an hypotreatments handler while identifying model parameters.");
    end
    
    valid = valid && exist(hypoTreatmentsHandler) == 2; %#ok<EXIST>
    if(~valid)
        error("Handler does not exist or it is not a function.");
    end
    
    valid = valid && nargout(hypoTreatmentsHandler) == 2;
    if(~valid)
        error("Handler does not have the proper number of outputs (must be 2).");
    end
    
    valid = valid && nargin(hypoTreatmentsHandler) == 8;
    if(~valid)
        error("Handler does not have the proper number of outputs (must be 8).");
    end
    
end