function valid = coreModelValidator(coreModel)
% function  coreModelValidator(pathology)
% Validates the input parameter 'coreModel'.
%
% Inputs:
%   - coreModel.
% Outputs:
%   - valid: a boolean defining if the input parameter is valid. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2023 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    expectedCoreModels = {'cappon','resalat'};

    valid = any(validatestring(coreModel,expectedCoreModels));
    if(~valid)
        error("Must be 'cappon', or 'resalat'.");
    end
    
    
end