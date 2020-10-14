function valid = preFilterDataValidator(preFilterData,modality)
% function  preFilterDataValidator(preFilterData,modality)
% Validates the input parameter 'preFilterData'.
%
% Inputs:
%   - preFilterData;
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


    valid = preFilterData == 0 || preFilterData == 1;
    if(~valid)
        error("Must be 0 or 1.");
    end
    
    if(strcmp(modality,'replay'))
        warning("You are trying to set the parameter 'preFilterData' while using the 'replay' modality. It won't be used.");
    end
    
end