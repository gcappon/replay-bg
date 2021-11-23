function dss = initDecisionSupportSystem(CR,CF,enableHypoTreatments,hypoTreatmentsHandler,enableCorrectionBoluses,correctionBolusesHandler,hypoTreatmentsHandlerParams,correctionBolusesHandlerParams)
% function  initDecisionSupportSystem(CR,CF,enableHypoTreatments,hypoTreatmentsHandler,enableCorrectionBoluses,correctionBolusesHandler,hypoTreatmentsHandlerParams,correctionBolusesHandlerParams)
% Initializes the 'dss' core variable.
%
% Inputs:
%   - CR: the carbohydrate-to-insulin ratio of the patient in g/U to be 
%   used by the integrated decision support system;
%   - CF: the correction factor of the patient in mg/dl/U to be used by the 
%   integrated decision support system;
%   - enableHypoTreatments: a numerical flag that specifies whether to 
%   enable hypotreatments during the replay of a given scenario;
%   - hypoTreatmentsHandler: a vector of characters that specifies the
%   name of the function handler that implements an hypotreatment strategy
%   during the replay of a given scenario;
%   - enableCorrectionBoluses: a numerical flag that specifies whether to 
%   enable correction boluses during the replay of a given scenario;
%   - correctionBolusesHandler: a vector of characters that specifies the
%   name of the function handler that implements a corrective bolusing strategy
%   during the replay of a given scenario.
%   - hypoTreatmentsHandlerParams: (optional, default: []) a structure that contains the parameters
%   to pass to the hypoTreatmentsHandler function. It also serves as memory
%   area for the hypoTreatmentsHandler function;
%   - correctionBolusesHandlerParams: (optional, default: []) a structure that contains the parameters
%   to pass to the correctionBolusesHandler function. It also serves as memory
%   area for the correctionBolusesHandler function.
% Outputs:
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2021 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    if(environment.verbose && strcmp(environment.modality,'replay'))
    	fprintf('Setting up the Decision Support System hyperparameters...');
    	tic;
    end
    
    %Patient therapy parameters
    dss.CR = CR;
    dss.CF = CF;
    
    %Hypotreatment module parameters
    dss.enableHypoTreatments = enableHypoTreatments;
    dss.hypoTreatmentsHandler = hypoTreatmentsHandler;
    
    %Correction bolus module parameters
    dss.enableCorrectionBoluses = enableCorrectionBoluses;
    dss.correctionBolusesHandler = correctionBolusesHandler;
    
    %Handlers optional parameters
    dss.hypoTreatmentsHandlerParams = hypoTreatmentsHandlerParams;
    dss.correctionBolusesHandlerParams = correctionBolusesHandlerParams;
    
    if(environment.verbose && strcmp(environment.modality,'replay'))
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
end