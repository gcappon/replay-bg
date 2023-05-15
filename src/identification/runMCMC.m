function [pHat, accept, ll] = runMCMC(data,mcmc,mP,model,sensors,dss,environment)
% function  runMCMC(data,mcmc,mP,model,sensors,environment)
% Performs a run of the MCMC identification procedure.
%
% Inputs:
%   - data: a timetable which contains the data to be used by the tool;
%   - mcmc: a structure that contains the hyperparameters of the MCMC
%   identification procedure;
%   - mP: a struct containing the model parameters;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - sensors: a structure that contains general parameters of the
%   sensors models;
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Outputs:
%   - pHat: is a structure containing the MCMC chain realizations;
%   - accept: is a vector containing the acceptance rate of each MCMC
%   block;
%   - ll: is a vector containing the values the likelihood take through the
%   simulation.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    %Prealloc accept and ll
    accept = zeros(mcmc.nBlocks,1);
    ll = zeros(mcmc.n,1);
    
    %Set the initial parameter values and prealloc pHat
    for p = 1:length(mcmc.theta0)
        mP.(mcmc.thetaNames{p}) = mcmc.theta0(p);
        pHat.(mcmc.thetaNames{p}) = zeros(mcmc.n,1);
    end %for p
    
    %Prealloc utility variables to speed up
    blockIdxs = cell(mcmc.nBlocks,1);
    nPar = cell(mcmc.nBlocks,1);
    X = cell(mcmc.nBlocks,1);
    Y = cell(mcmc.nBlocks,1);
    for block = 1:mcmc.nBlocks
        blockIdxs{block} = find(mcmc.parBlock==block);
        nPar{block} = length(blockIdxs{block});
        X{block} = zeros(nPar{block},1);
        Y{block} = zeros(nPar{block},1);
    end
    
    %Define the prior probability density functions
    prior = definePriorPDF(model, environment);
    
    %Enforce parameter starting condition constraints
    mP = enforceConstraints(mP,model,environment);
    
    %Set the measurement vector
    y = data.glucose; 
    
    %If specified, filter measurements with a 4-th order Butterworth filter
    if(mcmc.preFilterData)
        [bFilt,aFilt] = butter(4,0.2);
        y = filtfilt(bFilt,aFilt,y);
    end
    
    %Identify the non-nan values
    nonNanIdx = find(~isnan(y));
    
    %Get the number of samples
    N = model.TYSTEPS;
    
    %Run MCMC
    for run = 1:mcmc.n

        for block = 1:mcmc.nBlocks
            
            blockIdx = blockIdxs{block};
            
            % ============== Run simulation X =============================
            %Memorize model parameters into X
            for p = 1:nPar{block}
                X{block}(p) = mP.(mcmc.thetaNames{blockIdx(p)});
            end %for p
            
            %Enforce parameter constraints
            mP = enforceConstraints(mP,model,environment);
            
            %Compute glicemia given the data and model parameters
            G = computeGlicemia(mP,data,model,sensors,dss,environment);
            G = G(1:(model.YTS/model.TS):end);
            
            %Compute the log-likelihood lX
            switch(mP.typeN)
                case 'CV'
                    lX = -(N/2)*log(2*pi)-(N/2)*log(((y(nonNanIdx).*mP.CVn)^2))-0.5*sum(((G(nonNanIdx)-y(nonNanIdx))/(y(nonNanIdx).*mP.CVn)).^2);
                case 'SD'
                    lX = -(N/2)*log(2*pi)-(N/2)*log((mP.SDn^2))-0.5*sum(((G(nonNanIdx)-y(nonNanIdx))/mP.SDn).^2);
            end
            
            %Compute pi(X) by adding the log-prior to lX
            piX = lX;
            for p = 1:nPar{block}
                piX = piX + log(prior.(mcmc.thetaNames{blockIdx(p)})(mP));
            end %for p
            % =============================================================

            % ============== Run simulation Y =============================
            %Adapt the proposal covariance if needed
            if(mcmc.adaptiveSCMH && run >= mcmc.adaptationFrequency && mod(run,mcmc.adaptationFrequency)==0)
                %Transform pHat to a matrix K
                K = zeros(mcmc.adaptationFrequency-1,nPar{block});
                for p = 1:nPar{block}
                    K(:,p) = pHat.(mcmc.thetaNames{blockIdx(p)})((run-mcmc.adaptationFrequency+1):(run-1));
                end %for p
                mcmc.covar{block} = diag(diag(cov(K)));
            end
            
            %Sample Y
            Y{block} = mvnrnd(X{block},2.4^2/nPar{block}*mcmc.covar{block}); 

            %Update model parameters with the sampled Y
            for p = 1:nPar{block}
                mP.(mcmc.thetaNames{blockIdx(p)}) = Y{block}(p);
            end %for p

            %Enforce parameter constraints
            mP = enforceConstraints(mP,model,environment);
            
            %Compute glicemia given the data and model parameters
            G = computeGlicemia(mP,data,model,sensors,dss,environment);
            G = G(1:(model.YTS/model.TS):end);
            
            %Compute the log-likelihood lY
            switch(mP.typeN)
                case 'CV'
                    lY = -(N/2)*log(2*pi)-(N/2)*log(((y(nonNanIdx).*mP.CVn)^2))-0.5*sum(((G(nonNanIdx)-y(nonNanIdx))/(y(nonNanIdx).*mP.CVn)).^2);
                case 'SD'
                    lY = -(N/2)*log(2*pi)-(N/2)*log((mP.SDn^2))-0.5*sum(((G(nonNanIdx)-y(nonNanIdx))/mP.SDn).^2);
            end
            
            %Compute pi(Y) by adding the log-prior to lY
            piY = lY;
            for p = 1:nPar{block}
                piY = piY + log(prior.(mcmc.thetaNames{blockIdx(p)})(mP));
            end %for p
            % =============================================================

            % ============== Metropolis step ==============================
            %Draw a uniform distributed sample
            U = rand(1);
            
            %Compute the acceptance probability 
            alfa = min(1,exp(piY-piX));
            
            %Accept/reject mechanism
            if(U<=alfa && ~isnan(exp(piY-piX)))
                X{block} = Y{block};
                accept(block) = accept(block) + 1;
            end %if
            
            %Update mP
            for p = 1:nPar{block}
                mP.(mcmc.thetaNames{blockIdx(p)}) = X{block}(p);
                pHat.(mcmc.thetaNames{blockIdx(p)})(run) = X{block}(p);
            end %for p
            
            %Enforce parameter constraints
            mP = enforceConstraints(mP,model,environment);
            % =============================================================

        end %for block

        ll(run) = lX; %Save the likelihood value
       
        % ===== Plot current simulated trace for visual inspection ========
        if(environment.plotMode)
            
            if(mod(run,100)==0 || run == mcmc.n)
                
                [G, ~, ~, ~, ~, ~, ~, ~, ~, x] = computeGlicemia(mP,data,model,sensors,dss,environment);
                G = G(1:(model.YTS/model.TS):end);

                if(model.exercise)
                    subplot(6,1,1:3)
                else
                    subplot(5,1,1:3)
                end
                plot(data.Time,y,'r-*','linewidth',2);
                hold on

                plot(data.Time,G,'k-o','linewidth',2);
                legend y Ghat 
                hold off
                grid on
                
                title(['Run: ' num2str(run) ' of ' num2str(mcmc.n) '; LL: ' num2str(ll(run))]);
                xlabel('Time');
                ylabel('Glucose (mg/dl)');
                
                if(model.exercise)
                    subplot(6,1,4)
                else
                    subplot(5,1,4)
                end
                stem(data.Time,data.bolus,'k^','linewidth',2);
                ylabel('Bolus (U/min))');
                hold on
                legend Bolus 
                hold off
                grid on
                
                if(model.exercise)
                    subplot(6,1,5)
                else
                    subplot(5,1,5)
                end
                stem(data.Time,data.CHO,'k^','linewidth',2);
                hold on
                legend CHO 
                hold off
                grid on
                
                if(model.exercise)
                    subplot(6,1,6)
                    stem(data.Time,data.exercise,'k^','linewidth',2);
                    hold on
                    legend VO2 
                    hold off
                end
                xlabel('Iteration #');
                ylabel('CHO (g/min)');
                
                pause(1e-6);
                
            end %if plot

        end
        % =================================================================

    end %for run
    
    % =====================================================================

end
