function [pHat, accept, ll] = runMCMC(data,mcmc,mP,model,environment)
% function  runMCMC(data,mcmc,mP,model,environment)
% Performs a run of the MCMC identification procedure.
%
% Inputs:
%   - data: a timetable which contains the data to be used by the tool;
%   - mcmc: a structure that contains the hyperparameters of the MCMC
%   identification procedure;
%   - mP: a struct containing the model parameters;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Outputs:
%   - pHat: is a structure containing the parameter chains;
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
        
    %Set the prior probability functions
    prior.SI = @(mP) gampdf(mP.SI*mP.VG,2.5,4.5e-4);
    prior.SG = @(mP) lognpdf(mP.SG,-3.6,0.5);
    prior.p2 = @(mP) lognpdf(mP.p2,-4.3,0.35);
    prior.Gb = @(mP) normpdf(mP.Gb,120,10);
    
    prior.r1 = @(mP) lognpdf(mP.r1,0,0.3);
    prior.r2 = @(mP) lognpdf(mP.r2,0.7,0.25);
    
    prior.VI = @(mP) lognpdf(mP.VI,-2.0568,0.1128);
    prior.ke = @(mP) lognpdf(mP.ke,-2.0811,0.2977);
    prior.kd = @(mP) lognpdf(mP.kd,-3.5090,0.6187)*(mP.kd>=mP.ka2);
    prior.ka1 = @(mP) lognpdf(mP.ka1,-5.7775,0.6545);
    prior.ka2 = @(mP) lognpdf(mP.ka2,-4.2875,0.4274)*(mP.kd>=mP.ka2);
    prior.tau = @(mP) lognpdf(mP.tau,1.7869,1.1586)*(mP.tau <= 45);
    
    prior.kabs = @(mP) lognpdf(mP.kabs,-5.4591,1.4396)*(mP.kempt>=mP.kabs);
    prior.kempt = @(mP) lognpdf(mP.kempt,-1.9646,0.7069)*(mP.kempt>=mP.kabs);
    prior.alpha = @(mP) 1*(mP.alpha>0);
    
    prior.SDn = @(mP) 1*(mP.SDn>0);
    prior.CVn = @(mP) 1*(mP.CVn>0); 
    
    prior.Xpb = @(mP) 1*(mP.Xpb>=0 & mP.Xpb <= 0.01); 
    %prior.Xpb = @(mP) 1*(mP.Xpb>=0); 
    prior.Qgutb = @(mP) 1*(mP.Qgutb>=0);
    
    prior.beta = @(mP) 1*(mP.beta>=0 && mP.beta<=60);
            
    %Prealloc variables to speed up
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
    
    %Parameter starting condition constraints
    if(mP.kabs>mP.kempt)
        mP.kabs = mP.kempt;
    end
    if(mP.ka2>mP.kd)
        mP.ka2 = mP.kd;
    end
    
    y = data.glucose; %Measurement vector
    
    %Filter training data
    if(mcmc.filter)
        [bFilt,aFilt] = butter(4,0.2);
        y = filtfilt(bFilt,aFilt,y);
    end
    
    %Run MCMC
    for run = 1:mcmc.n

        for block = 1:mcmc.nBlocks
            
            blockIdx = blockIdxs{block};
            
            % ============== Run simulation X =============================
            for p = 1:nPar{block}
                X{block}(p) = mP.(mcmc.thetaNames{blockIdx(p)});
            end %for p
            mP.kgri = mP.kempt; %known from the literature
    
            G = computeGlicemia(mP,data,model)';
            G = G(1:(model.YTS/model.TS):end);
            
            N = model.TID/model.YTS;
            switch(mP.typeN)
                case 'CV'
                    lX = -(N/2)*log(2*pi)-(N/2)*log(((y.*mP.CVn)^2))-0.5*sum(((G-y)/(y.*mP.CVn)).^2);
                case 'SD'
                    lX = -(N/2)*log(2*pi)-(N/2)*log((mP.SDn^2))-0.5*sum(((G-y)/mP.SDn).^2);
            end
            
            piX = lX;
            for p = 1:nPar{block}
                piX = piX + log(prior.(mcmc.thetaNames{blockIdx(p)})(mP));
            end %for p
            % =============================================================

            % ============== Run simulation Y =============================
            Y{block} = X{block} + randn(nPar{block},1).*mcmc.std(blockIdx)';
            for p = 1:nPar{block}
                mP.(mcmc.thetaNames{blockIdx(p)}) = Y{block}(p);
            end %for p
            mP.kgri = mP.kempt; %known from the literature
      
            G = computeGlicemia(mP,data,model)';
            G = G(1:(model.YTS/model.TS):end);
            
            switch(mP.typeN)
                case 'CV'
                    lY = -(N/2)*log(2*pi)-(N/2)*log(((y.*mP.CVn)^2))-0.5*sum(((G-y)/(y.*mP.CVn)).^2);
                case 'SD'
                    lY = -(N/2)*log(2*pi)-(N/2)*log((mP.SDn^2))-0.5*sum(((G-y)/mP.SDn).^2);
            end
            
            piY = lY;
            for p = 1:nPar{block}
                piY = piY + log(prior.(mcmc.thetaNames{blockIdx(p)})(mP));
            end %for p
            % =============================================================

            % ============== Metropolis step ==============================
            U = rand(1);
            alfa = min(1,exp(piY-piX));
            if(U<=alfa && ~isnan(exp(piY-piX)))
                X{block} = Y{block};
                accept(block) = accept(block) + 1;
            end %if
            
            for p = 1:nPar{block}
                mP.(mcmc.thetaNames{blockIdx(p)}) = X{block}(p);
                pHat.(mcmc.thetaNames{blockIdx(p)})(run) = X{block}(p);
            end %for p
            % =============================================================

        end %for block

        ll(run) = lX; %Save the likelihood value
       
        % ===== Plot current simulated trace for visual inspection ========
        if(environment.plotMode)
            
            if(mod(run,100)==0 || run == mcmc.n)
                [G, x] = computeGlicemia(mP,data,model);
                G = G(1:(model.YTS/model.TS):end);

                subplot(4,1,1:2)
                plot(y,'b');
                hold on

                plot(G,'r');
                legend y Ghat 
                hold off
                switch(mP.typeN)
                    case 'SD'
                        title(['Run: ' num2str(run) ' of ' num2str(mcmc.n) '; LL: ' num2str(ll(run))] );
                    case 'CV'
                        title(['Run: ' num2str(run) ' of ' num2str(mcmc.n) '; LL: ' num2str(ll(run))] );
                end
                subplot(413)
                plot(x(2,:))
                title('X')
                subplot(414)
                plot(x(8,:))
                title('Qgut')
                pause(0.00001);
                
            end %if plot
        end
        % =================================================================

    end %for run
    
    % =====================================================================

end
