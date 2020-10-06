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
%   - saveSuffix: (optional, default: '') a vector of char to be attached
%   as suffix to the resulting output files' name;
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
    defaultSaveSuffix = '';
    defaultPlotMode = 1;
    defaultVerbose = 1;
    
    %Obtain the InputParser object
    ip = inputParser;
    
    %Set the validators
    validModalities = @(x) any(validatestring(x,expectedModalities));
    validData = @(x) istimetable(x) && ...
        any(strcmp(x.Properties.VariableNames,'glucose')) && any(strcmp(x.Properties.VariableNames,'basal')) && ...
        any(strcmp(x.Properties.VariableNames,'bolus')) && any(strcmp(x.Properties.VariableNames,'CHO')) && ...
        ~any(isnan(x.glucose) | isnan(x.basal) | isnan(x.bolus) | isnan(x.CHO));
    validBW = @(x) isnumeric(x);
    validSaveName = @(x) ischar(x);
    validMeasurementModel = @(x) any(validatestring(x,expectedMeasurementModels));
    validSampleTime = @(x) isnumeric(x) && ((x - round(x)) == 0);
    validSeed = @(x) isnumeric(x) && ((x - round(x)) == 0);
    validMaxETAPerMCMCRun = @(x) isnumeric(x);
    validMaxMCMCIterations = @(x) isnumeric(x) && ((x - round(x)) == 0);
    validMaxMCMCRuns = @(x) isnumeric(x) && ((x - round(x)) == 0);
    validMaxMCMCRunsWithMaxETA = @(x) isnumeric(x) && ((x - round(x)) == 0);
    validSaveSuffix = @(x) ischar(x);
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
    addParameter(ip,'saveSuffix',defaultSaveSuffix,validSaveSuffix);
    addParameter(ip,'plotMode',defaultPlotMode,validPlotMode);
    addParameter(ip,'verbose',defaultVerbose,validVerbose);
    
    %Parse the input arguments
    parse(ip,modality,data,BW,saveName,varargin{:});
    
    %Isolate data and BW from the results
    data = ip.Results.data;
    BW = ip.Results.BW;
    %% ====================================================================
    
    %% ================ Initialize core variables =========================
    [environment, model, mcmc] = initCoreVariables(data,ip);
    %% ====================================================================
    
    %% ================ Set model parameters ==============================
    [modelParameters, mcmc, draws] = setModelParameters(data,BW,environment,mcmc,model);
    %% ====================================================================
    
    %% ================ Replay of the scenario ============================
    glucose = replayScenario(data,modelParameters,draws,environment,model,mcmc);
    %% ====================================================================
    
    %% ================ Analyzing results =================================
    analysis = analyzeResults(glucose,data,environment);
    %% ====================================================================
    
    %% ================ Plotting results ==================================
    if(environment.plotMode)
        plotReplayBGResults(glucose,data,environment);
    end
    %% ====================================================================
    
    %% ================ Save the workspace and close the log ==============
    if(environment.verbose)
        fprintf('Saving the workspace...');
        tic;
    end
    
    if(strcmp(environment.modality,'identification'))
        save(fullfile(environment.replayBGPath,'results','workspaces',['identification_' environment.saveName]),...
            'data','BW','environment','mcmc','model',...
            'glucose','analysis');
    else
        save(fullfile(environment.replayBGPath,'results','workspaces',['replay_' environment.saveName '_' environment.saveSuffix]),...
            'data','BW','environment','model',...
            'glucose','analysis');
    end
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
    diary off;
    %% ====================================================================
    
end