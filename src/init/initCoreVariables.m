function [environment, model, sensors, mcmc, dss] = initCoreVariables(data,BW,ip)
% function  initCoreVariables(data,BW,ip)
% Initializes the core variables (i.e., environment, model, sensors, mcmc, and dss) of
% ReplayBG.
%
% Inputs:
%   - data: timetable which contains the data to be used by the tool;
%   - BW: the patient's body weight;
%   - ip: the input parser;
% Outputs:
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - sensors: a structure that contains general parameters of the
%   sensors models;
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
    environment = initEnvironment(ip.Results.modality,ip.Results.saveName,ip.Results.saveSuffix,ip.Results.scenario,...
        ip.Results.bolusSource, ip.Results.basalSource, ip.Results.choSource,...
        ip.Results.plotMode,ip.Results.enableLog,ip.Results.verbose);
    
    %Start the log file
    if(environment.enableLog)
        diary(environment.logFile);
    end
    
    %Initialize the model hyperparameters
    model = initModel(data,ip.Results.sampleTime, ip.Results.glucoseModel,ip.Results.pathology, ip.Results.seed, environment);
    
    %Initialize sensors hyperparameters 
    sensors = initSensors(ip.Results.cgmModel, model, environment);
    
    %Initialize the decision support system hyperparameters
    dss = initDecisionSupportSystem(BW,ip.Results.CR, ip.Results.CF, ip.Results.GT, ...
        ip.Results.bolusCalculatorHandler, ip.Results.bolusCalculatorHandlerParams, ...
        ip.Results.basalHandler, ip.Results.basalHandlerParams, ...
        ip.Results.enableHypoTreatments,ip.Results.hypoTreatmentsHandler,...
        ip.Results.enableCorrectionBoluses,ip.Results.correctionBolusesHandler,...
        ip.Results.hypoTreatmentsHandlerParams,...
        ip.Results.correctionBolusesHandlerParams,...
        environment);
    
    %Initialize the mcmc hyperparameters (if modality: 'identification')
    if(strcmp(environment.modality,'identification'))
        
        mcmc = initMarkovChainMonteCarlo(ip.Results.maxETAPerMCMCRun,ip.Results.maxMCMCIterations,ip.Results.maxMCMCRuns,ip.Results.maxMCMCRunsWithMaxETA,...
            ip.Results.MCMCTheta0Policy, ip.Results.bayesianEstimator, ip.Results.preFilterData, ip.Results.saveChains, ip.Results.adaptiveSCMH,...
            data,environment, model);

    else
        
        mcmc = [];
        
    end
   
end