function replayBG(modality, data, BW, scenario, saveName, varargin)
% function  replayBG(modality, data, BW, scenario, saveName, varargin)
% Core function of ReplayBG. Can be used to identify ReplayBG model on the
% given data or to "replay" specific scenarios specified by the given data.
%
% Inputs:
%   - modality: (required) 'identification' or 'replay', specifies if the
%   function will be used to identify the ReplayBG model on the given data
%   or to replay the scenario specified by the given data;
%   - data: (required) timetable which contains the data to be used by the tool.
%   When `modality` is `identification` it MUST
%   contain a column 'glucose' that contains the glucose measurements (in
%   mg/dl), a column 'basal' that contains the basal insulin data (in
%   U/min), a column 'bolus' that contains the bolus insulin data (in
%   U/min), a column 'CHO' that contains the CHO intake data (in
%   g/min). data MUST be sampled on a homogeneous time grid and MUST, except for the glucose column, not 
%   contain Nan values. In case of scenario = 'multi-meal' data MUST also 
%   contain a column of strings 'choLabel' that contains for each non-zero
%   value of the 'CHO' column, a character that specifies the type of CHO
%   intake ('B' for breakfast, 'L' for lunch, 'D' for dinner, 'S' for
%   snack, 'H' for hypotreatment).
%   If `modality` is `replay` it can be an empty timetable with only the
%   Time column. `bolus` column is required if `bolusSource` is `data`.
%   `basal` column is required if `basalSource` is data. `CHO` and
%   `choLabel` columns are required if `choSource` is `data`;
%   - BW: (required) the patient body weight (kg);
%   - scenario: (required) a vector of characters
%   that specifies whether the given scenario refers to a single-meal
%   scenario or a multi-meal scenario. Can be 'single-meal' or
%   'multi-meal';
%   - saveName: (required) a vector of characters used to label, thus identify, each 
%   output file and result;
%
%   - glucoseModel: (optional, default: 'IG') a vector of characters
%   that specifies the glucose model to use. Can be 'IG' or 'BG';
%   - cgmModel: (optional, default: 'IG') a vector of characters
%   that specifies the glucose model to use as cgm measurement. Can be 'CGM', 'IG' or 'BG';
%
%   - pathology: (optional, default: 't1d') a vector of characters that
%   specifies the patient pathology. Can be 't1d', 't2d', 'pbh', 'healthy'.
%
%   - sampleTime: (optional, default: 5 (min)) an integer that specifies
%   the data sample time;
%   - seed: (optional, default: randi([1 1048576])) an integer that
%   specifies the random seed. For reproducibility;
%
%   - maxETAPerMCMCRun: (optional, default: inf) a number that specifies
%   the maximum time in hours allowed for each MCMC run; 
%   - maxMCMCIterations: (optional, default: inf) an integer that specifies
%   the maximum number of iterations for each MCMC run; 
%   - maxMCMCRuns: (optional, default: inf) an integer that specifies
%   the maximum number of MCMC runs; 
%   - maxMCMCRunsWithMaxETA: (optional, default: inf) an integer that 
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
%
%   - bolusSource: (optional, default: `data`) a vector of character
%   defining whether to use, during replay, the insulin bolus data
%   contained in the `data` timetable (if `data`), or the boluses generated
%   by the bolus calculator implemented via the provided `bolusCalculatorHandler` 
%   function. Can be `data` or `dss`. It cannot be set if `modality` is
%   `identification`;
%   - basalSource: (optional, default: `data`) a vector of character
%   defining whether to use, during replay, the insulin basal data
%   contained in the `data` timetable (if `data`), or the basal generated
%   by the controller implemented via the provided `basalControllerHandler` 
%   function. Can be `data` or `dss`. It cannot be set if `modality` is
%   `identification`;
%   - choSource: (optional, default: `data`) a vector of character
%   defining whether to use, during replay, the CHO data
%   contained in the `data` timetable (if `data`), or the CHO generated
%   by the meal generator implemented via the provided `mealGeneratorHandler` 
%   function. Can be `data` or `dss`. It cannot be set if `modality` is
%   `identification`;
%
%   - CR: (optional, default: 10) the carbohydrate-to-insulin ratio of the
%   patient in g/U to be used by the integrated decision support system;
%   - CF: (optional, default: 40) the correction factor of the
%   patient in mg/dl/U to be used by the integrated decision support system;
%   - GT: (optional, default: 120) the target glucose value in mg/dl to be
%   used by the decsion support system modules;
%
%   - bolusCalculatorHandler: (optional, default:
%   `standardBolusCalculatorHandler`) a vector of characters that specifies the
%   name of the function handler that implements a bolus calculator to be
%   used during the replay of a given scenario when `bolusSource` is `dss`. The function must have 2 output,
%   i.e., the computed insulin bolus (U/min) and a structure
%   containing the dss hyperparameter. The function
%   must have 7 inputs, i.e., `G` (mg/dl) a vector as long the 
%   simulation length containing all the simulated glucose concentrations 
%   up to `timeIndex` (the other values are nan), 'mealAnnouncements'
%   (g/min) a vector that contains the announced meal CHO intakes inputs for the whole replay simulation,
%   'bolus' (U/min) a vector that contains the bolus insulin input for the whole replay 
%   simulation, 'basal' (U/min) a vector that contains the basal insulin 
%   input for the whole replay simulation, 'time' (datetime) a vector that 
%   contains the time istants of current replay simulation, 'timeIndex' is
%   a number that defines the current time istant in the replay simulation,
%   `dss` a structure containing the dss hyperparameters and the optionally
%   provided `bolusCalculatorTreatmentsHandlerParams` (`dss` is also echoed in the
%   output to enable memory-like features). Vectors contain one value for each integration step. 
%   The default bolus calculator implemented by `standardBolusCalculatorHandler` is
%   the standrd formula: B = CHO/CR + (GC-GT)/CF - IOB;
%   - bolusCalculatorHandlerParams: (optional, default: []) a structure that contains the parameters
%   to pass to the bolusCalculatorHandler function. It also serves as memory
%   area for the bolusCalculatorHandler function;

