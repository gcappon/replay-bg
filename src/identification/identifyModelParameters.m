function [modelParameters, draws] = identifyModelParameters(data, BW, mcmc, model, environment) 
% function  identifyModelParameters(data, BW, mcmc, model, environment) 
% Identifies the physiological model parameters using the MCMC.
%
% Inputs:
%   - data: timetable which contains the data to be used by the tool;
%   - BW: the patient's body weight;
%   - mcmc: a structure that contains the hyperparameters of the MCMC
%   identification procedure;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Outputs:
%   - modelParameters: is a struct containing all the identified model 
%   parameters;
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
    
        %Initial conditions
        modelParameters.Xpb = 0; %Insulin action initial condition
        modelParameters.Qgutb = 0; %Intestinal content initial condition

        %Delay in meal absorption
        modelParameters.beta = 0;

        %Glucose kinetics parameters
        modelParameters.VG = 1.7; %dl/kg
        modelParameters.SG = 1.7e-2; %1/min
        modelParameters.Gb = 120; %mg/dL
        modelParameters.r1 = 0.8; %unitless
        modelParameters.r2 = 1.44; %unitless

        %Interstitial glucose kinetics
        modelParameters.alpha = 7; %1/min

        %Insulin kinetic parameters 
        modelParameters.SI = 5e-4; %mL/(uU*min)
        modelParameters.p2 = 0.01; %1/min
        modelParameters.u2ss = mean(data.basal)*1000/BW; %mU/(kg*min)

        %Subcutaneous insulin absorption parameters
        modelParameters.VI = 0.126; %L/kg
        modelParameters.ke = 0.127; %1/min
        modelParameters.kd = 0.028; %1/min
        modelParameters.ka1 = 0.0034; %1/min
        modelParameters.ka2 = 0.014; %1/min
        modelParameters.tau = 8; %min

        %Meal absorption parameters
        modelParameters.kabs = 0.012; % % 1/min
        modelParameters.kgri = 0.18; %=kmax % 1/min
        modelParameters.kempt = 0.18; %1/min 
        modelParameters.f = 0.9; %dimensionless

        %Patient specific parameters
        modelParameters.BW = BW; %kg
        %modelParameters.Ib = sP.Ib; %U/min

        %Measurement noise specifics
        modelParameters.typeN = 'SD'; %'SD', 'CV', 'mixed'
        switch(modelParameters.typeN)
            case 'SD'
                modelParameters.SDn = 5;
            case 'CV'
                modelParameters.CVn = 0.04;
            case 'mixed'
                modelParameters.SDn = 5;
                modelParameters.CVn = 0.04;
        end %switch modelParameters.typeN
    
    %% ========== Run MCMC  ===============================================
        %1. Explorative run to roughly estimate conditional std and initial
        %values
        mcmc.n = mcmc.raftLewNmin; %number of iterations
        
        if(environment.verbose)
            disp(['*** Simulating first explorative MCMC run for ' num2str(mcmc.n) ' iterations...']);
        end
        tic;
        [pHat, accept, ll] = runMCMC(data,mcmc,modelParameters,model,environment); %Run MCMC
        timeFirstRun = toc;
        if(environment.verbose)
            disp(['*** MCMC Finished! , Time: ' num2str(timeFirstRun/60) ' min.']);
        end
        [mcmc] = setNewMCMCParameters(pHat,mcmc); %Set new std and theta0
        %2. Second explorative run to roughly (better) estimate conditional std and initial
        %values
        mcmc.n = mcmc.raftLewNmin; %number of iterations
        if(environment.verbose)
            disp(['*** Simulating second explorative MCMC run for ' num2str(mcmc.n) ' iterations...']);
        end
        tic;
        [pHat, accept, ll] = runMCMC(data,mcmc,modelParameters,model,environment); %Run MCMC
        timeSecondRun = toc;
        if(environment.verbose)
            disp(['*** MCMC Finished! , Time: ' num2str(timeSecondRun/60) ' min.']);
        end
        [mcmc] = setNewMCMCParameters(pHat,mcmc); %Set new std and theta0
        
        %Set the ETA for 600 iterations
        timeFor600 = (timeFirstRun/60 + timeSecondRun/60)/2; %[min]
        
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
            
            mcmc.n = nextN;
            nIterations = nIterations + 1;
            
            %Set the maximum ETA to limitETA hours and 
            ETA = timeFor600*mcmc.n/600;
            limitETA = mcmc.maxETAPerMCMCRun*60; %[min]
            if(ETA > limitETA)
                limitedN = (limitETA * 600)/timeFor600;
                limitedN = ceil(limitedN)
                if(environment.verbose)
                    disp(['*** WARNING: ETA greater than the maximum allowed ETA per MCMC run. Setting the number of MCMC iterations so that ETA is equal to the maximum allowed ETA. (Originally: ' num2str(mcmc.n) ', now: ' num2str(limitedN) ')']);
                end
                mcmc.n = limitedN;
                runWithMaxETA = runWithMaxETA + 1;
            end
            
            if(mcmc.n > mcmc.maxMCMCIterations)
                if(environment.verbose)
                    disp(['*** WARNING: Number of MCMC iterations greater than the maximum allowed number of MCMC iterations. Setting the number of MCMC iterations to the maximum allowed ETA. (Originally: ' num2str(mcmc.n) ', now: ' num2str(mcmc.maxMCMCIterations) ')']);
                end
                mcmc.n = mcmc.maxMCMCIterations;
                ETA = timeFor600*mcmc.n/600;
            end
    
            if(environment.verbose)
                tic;
                disp(['*** Simulating MCMC run number ' num2str(nIterations) ' for ' num2str(mcmc.n) ' iterations (ETA ~ ' num2str(ETA) ' min)...']);
            end
            [pHat, accept, ll] = runMCMC(data,mcmc,modelParameters,model,environment);  %Run MCMC
            if(environment.verbose)
                timeRun = toc;
                disp(['*** MCMC Finished! , Time: ' num2str(timeRun/60) ' min.']);
            end
            draws = zeros(mcmc.n,length(mcmc.thetaNames));
            for p = 1:length(mcmc.thetaNames)
                draws(:,p) = pHat.(mcmc.thetaNames{p});
            end %for p
            conv = rafteryLewis(draws,mcmc.raftLewQ,mcmc.raftLewR,mcmc.raftLewS); %Raftery Lewis diagnostics
            
            %Save (intermediate) results
            name = ['mcmcChain_par'];
            for p = 1:length(mcmc.thetaNames)
                name = [name '-' mcmc.thetaNames{p}];
            end %for p
            
            %Save the chain
            if(mcmc.saveChains)
                save(fullfile(environment.replayBGPath,'results','mcmcChains',[name '_iter' num2str(k-1) '_' environment.saveName]),'mcmc', 'pHat', 'accept', 'll', 'conv');
            end
            
            %Set new std and theta0
            [mcmc] = setNewMCMCParameters(pHat,mcmc); 
            
            k = k+1;
            
            %Compute the next MCMC number of iterations using Raftery Lewis
            nextN = max(conv.N_total);
            
        end % while
        
        if(nextN < (mcmc.n*1.1))
            disp('ReplayBG model was successfully identified.');
        else
            if(runWithMaxETA == mcmc.maxMCMCRunsWithMaxETA && nextN > (mcmc.n*1.1))
                disp('WARNING: Identification procedure stopped because the maximum number of MCMC runs having maximum allowed ETA reached.');
            end
            if(nIterations == mcmc.maxMCMCRuns)
                disp('WARNING: Identification procedure stopped because the maximum allowed number of MCMC iterations was reached.');
            end
        end
    % =====================================================================

    %% ========== Parameter estimates  ====================================  
    
        draws = struct();
        paramsForCopula = zeros(length(pHat.(mcmc.thetaNames{1})(max(conv.M_burn):max(conv.k_ind):end)),mcmc.nPar);
                
        switch(mcmc.estimator)
            case "mean"
                
                for p = 1:length(mcmc.thetaNames)
                    
                    draws.(mcmc.thetaNames{p}).chain = pHat.(mcmc.thetaNames{p})(max(conv.M_burn):max(conv.k_ind):end);
                    draws.(mcmc.thetaNames{p}).min = min(draws.(mcmc.thetaNames{p}).chain);
                    draws.(mcmc.thetaNames{p}).max = max(draws.(mcmc.thetaNames{p}).chain);

                    paramsForCopula(:,p) = ksdensity(draws.(mcmc.thetaNames{p}).chain,draws.(mcmc.thetaNames{p}).chain,'function','cdf');        
                    
                    %Obtain a point-estimate of model parameters
                    distributions.(mcmc.thetaNames{p}) = pHat.(mcmc.thetaNames{p})(conv.M_burn(p):conv.k_ind(p):end);
                    modelParameters.(mcmc.thetaNames{p}) = mean(distributions.(mcmc.thetaNames{p}));
                    
                end %for p
                modelParameters.kgri = modelParameters.kempt;
                
            case "map"
                
                for p = 1:length(mcmc.thetaNames)                    
                    
                    draws.(mcmc.thetaNames{p}).chain = pHat.(mcmc.thetaNames{p})(max(conv.M_burn):max(conv.k_ind):end);
                    draws.(mcmc.thetaNames{p}).min = min(draws.(mcmc.thetaNames{p}).chain);
                    draws.(mcmc.thetaNames{p}).max = max(draws.(mcmc.thetaNames{p}).chain);
                    
                    paramsForCopula(:,p) = ksdensity(draws.(mcmc.thetaNames{p}).chain,draws.(mcmc.thetaNames{p}).chain,'function','cdf');
                    
                    %Obtain a point-estimate of model parameters
                    distributions.(mcmc.thetaNames{p}) = pHat.(mcmc.thetaNames{p})(conv.M_burn(p):conv.k_ind(p):end);
                    kernel = histfit(distributions.(mcmc.thetaNames{p}),round(length(distributions.(mcmc.thetaNames{p}))/3),'kernel');
                    modelParameters.(mcmc.thetaNames{p}) = kernel(2).XData(find(kernel(2).YData == max(kernel(2).YData),1','first'));
                    
                    %edges = histogram(par,round(length(par)/3)).BinEdges;
                    %counts = histogram(par,round(length(par)/3)).BinCounts;
                    %imax = find(max(counts)==counts,1,'first');
                    %modelParameters.(mcmc.thetaNames{p}) = (edges(imax)+edges(imax+1))/2;

                end %for p
                modelParameters.kgri = modelParameters.kempt;
                
        end
        
        %Fit the copula
        [Rho,nu] = copulafit('t',paramsForCopula,'Method','ApproximateML');
        %Generate 1000 samples
        r = copularnd('t',Rho,nu,1000);
        %Scale the samples back to the original scale of the data
        for p = 1:length(mcmc.thetaNames)       
            draws.(mcmc.thetaNames{p}).samples = ksdensity(draws.(mcmc.thetaNames{p}).chain,r(:,p),'function','icdf');
        end
        
        %Save distributions here 
        save(fullfile(environment.replayBGPath,'results','distributions',['distributions_' environment.saveName]),'mcmc','distributions','draws');
            
    % =====================================================================
    
    %% ========== Save modelParameters for future usage  ==================
        save(fullfile(environment.replayBGPath,'results','modelParameters',['modelParameters_' environment.saveName]),'modelParameters');
    % =====================================================================
    
 end