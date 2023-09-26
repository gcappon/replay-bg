function [modelParameters, draws] = identifyModelParameters(data, BW, mcmc, model, sensors, dss, environment) 
% function  identifyModelParameters(data, BW, mcmc, model, sensors, dss, environment) 
% Identifies the physiological model parameters using the MCMC.
%
% Inputs:
%   - data: timetable which contains the data to be used by the tool;
%   - BW: the patient's body weight;
%   - mcmc: a structure that contains the hyperparameters of the MCMC
%   identification procedure;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - sensors: a structure that contains general parameters of the
%   sensors models;
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Outputs:
%   - modelParameters: is a struct containing all the identified model 
%   parameters (point estimates);
%   - draws: a structure that contains the modelParameter draws obtained
%   with MCMC.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    %% ============ Set default parameter values ==========================
    
        modelParameters = setDefaultModelParameters(data,BW,model,environment);
        
        %Set model initial conditions (to start replay according to data)
        idxFirstNonNan = find(~isnan(data.glucose),1,'first');
        modelParameters.G0 = data.glucose(idxFirstNonNan);
        
    %% ========== Run MCMC  ===============================================
        %1. Explorative run to roughly estimate std and initial values
        mcmc.n = mcmc.raftLewNmin; %number of iterations
        if(environment.verbose)
            disp(['*** Simulating first explorative MCMC run for ' num2str(mcmc.n) ' iterations...']);
        end
        tic;
        [pHat, accept, ll] = runMCMC(data,mcmc,modelParameters,model,sensors,dss,environment); %Run MCMC
        timeFirstRun = toc;
        if(environment.verbose)
            disp(['*** MCMC Finished! , Time: ' num2str(timeFirstRun/60) ' min.']);
        end
        [mcmc] = setNewMCMCParameters(pHat,mcmc); %Set new std and theta0
        
        %2. Second explorative run to roughly (better) estimate std and initial
        %values
        mcmc.n = mcmc.raftLewNmin; %number of iterations
        if(environment.verbose)
            disp(['*** Simulating second explorative MCMC run for ' num2str(mcmc.n) ' iterations...']);
        end
        tic;
        [pHat, accept, ll] = runMCMC(data,mcmc,modelParameters,model,sensors,dss,environment); %Run MCMC
        timeSecondRun = toc;
        if(environment.verbose)
            disp(['*** MCMC Finished! , Time: ' num2str(timeSecondRun/60) ' min.']);
        end
        [mcmc] = setNewMCMCParameters(pHat,mcmc); %Set new std and theta0
        
        %Compute the ETA for Nmin iterations
        timeForNmin = (timeFirstRun/60 + timeSecondRun/60)/2; %[min]
        
        %Compute the MCMC number of iterations using Raftery Lewis
        draws = zeros(mcmc.n,length(mcmc.thetaNames));
        for p = 1:length(mcmc.thetaNames)
            draws(:,p) = pHat.(mcmc.thetaNames{p});
        end %for p
        conv = rafteryLewis(draws,mcmc.raftLewQ,mcmc.raftLewR,mcmc.raftLewS); %Raftery Lewis diagnostics
        
        %3. Run the actual MCMC runs
        k = 2;
        runWithMaxETA = 0;
        nIterations = 0;
        nextN = max(conv.N_total);
        
        while((k == 2 || nextN>(mcmc.n*1.1)) && nIterations < mcmc.maxMCMCRuns && runWithMaxETA < mcmc.maxMCMCRunsWithMaxETA)
            
            %Set the number of MCMC iterations (mcmc.n)
            mcmc.n = nextN;
            nIterations = nIterations + 1;
            
            %Limit the maximum ETA to limitETA hours and set mcmc.n
            %accordingly
            ETA = timeForNmin*mcmc.n/mcmc.raftLewNmin;
            limitETA = mcmc.maxETAPerMCMCRun*60; %[min]
            if(ETA > limitETA)
                limitedN = (limitETA * mcmc.raftLewNmin)/timeForNmin;
                limitedN = ceil(limitedN);
                if(environment.verbose)
                    warning(['*** ETA greater than the maximum allowed ETA per MCMC run. Setting the number of MCMC iterations so that ETA is equal to the maximum allowed ETA. (Originally: ' num2str(mcmc.n) ', now: ' num2str(limitedN) ')']);
                end
                mcmc.n = limitedN;
                ETA = timeForNmin*mcmc.n/mcmc.raftLewNmin;
                runWithMaxETA = runWithMaxETA + 1;
            end
            
            %Limit the maximum number of MCMC iterations to mcmc.maxMCMCIterations
            %and set mcmc.n accordingly
            if(mcmc.n > mcmc.maxMCMCIterations)
                if(environment.verbose)
                    warning(['*** Number of MCMC iterations greater than the maximum allowed number of MCMC iterations. Setting the number of MCMC iterations to the maximum allowed ETA. (Originally: ' num2str(mcmc.n) ', now: ' num2str(mcmc.maxMCMCIterations) ')']);
                end
                mcmc.n = mcmc.maxMCMCIterations;
                ETA = timeForNmin*mcmc.n/mcmc.raftLewNmin;
            end
    
            %Simulate MCMC run
            if(environment.verbose)
                tic;
                disp(['*** Simulating MCMC run number ' num2str(nIterations) ' for ' num2str(mcmc.n) ' iterations (ETA ~ ' num2str(ETA) ' min)...']);
            end
            [pHat, accept, ll] = runMCMC(data,mcmc,modelParameters,model,sensors,dss,environment);
            if(environment.verbose)
                timeRun = toc;
                disp(['*** MCMC Finished! , Time: ' num2str(timeRun/60) ' min.']);
            end
            
            %Compute the next MCMC number of iterations using Raftery Lewis
            draws = zeros(mcmc.n,length(mcmc.thetaNames));
            for p = 1:length(mcmc.thetaNames)
                draws(:,p) = pHat.(mcmc.thetaNames{p});
            end %for p
            conv = rafteryLewis(draws,mcmc.raftLewQ,mcmc.raftLewR,mcmc.raftLewS); 

            %Save the chain if specified
            if(mcmc.saveChains)
                name = ['mcmcChain_par'];
                for p = 1:length(mcmc.thetaNames)
                    name = [name '-' mcmc.thetaNames{p}];
                end %for p
                save(fullfile(environment.replayBGPath,'results','mcmcChains',environment.saveFolder,[name '_iter' num2str(k-1) '_' environment.saveName]),'mcmc', 'pHat', 'accept', 'll', 'conv');
            end
            
            %Set new std and theta0
            [mcmc] = setNewMCMCParameters(pHat,mcmc); 
            
            k = k+1;
            
            %Compute the next MCMC number of iterations using Raftery Lewis
            nextN = max(conv.N_total);
            
        end % while
        
        %Display why mcmc stopped
        if(nextN < (mcmc.n*1.1))
            disp('ReplayBG model was successfully identified.');
        else
            if(runWithMaxETA == mcmc.maxMCMCRunsWithMaxETA && nextN > (mcmc.n*1.1))
                warning('Identification procedure stopped because the maximum number of MCMC runs having maximum allowed ETA reached.');
            end
            if(nIterations == mcmc.maxMCMCRuns)
                warning('Identification procedure stopped because the maximum allowed number of MCMC iterations was reached.');
            end
        end
    % =====================================================================

    %% ========== Compute parameter estimates  ============================
        
        %Initialize the output structure
        draws = struct();
        
        flagChainHealthy = true;
        
        paramsForCopula = zeros(length(pHat.(mcmc.thetaNames{1})(max(conv.M_burn):max(conv.k_thin):end)),mcmc.nPar);
        
        if(isempty(paramsForCopula))
            flagChainHealthy = false;
            paramsForCopula = zeros(length(pHat.(mcmc.thetaNames{1})),mcmc.nPar);
            warning('Initial (burn-in) samples  of the MCMC chains cannot be removed becuase the number of iterations was too low. Identification can be innacurate. To solve this issue try to increase the limit on the maximum ETA.');
        end
        
        %Obtain a point estimate of model parameters using the specified
        %bayesian esitmator
        switch(mcmc.bayesianEstimator)
            
            case 'mean'
                
                %For each unknown model parameter...
                for p = 1:length(mcmc.thetaNames)
                    
                    %...get the chain realization, minimum, and maximum
                    %value...
                    if(flagChainHealthy)
                        draws.(mcmc.thetaNames{p}).chain = pHat.(mcmc.thetaNames{p})(max(conv.M_burn):max(conv.k_thin):end);
                    else
                        draws.(mcmc.thetaNames{p}).chain = pHat.(mcmc.thetaNames{p});
                    end
                    draws.(mcmc.thetaNames{p}).min = min(draws.(mcmc.thetaNames{p}).chain);
                    draws.(mcmc.thetaNames{p}).max = max(draws.(mcmc.thetaNames{p}).chain);
                    
                    %...fit a cdf for later copula...
                    paramsForCopula(:,p) = ksdensity(draws.(mcmc.thetaNames{p}).chain,draws.(mcmc.thetaNames{p}).chain,'function','cdf');        
                    
                    %...and obtain a point-estimate of model parameters as
                    %the mean value of the chain.
                    if(flagChainHealthy)
                        distributions.(mcmc.thetaNames{p}) = pHat.(mcmc.thetaNames{p})(conv.M_burn(p):conv.k_thin(p):end);
                    else
                        distributions.(mcmc.thetaNames{p}) = pHat.(mcmc.thetaNames{p});
                    end
                    modelParameters.(mcmc.thetaNames{p}) = mean(distributions.(mcmc.thetaNames{p}));
                    
                end
                
                %Remeber to set kgri = kempt (known from the literature)
                modelParameters = enforceConstraints(modelParameters,model,environment);
                
            case 'map'
                
                %For each unknown model parameter...
                for p = 1:length(mcmc.thetaNames)                    
                    
                    %...get the chain realization, minimum, and maximum
                    %value...
                    if(flagChainHealthy)
                        draws.(mcmc.thetaNames{p}).chain = pHat.(mcmc.thetaNames{p})(max(conv.M_burn):max(conv.k_thin):end);
                    else
                        draws.(mcmc.thetaNames{p}).chain = pHat.(mcmc.thetaNames{p});
                    end
                    draws.(mcmc.thetaNames{p}).min = min(draws.(mcmc.thetaNames{p}).chain);
                    draws.(mcmc.thetaNames{p}).max = max(draws.(mcmc.thetaNames{p}).chain);
                    
                    %...fit a cdf for later copula...
                    paramsForCopula(:,p) = ksdensity(draws.(mcmc.thetaNames{p}).chain,draws.(mcmc.thetaNames{p}).chain,'function','cdf');
                    
                    %...and obtain a point-estimate of model parameters as
                    %the value of the chain having maxiimum probabilty.
                    if(flagChainHealthy)
                        distributions.(mcmc.thetaNames{p}) = pHat.(mcmc.thetaNames{p})(conv.M_burn(p):conv.k_thin(p):end);
                    else
                        distributions.(mcmc.thetaNames{p}) = pHat.(mcmc.thetaNames{p});
                    end
                    kernel = histfit(distributions.(mcmc.thetaNames{p}),round(length(distributions.(mcmc.thetaNames{p}))/3),'kernel');
                    maxs = find(kernel(2).YData == max(kernel(2).YData));
                    if(length(maxs) > 1)
                        warning('MAP estimate: Found two points having maximum probability. Setting the point estimate to the first one.');
                    end
                    modelParameters.(mcmc.thetaNames{p}) = kernel(2).XData(find(kernel(2).YData == max(kernel(2).YData),1,'first'));
                  
                end
                
                %Remeber to set kgri = kempt (known from the literature)
                modelParameters = enforceConstraints(modelParameters,model,environment);
                
                %Set kabs of hypotreatment to the fastest kabs between
                %breakfast, lunch, dinner, and snack, if no hypotreatment 
                %are present within data.
                if(~any(strcmp(data.choLabel,'H')) && strcmp(environment.scenario,'multi-meal'))
                    modelParameters.kabsH = max([modelParameters.kabsB, modelParameters.kabsL, modelParameters.kabsD, modelParameters.kabsS]);
                end
                
        end
        
        %Sample mcmc.tbe model parameter samples using a copula
        
        %Fit the copula
        try
            [Rho,nu] = copulafit('t',paramsForCopula,'Method','ApproximateML');
           
            %Init parameters that are not yet ok (nyOK) 
            nyOK = mcmc.tbe;
            parametersOK = false(mcmc.tbe,1);
            
            %Repeat while not all parameters are ok
            while ~all(parametersOK)
                
                %Generate the samples
                r = copularnd('t',Rho,nu,nyOK);
                
                %Scale the samples back to the original scale of the data
                for p = 1:length(mcmc.thetaNames)       
                    draws.(mcmc.thetaNames{p}).samples(~parametersOK) = ksdensity(draws.(mcmc.thetaNames{p}).chain,r(:,p),'function','icdf');
                end
                
                %Check if the extracted parameters are ok and find who's
                %not
                parametersOK = checkCopulaExtractions(draws, mcmc, modelParameters, model, environment);
                %Count who many are missing yet
                nyOK = sum(~parametersOK);
                
            end
            
        catch exception
            error('The estimate of parameters made by copula has become rank-deficient. You may have too few data, or strong dependencies among variables. To solve this issue try to increase the limit on the maximum ETA.');
        end
        
        %Save distributions here 
        save(fullfile(environment.replayBGPath,'results','distributions',environment.saveFolder,['distributions_' environment.saveName]),'mcmc','distributions','draws');
            
    % =====================================================================
    
    %% ========== Save modelParameters for future usage  ==================
        save(fullfile(environment.replayBGPath,'results','modelParameters',environment.saveFolder,['modelParameters_' environment.saveName]),'modelParameters');
    % =====================================================================
    
 end