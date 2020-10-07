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
    %Obtain the InputParser object
    ip = inputParser;
        
    %Add the parameters to the InputParsers
    addRequired(ip,'modality',@(x) modalityValidator(x));
    addRequired(ip,'data',@(x) dataValidator(x));
    addRequired(ip,'BW',@(x) BWValidator(x));
    addRequired(ip,'saveName',@(x) saveNameValidator(x));
    addParameter(ip,'measurementModel','IG',@(x) measurementModelValidator(x)); %default = 'IG'
    addParameter(ip,'sampleTime',5,@(x) sampleTimeValidator(x)); % default = 5
    addParameter(ip,'seed',randi([1 1048576]),@(x) seedValidator(x)); % default = randi([1 1048576])
    addParameter(ip,'maxETAPerMCMCRun',inf,@(x) maxETAPerMCMCRunValidator(x,modality)); % default = inf
    addParameter(ip,'maxMCMCIterations',inf,@(x) maxMCMCIterationsValidator(x,modality)); % default = inf
    addParameter(ip,'maxMCMCRuns',inf,@(x) maxMCMCRunsValidator(x, modality)); % default = inf
    addParameter(ip,'maxMCMCRunsWithMaxETA',2, @(x) maxMCMCRunsWithMaxETAValidator(x,modality)); % default = 2
    addParameter(ip,'saveSuffix','',@(x) saveSuffixValidator(x)); % default = ''
    addParameter(ip,'plotMode',1,@(x) plotModeValidator(x)); % default = 1
    addParameter(ip,'verbose',1,@(x) verboseValidator(x)); % default = 1
    
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
        save(fullfile(environment.replayBGPath,'results','workspaces',['identification_' environment.saveName environment.saveSuffix]),...
            'data','BW','environment','mcmc','model',...
            'glucose','analysis');
    else
        save(fullfile(environment.replayBGPath,'results','workspaces',['replay_' environment.saveName environment.saveSuffix]),...
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