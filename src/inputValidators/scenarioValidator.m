function valid = scenarioValidator(scenario,data)
% function  scenarioValidator(scenario,data)
% Validates the input parameter 'scenario'.
%
% Inputs:
%   - scenario;
%   - data.
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

    valid = any(strcmp(data.Properties.VariableNames,'choLabel'));
    
    if(~valid)
        error("Must contain a column named 'choLabel'.");
    end
    
    okLabels = ["B","L","D","S","H"];
    labels = data.choLabel(data.CHO > 0);
    valid = valid && all(contains(labels,okLabels));
    if(~valid)
        error("Must contain a label for every CHO and they must be 'B', 'L', 'D', 'S', or 'H'.");
    end
    
    expectedScenarios = {'single-meal','multi-meal'};

    valid = any(validatestring(scenario,expectedScenarios));
    if(~valid)
        error("Must be 'single-meal' or 'multi-meal'.");
    end
    
    
end