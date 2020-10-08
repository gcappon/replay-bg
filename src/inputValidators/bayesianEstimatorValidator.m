function valid = bayesianEstimatorValidator(bayesianEstimator,modality)
% function  bayesianEstimatorValidator(bayesianEstimator,modality)
% Validates the input parameter 'bayesianEstimator'.
%
% Inputs:
%   - bayesianEstimator;
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

    expectedBayesianEstimator = {'mean','map'};

    valid = any(validatestring(bayesianEstimator,expectedBayesianEstimator));
    if(~valid)
        error("Must be 'mean' or 'map'.");
    end
    
    if(strcmp(modality,'replay'))
        disp("WARNING: you are trying to set the parameter 'bayesianEstimator' while using the 'replay' modality. It won't be used.");
    end
    
end