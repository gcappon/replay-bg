function valid = measurementModelValidator(measurementModel)
% function  measurementModelValidator(measurementModel)
% Validates the input parameter 'measurementModel'.
%
% Inputs:
%   - measurementModel;
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

    expectedMeasurementModels = {'BG','IG'};

    valid = any(validatestring(measurementModel,expectedMeasurementModels));
    if(~valid)
        error("Must be 'IG' or 'BG'.");
    end
    
end