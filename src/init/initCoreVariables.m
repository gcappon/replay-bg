function [environment, model, mcmc, dss] = initCoreVariables(data,ip)
% function  initCoreVariables(data,ip)
% Initializes the core variables (i.e., environment, model, mcmc, and dss) of
% ReplayBG.
%
% Inputs:
%   - data: timetable which contains the data to be used by the tool;
%   - ip: the input parser;
% Outputs:
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - mcmc: a structure that contains the hyperparameters of the MCMC
%   identification procedure;
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

    %Initialize the environment parameters
    environment = initEnvironment(ip.Results.modality,ip.Results.saveName,ip.Results.saveSuffix, ip.Results.scenario, ip.Results.plotMode,ip.Results.enableLog,ip.Results.verbose);
    
    %Start the log file
    if(environment.enableLog)
        diary(environment.logFile);
    end
    
    %Initialize the model hyperparameters
    model = initModel(data,ip.Results.sampleTime, ip.Results.cgmModel, ip.Results.glucoseModel,ip.Results.pathology, ip.Results.seed, environment);
    
    %Initialize the decision support system hyperparameters
    dss = initDecisionSupportSystem(ip.Results.CR, ip.Results.CF,...
        ip.Results.enableHypoTreatments,ip.Results.hypoTreatmentsHandler,...
        ip.Results.enableCorrectionBoluses,ip.Results.correctionBolusesHandler,...
        ip.Results.hypoTreatmentsHandlerParams,...
        ip.Results.correctionBolusesHandlerParams);
    
    %Initialize the mcmc hyperparameters (if modality: 'identification')
    if(strcmp(environment.modality,'identification'))
        
        mcmc = initMarkovChainMonteCarlo(ip.Results.maxETAPerMCMCRun,ip.Results.maxMCMCIterations,ip.Results.maxMCMCRuns,ip.Results.maxMCMCRunsWithMaxETA,...
            ip.Results.MCMCTheta0Policy, ip.Results.bayesianEstimator, ip.Results.preFilterData, ip.Results.saveChains, ip.Results.adaptiveSCMH,...
            data,environment, model);

    else
        
        mcmc = [];
        
    end
   
end