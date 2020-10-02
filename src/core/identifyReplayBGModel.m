function identifyReplayBGModel(data, BW, saveName, varargin)

    %% ================ Function input parsing ============================
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
    
    ip = inputParser;
    
    validData = @(x) istimetable(x) && ...
        any(strcmp(x.Properties.VariableNames,'Glucose')) && any(strcmp(x.Properties.VariableNames,'Basal')) && ...
        any(strcmp(x.Properties.VariableNames,'Bolus')) && any(strcmp(x.Properties.VariableNames,'CHO')) && ...
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
    
    parse(ip,data,BW,saveName,varargin{:});
    
    data = ip.Results.data;
    %% ====================================================================
    
    %% ================ Initialize core variables =========================
    %Initialize the environment parameters
    environment = initEnvironment('identifyReplayBGModel',ip.Results.saveName,ip.Results.plotMode,ip.Results.verbose);
    
    %Start the log file
    diary(environment.logFile);

    %Initialize the model hyperparameters
    if(environment.verbose)
        fprintf('Setting up the model hyperparameters...');
        tic;
    end
    
    model = initModel(data,ip.Results.sampleTime,ip.Results.measurementModel,ip.Results.seed);
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
    %Initialize the mcmc hyperparameters
    if(environment.verbose)
        fprintf('Setting up the MCMC hyperparameters...');
        tic;
    end

    mcmc = initMarkovChainMonteCarlo(ip.Results.maxETAPerMCMCRun,ip.Results.maxMCMCIterations,ip.Results.maxMCMCRuns,ip.Results.maxMCMCRunsWithMaxETA);
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    %% ====================================================================
    
    %% ================ Identify model parameters =========================
    if(environment.verbose)
        st = [mcmc.thetaNames{1}];
        for s = 2:mcmc.nPar
            st = [st ' ' mcmc.thetaNames{s}];
        end %for s
        fprintf(['Identifying ReplayBG model using MCMC on ' st '...\n']);
    end
    
    %Identify model parameters
    [modelParameters, draws] = identifyModelParameters(data, ip.Results.BW, mcmc, model, environment);
    
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
        fprintf('DONE.\n');  
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
        plotIdentificationResults(glucose,data);
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
    
    save(fullfile(environment.replayBGPath,'results','workspaces',['identification_' environment.saveName]),...
        'data','environment','mcmc','model',...
        'glucose','analysis');
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
    diary off;
    %% ====================================================================
    
end