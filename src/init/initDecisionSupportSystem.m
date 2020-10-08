function dss = initDecisionSupportSystem(enableHypoTreatments,hypoTreatmentsHandler)
% function  initDecisionSupportSystem(enableHypoTreatments)
% Initializes the 'dss' core variable.
%
% Inputs:
%   - enableHypoTreatments: a numerical flag that specifies whether to 
%   enable hypotreatments during the replay of a given scenario;
%   - hypoTreatmentsHandler: a vector of characters that specifies the
%   name of the function handler that implements an hypotreatment strategy
%   during the replay of a given scenario.
% Outputs:
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    %Hypotreatment module parameters
    dss.enableHypoTreatments = enableHypoTreatments;
    dss.hypoTreatmentsHandler = hypoTreatmentsHandler;
    
end