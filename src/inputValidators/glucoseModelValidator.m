function valid = glucoseModelValidator(glucoseModel)
% function  glucoseModelValidator(glucoseModel)
% Validates the input parameter 'glucoseModel'.
%
% Inputs:
%   - glucoseModel;
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

    expectedGlucoseModels = {'BG','IG'};

    valid = any(validatestring(glucoseModel,expectedGlucoseModels));
    if(~valid)
        error("Must be 'IG' or 'BG'.");
    end
    
end