%   - enableHypoTreatments: (optional, default: 0) a numerical flag that
%   specifies whether to enable hypotreatments during the replay of a given
%   scenario. Can be 0 or 1. Can be set only when modality is 'replay';
%   - hypoTreatmentsHandler: (optional, default:
%   'adaHypoTreatmentsHandler') a vector of characters that specifies the
%   name of the function handler that implements an hypotreatment strategy
%   during the replay of a given scenario. The function must have 2 output,
%   i.e., the hypotreatments carbohydrates intake (g/min) and a structure
%   containing the dss hyperparameter. The function
%   must have 8 inputs, i.e., `G` (mg/dl) a vector as long the 
%   simulation length containing all the simulated glucose concentrations 
%   up to `timeIndex` (the other values are nan), 'CHO' (g/min) a vector that contains the CHO
%   intakes input for the whole replay simulation, `hypotreatment` (g/min)
%   a vector that contains the hypotreatments intakes input for the whole 
%   replay simulation (g/min); 'bolus' (U/min) a 
%   vector that contains the bolus insulin input for the whole replay 
%   simulation, 'basal' (U/min) a vector that contains the basal insulin 
%   input for the whole replay simulation, 'time' (datetime) a vector that 
%   contains the time istants of current replay simulation, 'timeIndex' is
%   a number that defines the current time istant in the replay simulation,
%   `dss` a structure containing the dss hyperparameters and the optionally
%   provided `hypoTreatmentsHandlerParams` (`dss` is also echoed in the
%   output to enable memory-like features).
%   Vectors contain one value for each integration step. The default policy
%   implemented by `adaHypoTreatmentsHandler` is "take an hypotreatment of 10 g every 15 minutes while in
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
%   - hypoTreatmentsHandlerParams: (optional, default: []) a structure that contains the parameters
%   to pass to the hypoTreatmentsHandler function. It also serves as memory
%   area for the hypoTreatmentsHandler function;
%   - correctionBolusesHandlerParams: (optional, default: []) a structure that contains the parameters
%   to pass to the correctionBolusesHandler function. It also serves as memory
%   area for the correctionBolusesHandler function;
%
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
%   from the literature. Unknown model parameters estimates are in 
%   draws.<modelParameterName>.samples;
%   * results/workspaces/: contains the core ReplayBG variables and data used in a
%   specific ReplayBG call.
%
%   - Plot is not currently showing insulin and carbohydrate intake
%   generated during the simulation via the dss, only input data. This is
%   because we have multiple simulations, so events can occur at different
%   time with different amounts (see issue #17).
%
% ---------------------------------------------------------------------
% REFERENCES:
% 
%   - Cappon et al., "ReplayBG: a methodology to identify a personalized
%   model from type 1 diabetes data and simulate glucose concentrations to
%   assess alternative therapies", IEEE TBME, 2022 (under revision).
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
    addRequired(ip,'data',@(x) dataValidator(x,modality));
    addRequired(ip,'BW',@(x) BWValidator(x));
    addRequired(ip,'scenario',@(x) scenarioValidator(x));
    addRequired(ip,'saveName',@(x) saveNameValidator(x));
    
    addParameter(ip,'cgmModel','CGM',@(x) cgmModelValidator(x)); %default = 'CGM'
    addParameter(ip,'glucoseModel','IG',@(x) glucoseModelValidator(x)); %default = 'IG'
    addParameter(ip,'sampleTime',5,@(x) sampleTimeValidator(x)); % default = 5
    addParameter(ip,'seed',randi([1 1048576]),@(x) seedValidator(x)); % default = randi([1 1048576])
    
    addParameter(ip,'pathology','t1d',@(x) pathologyValidator(x)); %default = 't1d'
    
    addParameter(ip,'bolusSource','data',@(x) bolusSourceValidator(x,data,modality));
    addParameter(ip,'basalSource','data',@(x) basalSourceValidator(x,data,modality));
    addParameter(ip,'choSource','data',@(x) choSourceValidator(x,data,modality,scenario));
    
    addParameter(ip,'bolusCalculatorHandler','standardBolusCalculatorHandler',@(x) bolusCalculatorHandlerValidator(x,data,modality));
    addParameter(ip,'bolusCalculatorHandlerParams',[], @(x) bolusCalculatorHandlerParamsValidator(x,modality));
    %addParameter(ip,'basalSource','data',@(x) basalSourceValidator(x,data,modality));
    
    addParameter(ip,'maxETAPerMCMCRun',inf,@(x) maxETAPerMCMCRunValidator(x,modality)); % default = inf
    addParameter(ip,'maxMCMCIterations',inf,@(x) maxMCMCIterationsValidator(x,modality)); % default = inf
    addParameter(ip,'maxMCMCRuns',inf,@(x) maxMCMCRunsValidator(x, modality)); % default = inf
    addParameter(ip,'maxMCMCRunsWithMaxETA',inf, @(x) maxMCMCRunsWithMaxETAValidator(x,modality)); % default = inf
    addParameter(ip,'adaptiveSCMH',1, @(x) adaptiveSCMHValidator(x,modality)); % default = 1
    
    addParameter(ip,'MCMCTheta0Policy','mean', @(x) MCMCTheta0PolicyValidator(x,modality)); % default = 'mean'
    addParameter(ip,'bayesianEstimator','mean', @(x) bayesianEstimatorValidator(x,modality)); % default = 'mean'
    addParameter(ip,'preFilterData',0, @(x) preFilterDataValidator(x,modality)); % default = 0
    addParameter(ip,'saveChains',1, @(x) saveChainsValidator(x,modality)); % default = 1
    
    addParameter(ip,'CR',10, @(x) crValidator(x)); % default = 10
    addParameter(ip,'CF',40, @(x) cfValidator(x)); % default = 40
    addParameter(ip,'GT',120, @(x) gtValidator(x)); % default = 120
    
    addParameter(ip,'enableHypoTreatments',0, @(x) enableHypoTreatmentsValidator(x,modality)); % default = 0
    addParameter(ip,'hypoTreatmentsHandler','adaHypoTreatmentsHandler', @(x) hypoTreatmentsHandlerValidator(x,modality)); % default = 'adaHypoTreatmentsHandler'
    addParameter(ip,'hypoTreatmentsHandlerParams',[], @(x) hypoTreatmentsHandlerParamsValidator(x,modality)); % default = 'correctsAbove250Handler'
    addParameter(ip,'enableCorrectionBoluses',0, @(x) enableCorrectionBolusesValidator(x,modality)); % default = 0
    addParameter(ip,'correctionBolusesHandler','correctsAbove250Handler', @(x) correctionBolusesHandlerValidator(x,modality)); % default = 'correctsAbove250Handler'
    addParameter(ip,'correctionBolusesHandlerParams',[], @(x) correctionBolusesHandlerParamsValidator(x,modality)); % default = 'correctsAbove250Handler'
    
    addParameter(ip,'saveSuffix','',@(x) saveSuffixValidator(x)); % default = ''
    addParameter(ip,'plotMode',1,@(x) plotModeValidator(x)); % default = 1
    addParameter(ip,'enableLog',1,@(x) enableLogValidator(x)); % default = 1
    addParameter(ip,'verbose',1,@(x) verboseValidator(x)); % default = 1
    
    %Parse the input arguments
    parse(ip,modality,data,BW,scenario,saveName,varargin{:});
    
    %Isolate data and BW from the results
    data = ip.Results.data;
    BW = ip.Results.BW;
    %% ====================================================================
    
    %% ================ Initialize core variables =========================
    [environment, model, sensors, mcmc, dss] = initCoreVariables(data,ip);
    %% ====================================================================
    
    %% ================ Set model parameters ==============================
    [modelParameters, mcmc, draws] = setModelParameters(data,BW,environment,mcmc,model,sensors,dss);
    %% ====================================================================
    
    %% ================ Replay of the scenario ============================
    [cgm, glucose, insulinBolus, correctionBolus, insulinBasal, CHO, hypotreatments] = replayScenario(data,modelParameters,draws,environment,model,sensors,mcmc,dss);
    %% ====================================================================
    
    %% ================ Analyzing results =================================
    analysis = analyzeResults(cgm, glucose, insulinBolus, correctionBolus, insulinBasal, CHO, hypotreatments,data,environment);
    %% ====================================================================
    
    %% ================ Plotting results ==================================
    if(environment.plotMode)
        
        %Replay overview
        plotReplayBGResults(cgm,glucose,insulinBolus, insulinBasal, CHO, hypotreatments, correctionBolus, data,environment);
        
        %Convert the profile to a timetable to comply with AGATA
        dataHat = glucoseVectorToTimetable(cgm.median,minutes(data.Time(2)-data.Time(1)),data.Time(1));
        
        %Clarke's Error Grid
        if(strcmp(environment.modality,'identification'))
            plotClarkeErrorGrid(data,dataHat,0);
        end
        
    end
    %% ====================================================================
    
    %% ================ Save the workspace and close the log ==============
    if(environment.verbose)
        fprintf('Saving the workspace...');
        tic;
    end
    
    if(strcmp(environment.modality,'identification'))
        save(fullfile(environment.replayBGPath,'results','workspaces',['identification_' environment.saveName environment.saveSuffix]),...
            'data','BW','environment','mcmc','model','sensors','dss',...
            'cgm','glucose','insulinBolus', 'insulinBasal', 'CHO',...
            'analysis');
    else
        save(fullfile(environment.replayBGPath,'results','workspaces',['replay_' environment.saveName environment.saveSuffix]),...
            'data','BW','environment','model','sensors','dss',...
            'cgm','glucose','insulinBolus', 'insulinBasal', 'CHO',...
            'correctionBolus', 'hypotreatments',...
            'analysis');
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