function replayBG(modality, data, BW, saveName, varargin)
% function  replayBG(modality, data, BW, saveName, varargin)
% Core function of ReplayBG. Can be used to identify ReplayBG model on the
% given data or to "replay" specific scenarios specified by the given data.
%
% Inputs:
%   - modality: (required) 'identification' or 'replay', specifies if the
%   function will be used to identify the ReplayBG model on the given data
%   or to replay the scenario specified by the given data;
%   - data: (required) timetable which contains the data to be used by the tool. MUST
%   contain a column 'glucose' that contains the glucose measurements (in
%   mg/dl), a column 'basal' that contains the basal insulin data (in
%   U/min), a column 'bolus' that contains the bolus insulin data (in
%   U/min), a column 'CHO' that contains the CHO intake data (in
%   g/min). data MUST be sampled on a homogeneous time grid and MUST not 
%   contain Nan values. ;
%   - BW: (required) the patient body weight (kg);
%   - saveName: (required) a vector of characters used to label, thus identify, each 
%   output file and result;
%   - measurementModel: (optional, default: 'IG') a vector of characters
%   that specifies the glucose model to use. Can be 'IG' or 'BG';
%   - sampleTime: (optional, default: 5 (min)) an integer that specifies
%   the data sample time;
%   - seed: (optional, default: randi([1 1048576])) an integer that
%   specifies the random seed. For reproducibility. NOT SUPPORTED YET;
%   - maxETAPerMCMCRun: (optional, default: inf) a number that specifies
%   the maximum time in hours allowed for each MCMC run; 
%   maxMCMCIterations: (optional, default: inf) an integer that specifies
%   the maximum number of iterations for each MCMC run; 
%   - maxMCMCRuns: (optional, default: inf) an integer that specifies
%   the maximum number of MCMC runs; 
%   - maxMCMCRunsWithMaxETA: (optional, default: 2) an integer that 
%   specifies the maximum number of MCMC runs having maximum ETA; 
%   - plotMode: (optional, default: 1) a numerical flag that specifies
%   whether to show the plot of the results or not. Can be 0 or 1;
%   - verbose: (optional, default: 1) a numerical flag that specifies
%   the verbosity of ReplayBG. Can be 0 or 1.
%   
% ---------------------------------------------------------------------
% NOTES:   
% - Results folder
%   Results are saved in the results/ folder, specifically:
%   * results/distributions/: contains the identified ReplayBG model parameter distributions
%   obtained via MCMC;
%   * logs/: contains .txt files that log the command window output of
%   ReplayBG. NB: .txt files will be empty if verbose = 0;
%   * results/mcmcChains/: contains the MCMC chains, for each unknown parameter,
%   obtained in each MCMC run;
%   * results/modelParameters/: contains the model parameters identified using
%   MCMC. Known model parameters are fixed to population values obtained
%   from the literature. Unknown model parameters are pointly estimated
%   using MAP criterion without accounting for intra-parameter correlation.
%   For this reason is better to obtain an estimate of the replayed glucose
%   profile via Monte Carlo simulations using hte model parameters in
%   draws.<modelParameterName>.samples;
%   * results/workspaces/: contains the core ReplayBG variables and data used in a
%   specific ReplayBG call.
%
% ---------------------------------------------------------------------
% REFERENCES:
% TBD...
%
% ----------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    %% ================ Function input parsing ============================
    %Set the default values
    expectedModalities = {'replay','identification'};
    defaultMeasurementModel = 'IG';
    expectedMeasurementModels = {'BG','IG'};
    defaultSampleTime = 5; %[min]
    defaultSeed = randi([1 1048576]);
    defaultMaxETAPerMCMCRun = inf; %[hour]
    defaultMaxMCMCIterations = inf; 
    defaultMaxMCMCRuns = inf;
    defaultMaxMCMCRunsWithMaxETA = 2;
    defaultPlotMode = 1;
    defaultVerbose = 1;
    
    %Obtain the InputParser object
    ip = inputParser;
    
    %Set the validators
    validModalities = @(x) any(validatestring(x,expectedModalities));
    validData = @(x) istimetable(x) && ...
        any(strcmp(x.Properties.VariableNames,'glucose')) && any(strcmp(x.Properties.VariableNames,'basal')) && ...
        any(strcmp(x.Properties.VariableNames,'bolus')) && any(strcmp(x.Properties.VariableNames,'CHO')) && ...
        ~any(isnan(x.Glucose) | isnan(x.Basal) | isnan(x.Bolus) | isnan(x.CHO));
    validBW = @(x) isnumeric(x);
    validSaveName = @(x) ischar(saveName);
    validMeasurementModel = @(x) any(validatestring(x,expectedMeasurementModels));
    validSampleTime = @(x) isnumeric(x) && ((x - round(x)) == 0);
    validSeed = @(x) isnumeric(x) && ((x - round(x)) == 0);
    validMaxETAPerMCMCRun = @(x) isnumeric(x);
    validMaxMCMCIterations = @(x) isnumeric(x) && ((x - round(x)) == 0);
    validMaxMCMCRuns = @(x) isnumeric(x) && ((x - round(x)) == 0);
    validMaxMCMCRunsWithMaxETA = @(x) isnumeric(x) && ((x - round(x)) == 0);
    validPlotMode = @(x) x == 0 || x == 1;
    validVerbose = @(x) x == 0 || x == 1;
    
    %Add the parameters to the InputParsers
    addRequired(ip,'modality',validModalities);
    addRequired(ip,'data',validData);
    addRequired(ip,'BW',validBW);
    addRequired(ip,'saveName',validSaveName);
    addParameter(ip,'measurementModel',defaultMeasurementModel,validMeasurementModel);
    addParameter(ip,'sampleTime',defaultSampleTime,validSampleTime);
    addParameter(ip,'seed',defaultSeed,validSeed);
    addParameter(ip,'maxETAPerMCMCRun',defaultMaxETAPerMCMCRun,validMaxETAPerMCMCRun);
    addParameter(ip,'maxMCMCIterations',defaultMaxMCMCIterations,validMaxMCMCIterations);
    addParameter(ip,'maxMCMCRuns',defaultMaxMCMCRuns,validMaxMCMCRuns);
    addParameter(ip,'maxMCMCRunsWithMaxETA',defaultMaxMCMCRunsWithMaxETA,validMaxMCMCRunsWithMaxETA);
    addParameter(ip,'plotMode',defaultPlotMode,validPlotMode);
    addParameter(ip,'verbose',defaultVerbose,validVerbose);
    
    %Parse the input arguments
    parse(ip,modality,data,BW,saveName,varargin{:});
    
    %Isolate data from the results
    data = ip.Results.data;
    %% ====================================================================
    
    %% ================ Initialize core variables =========================
    %Initialize the environment parameters
    environment = initEnvironment(ip.Results.modality,ip.Results.saveName,ip.Results.plotMode,ip.Results.verbose);
    
    %Start the log file
    diary(environment.logFile);

    if(environment.verbose)
        fprintf('Setting up the model hyperparameters...');
        tic;
    end
    
    %Initialize the model hyperparameters
    model = initModel(data,ip.Results.sampleTime,ip.Results.measurementModel,ip.Results.seed);
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
    if(strcmp(environment.modality,'identification'))
        
        if(environment.verbose)
            fprintf('Setting up the MCMC hyperparameters...');
            tic;
        end

        %Initialize the mcmc hyperparameters (if modality: 'identification')
        mcmc = initMarkovChainMonteCarlo(ip.Results.maxETAPerMCMCRun,ip.Results.maxMCMCIterations,ip.Results.maxMCMCRuns,ip.Results.maxMCMCRunsWithMaxETA);

        if(environment.verbose)
            time = toc;
            fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
        end
        
    end
    %% ====================================================================
    
    %% ================ Get model parameters ==============================
    if(strcmp(environment.modality,'identification'))
        
        if(environment.verbose)
            st = [mcmc.thetaNames{1}];
            for s = 2:mcmc.nPar
                st = [st ' ' mcmc.thetaNames{s}];
            end %for s
            fprintf(['Identifying ReplayBG model using MCMC on ' st '...\n']);
        end

        %Identify model parameters (if modality: 'identification')
        [modelParameters, draws] = identifyModelParameters(data, ip.Results.BW, mcmc, model, environment);
        
    else
        
        if(environment.verbose)
            tic;
            fprintf(['Loading model parameters...']);
        end
        
        %Load the model parameters (if modality: 'replay')
        load(fullfile(environment.replayBGPath,'results','modelParameters',['modelParameters_' environment.saveName]));
        load(fullfile(environment.replayBGPath,'results','distributions',['distributions_' environment.saveName]));

        if(environment.verbose)
            time = toc;
            fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
        end
        
    end
    
    if(environment.verbose)
        fprintf('DONE.\n');  
    end
    %% ====================================================================
    
    %% ================ Replay of the scenario ============================
    if(environment.verbose)
        tic;
        fprintf(['Replaying scenario...']);
    end

    %Obtain the glicemic realizations using the copula-generated parameter
    %samples
    glucose.realizations = zeros(height(data),length(draws.(mcmc.thetaNames{1}).samples));
    for r = 1:length(draws.(mcmc.thetaNames{1}).samples)
        
        for p = 1:length(mcmc.thetaNames)
            modelParameters.(mcmc.thetaNames{p}) = draws.(mcmc.thetaNames{p}).samples(r);
        end
        
        [G, ~] = computeGlicemia(modelParameters,data,model);
        glucose.realizations(:,r) = G(1:model.YTS:end)';
        
    end
    
    %Obtain the confidence intervals
    glucose.ci25th = zeros(height(data),1);
    glucose.ci75th = zeros(height(data),1);
    
    glucose.median = zeros(height(data),1);
    
    glucose.ci5th = zeros(height(data),1);
    glucose.ci95th = zeros(height(data),1);
    
    for g = 1:length(glucose.median)
        glucose.ci25th(g) = prctile(glucose.realizations(g,:),25);
        glucose.ci75th(g) = prctile(glucose.realizations(g,:),75);
        
        glucose.median(g) = prctile(glucose.realizations(g,:),50);
        
        glucose.ci5th(g) = prctile(glucose.realizations(g,:),5);
        glucose.ci95th(g) = prctile(glucose.realizations(g,:),95);
    end
        
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    %% ====================================================================
    
    %% ================ Analyzing results =================================
    if(environment.verbose)
        tic;
        fprintf(['Analyzing results...']);
    end
    
    analysis = analyzeResults(glucose,data,environment);
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    %% ====================================================================
    
    %% ================ Plotting results ==================================
    if(environment.verbose && environment.plotMode)
        tic;
        fprintf(['Plotting results...']);
    end

    if(environment.plotMode)
        plotReplayBGResults(glucose,data);
    end
    
    if(environment.verbose && environment.plotMode)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    %% ====================================================================
    
    %% ================ Save the workspace and close the log ==============
    if(environment.verbose)
        fprintf('Saving the workspace...');
        tic;
    end
    
    if(strcmp(environment.modality,'identification'))
        save(fullfile(environment.replayBGPath,'results','workspaces',['identification_' environment.saveName]),...
            'data','environment','mcmc','model',...
            'glucose','analysis');
    else
        save(fullfile(environment.replayBGPath,'results','workspaces',['replay_' environment.saveName]),...
            'data','environment','model',...
            'glucose','analysis');
    end
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
    diary off;
    %% ====================================================================
    
end