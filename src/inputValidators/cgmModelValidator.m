function valid = cgmModelValidator(cgmModel)
% function  cgmModelValidator(cgmModel)
% Validates the input parameter 'cgmModel'.
%
% Inputs:
%   - cgmModel;
% Outputs:
%   - valid: a boolean defining if the input parameter is valid. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2021 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    expectedCGMModels = {'CGM','BG','IG'};

    valid = any(validatestring(cgmModel,expectedCGMModels));
    if(~valid)
        error("Must be 'CGM', 'IG' or 'BG'.");
    end
    
end