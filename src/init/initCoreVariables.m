function [environment, model, mcmc] = initCoreVariables(data,ip)

    %Initialize the environment parameters
    environment = initEnvironment(ip.Results.modality,ip.Results.saveName,ip.Results.saveSuffix, ip.Results.plotMode,ip.Results.verbose);
    
    %Start the log file
    diary(environment.logFile);

    if(environment.verbose)
        fprintf('Setting up the model hyperparameters...');
        tic;
    end
    
    %Initialize the model hyperparameters
    model = initModel(data,ip.Results.sampleTime, ip.Results.measurementModel,ip.Results.seed);
    
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
        
    else
        
        mcmc = [];
        
    end
   
end