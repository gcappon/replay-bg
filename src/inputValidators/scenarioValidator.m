function valid = scenarioValidator(scenario)
% function  scenarioValidator(scenario)
% Validates the input parameter 'scenario'.
%
% Inputs:
%   - scenario.
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

    expectedScenarios = {'single-meal','multi-meal'};

    valid = any(validatestring(scenario,expectedScenarios));
    if(~valid)
        error("Must be 'single-meal' or 'multi-meal'.");
    end
    
end