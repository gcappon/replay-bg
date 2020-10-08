function [environment, model, mcmc, dss] = initCoreVariables(data,ip)
% function  initCoreVariables(data,ip)
% Initializes the core variables (i.e., environment, model, and mcmc) of
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
    environment = initEnvironment(ip.Results.modality,ip.Results.saveName,ip.Results.saveSuffix, ip.Results.plotMode,ip.Results.verbose);
    
    %Start the log file
    diary(environment.logFile);

    if(environment.verbose)
        fprintf('Setting up the model hyperparameters...');
        tic;
    end
    
    %Initialize the model hyperparameters
    model = initModel(data,ip.Results.sampleTime, ip.Results.glucoseModel,ip.Results.seed);
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
    
    if(environment.verbose && strcmp(environment.modality,'replay'))
        fprintf('Setting up the Decision Support System hyperparameters...');
        tic;
    end
    
    %Initialize the decision support system hyperparameters
    dss = initDecisionSupportSystem(ip.Results.enableHypoTreatments,ip.Results.hypoTreatmentsHandler,...
        ip.Results.enableCorrectionBoluses,ip.Results.correctionBolusesHandler);
    
    if(environment.verbose && strcmp(environment.modality,'replay'))
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
    %Initialize the mcmc hyperparameters (if modality: 'identification')
    if(strcmp(environment.modality,'identification'))
        
        if(environment.verbose)
            fprintf('Setting up the MCMC hyperparameters...');
            tic;
        end

        mcmc = initMarkovChainMonteCarlo(ip.Results.maxETAPerMCMCRun,ip.Results.maxMCMCIterations,ip.Results.maxMCMCRuns,ip.Results.maxMCMCRunsWithMaxETA,...
            ip.Results.MCMCTheta0Policy, ip.Results.bayesianEstimator, ip.Results.preFilterData, ip.Results.saveChains);

        if(environment.verbose)
            time = toc;
            fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
        end
        
    else
        
        mcmc = [];
        
    end
   
end