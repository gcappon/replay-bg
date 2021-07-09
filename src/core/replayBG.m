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
%   - glucoseModel: (optional, default: 'IG') a vector of characters
%   that specifies the glucose model to use. Can be 'IG' or 'BG';
%   - sampleTime: (optional, default: 5 (min)) an integer that specifies
%   the data sample time;
%   - seed: (optional, default: randi([1 1048576])) an integer that
%   specifies the random seed. For reproducibility. NOT SUPPORTED YET;
%   - maxETAPerMCMCRun: (optional, default: inf) a number that specifies
%   the maximum time in hours allowed for each MCMC run; 
%   - maxMCMCIterations: (optional, default: inf) an integer that specifies
%   the maximum number of iterations for each MCMC run; 
%   - maxMCMCRuns: (optional, default: inf) an integer that specifies
%   the maximum number of MCMC runs; 
%   - maxMCMCRunsWithMaxETA: (optional, default: 2) an integer that 
%   specifies the maximum number of MCMC runs having maximum ETA; 
%   - adaptiveSCMH: (optional, default: 1) a numerical flag that specifies 
%   whether to make the Single Components Metropolis Hastings algorithm 
%   adaptive or non-adaptive. Can be 0 or 1.
%   - MCMCTheta0Policy: (optional, default: 'mean') a vector of characters 
%   defining the policy used by the MCMC procedure to set the initial MCMC 
%   chain values. Can be 'mean' or 'last' or 'initial'. Using 'mean', the 
%   mean value of the MCMC chain obtained from the last MCMC run will be 
%   set as initial MCMC chain value to be used in the next MCMC run. Using 
%   'last', the last value of the MCMC chain obtained from the last MCMC 
%   run will be set as initial MCMC chain value to be used in the next MCMC
%   run. Using 'initial', the same initial value will be used for every run 
%   of MCMC;
%   - bayesianEstimator: (optional, default: 'mean') a vector of characters
%   defining which Bayesian estimator to use to obtain a point estimate of
%   model parameters. Can be 'mean' or 'map'. Using 'mean' the posterior
%   mean estimater will be used. Using 'map', the marginalized
%   maximum-a-posteriori estimator will be used;
%   - preFilterData: (optional, default: 0) a numerical flag that specifies
%   whether to filter the glucose data before performing the model
%   identification or not. Can be 0 or 1. This might help the identification
%   procedure. Filtering is performed using a non-causal fourth-order 
%   Butterworth filter having 0.1*sampleTime cutOff frequency;
%   - saveChains: (optional, default: 1) a numerical flag that specifies
%   whether to save the resulting mcmc chains in dedicated files (one for 
%   each MCMC run) for future analysis or not. Can be 0 or 1;
%   - enableHypoTreatments: (optional, default: 0) a numerical flag that
%   specifies whether to enable hypotreatments during the replay of a given
%   scenario. Can be 0 or 1. Can be set only when modality is 'replay';
%   - CR: (optional, default: nan) the carbohydrate-to-insulin ratio of the
%   patient in g/U to be used by the integrated decision support system;
%   - CF: (optional, default: nan) the correction factor of the
%   patient in mg/dl/U to be used by the integrated decision support system;
%   - hypoTreatmentsHandler: (optional, default:
%   'adaHypoTreatmentsHandler') a vector of characters that specifies the
%   name of the function handler that implements an hypotreatment strategy
%   during the replay of a given scenario. The function must have 1 output,
%   i.e., the hypotreatments carbohydrates intake (g/min). The function
%   must have 6 inputs, i.e., 'G' (mg/dl) the glucose concentration at 
%   time(timeIndex), 'CHO' (g/min) a vector that contains the CHO
%   intakes input for the whole replay simulation, 'bolus' (U/min) a 
%   vector that contains the bolus insulin input for the whole replay 
%   simulation, 'basal' (U/min) a vector that contains the basal insulin 
%   input for the whole replay simulation, 'time' (datetime) a vector that 
%   contains the time istants of current replay simulation, 'timeIndex' is
%   a number that defines the current time istant in the replay simulation.
%   Vectors contain one value for each integration step. The default policy
%   is "take an hypotreatment of 10 g every 15 minutes while in
%   hypoglycemia";
%   - enableCorrectionBoluses: (optional, default: 0) a numerical flag that
%   specifies whether to enable correction boluses during the replay of a 
%   given scenario. Can be 0 or 1. Can be set only when modality is 
%   'replay';
%   - correctionBolusesHandler: (optional, default:
%   'correctsAbove250Handler') a vector of characters that specifies the
%   name of the function handler that implements a corrective bolusing strategy
%   during the replay of a given scenario. The function must have 1 output,
%   i.e., the correction insulin bolus (U/min). The function
%   must have 6 inputs, i.e., 'G' (mg/dl) the glucose concentration at 
%   time(timeIndex), 'CHO' (g/min) a vector that contains the CHO
%   intakes input for the whole replay simulation, 'bolus' (U/min) a 
%   vector that contains the bolus insulin input for the whole replay 
%   simulation, 'basal' (U/min) a vector that contains the basal insulin 
%   input for the whole replay simulation, 'time' (datetime) a vector that 
%   contains the time istants of current replay simulation, 'timeIndex' is
%   a number that defines the current time istant in the replay simulation.
%   Vectors contain one value for each integration step. The default policy
%   is "take a corrective bolus of 1 U every 1 hour while above 250 mg/dl";
%   - saveSuffix: (optional, default: '') a vector of char to be attached
%   as suffix to the resulting output files' name;
%   - plotMode: (optional, default: 1) a numerical flag that specifies
%   whether to show the plot of the results or not. Can be 0 or 1;
%   - enableLog: (optional, default: 1) a numerical flag that specifies
%   whether to log the output of ReplayBG not. Can be 0 or 1;
%   - verbose: (optional, default: 1) a numerical flag that specifies
%   the verbosity of ReplayBG. Can be 0 or 1.
%   
% ---------------------------------------------------------------------
% NOTES:   
% - Integration step is 1 minute. Function handlers of the integrated 
%   decision support systems works at this time step. So, input vectors of 
%   the function handlers contain one value for each integration step.
%
% - Results folder
%   Results are saved in the results/ folder, specifically:
%   * results/distributions/: contains the identified ReplayBG model parameter distributions
%   obtained via MCMC;
%   * results/logs/: contains .txt files that log the command window output of
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
% ---------------------------------------------------------------------
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
    addParameter(ip,'glucoseModel','IG',@(x) glucoseModelValidator(x)); %default = 'IG'
    addParameter(ip,'sampleTime',5,@(x) sampleTimeValidator(x)); % default = 5
    addParameter(ip,'seed',randi([1 1048576]),@(x) seedValidator(x)); % default = randi([1 1048576])
    addParameter(ip,'maxETAPerMCMCRun',inf,@(x) maxETAPerMCMCRunValidator(x,modality)); % default = inf
    addParameter(ip,'maxMCMCIterations',inf,@(x) maxMCMCIterationsValidator(x,modality)); % default = inf
    addParameter(ip,'maxMCMCRuns',inf,@(x) maxMCMCRunsValidator(x, modality)); % default = inf
    addParameter(ip,'maxMCMCRunsWithMaxETA',2, @(x) maxMCMCRunsWithMaxETAValidator(x,modality)); % default = 2
    addParameter(ip,'adaptiveSCMH',1, @(x) adaptiveSCMHValidator(x,modality)); % default = 1
    
    addParameter(ip,'MCMCTheta0Policy','mean', @(x) MCMCTheta0PolicyValidator(x,modality)); % default = 'mean'
    addParameter(ip,'bayesianEstimator','mean', @(x) bayesianEstimatorValidator(x,modality)); % default = 'mean'
    addParameter(ip,'preFilterData',0, @(x) preFilterDataValidator(x,modality)); % default = 0
    addParameter(ip,'saveChains',1, @(x) saveChainsValidator(x,modality)); % default = 1
    
    addParameter(ip,'CR',nan, @(x) crValidator(x)); % default = nan
    addParameter(ip,'CF',nan, @(x) cfValidator(x)); % default = nan
    
    addParameter(ip,'enableHypoTreatments',0, @(x) enableHypoTreatmentsValidator(x,modality)); % default = 0
    addParameter(ip,'hypoTreatmentsHandler','adaHypoTreatmentsHandler', @(x) hypoTreatmentsHandlerValidator(x,modality)); % default = 'adaHypoTreatmentsHandler'
    addParameter(ip,'enableCorrectionBoluses',0, @(x) enableCorrectionBolusesValidator(x,modality)); % default = 0
    addParameter(ip,'correctionBolusesHandler','correctsAbove250Handler', @(x) correctionBolusesHandlerValidator(x,modality)); % default = 'correctsAbove250Handler'
    
    addParameter(ip,'saveSuffix','',@(x) saveSuffixValidator(x)); % default = ''
    addParameter(ip,'plotMode',1,@(x) plotModeValidator(x)); % default = 1
    addParameter(ip,'enableLog',1,@(x) enableLogValidator(x)); % default = 1
    addParameter(ip,'verbose',1,@(x) verboseValidator(x)); % default = 1
    
    %Parse the input arguments
    parse(ip,modality,data,BW,saveName,varargin{:});
    
    %Isolate data and BW from the results
    data = ip.Results.data;
    BW = ip.Results.BW;
    %% ====================================================================
    
    %% ================ Initialize core variables =========================
    [environment, model, mcmc, dss] = initCoreVariables(data,ip);
    %% ====================================================================
    
    %% ================ Set model parameters ==============================
    [modelParameters, mcmc, draws] = setModelParameters(data,BW,environment,mcmc,model,dss);
    %% ====================================================================
    
    %% ================ Replay of the scenario ============================
    [glucose, insulinBolus, correctionBolus, insulinBasal, CHO, hypotreatments,physioCheck] = replayScenario(data,modelParameters,draws,environment,model,mcmc,dss);
    %% ====================================================================
    
    %% ================ Analyzing results =================================
    analysis = analyzeResults(glucose, insulinBolus, correctionBolus, insulinBasal, CHO, hypotreatments,data,environment);
    %% ====================================================================
    
    %% ================ Plotting results ==================================
    if(environment.plotMode)
        
        %Replay overview
        plotReplayBGResults(glucose,data,environment);
        
        %Convert the profile to a timetable to comply with AGATA
        dataHat = glucoseVectorToTimetable(glucose.median,minutes(data.Time(2)-data.Time(1)),data.Time(1));
        
        %Clarke's Error Grid
        plotClarkeErrorGrid(data,dataHat,0);
        
    end
    %% ====================================================================
    
    %% ================ Save the workspace and close the log ==============
    if(environment.verbose)
        fprintf('Saving the workspace...');
        tic;
    end
    
    if(strcmp(environment.modality,'identification'))
        save(fullfile(environment.replayBGPath,'results','workspaces',['identification_' environment.saveName environment.saveSuffix]),...
            'data','BW','environment','mcmc','model','dss',...
            'glucose','insulinBolus', 'insulinBasal', 'CHO',...
            'analysis','physioCheck');
    else
        save(fullfile(environment.replayBGPath,'results','workspaces',['replay_' environment.saveName environment.saveSuffix]),...
            'data','BW','environment','model','dss',...
            'glucose','insulinBolus', 'insulinBasal', 'CHO',...
            'correctionBolus', 'hypotreatments',...
            'analysis','physioCheck');
    end
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
    if(environment.enableLog)
        diary off;
        
    end
    %% ====================================================================
    
end