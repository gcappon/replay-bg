function glucose = replayScenario(data,modelParameters,draws,environment,model,mcmc)
% function  replayScenario(data,modelParameters,draws,environment,model,mcmc)
% Replays the given scenario defined by the given data.
%
% Inputs:
%   - data: timetable which contains the data to be used by the tool;
%   - modelParameters: a struct containing the model parameters;
%   - draws: a structure that contains the modelParameter draws obtained
%   with MCMC;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - mcmc: a structure that contains the hyperparameters of the MCMC
%   identification procedure.
% Output:
%   - glucose: a structure which contains the obtained glucose traces 
%   simulated via ReplayBG.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    if(environment.verbose)
        tic;
        fprintf(['Replaying scenario...']);
    end

    %Obtain the glicemic realizations using the copula-generated parameter
    %samples
    glucose.realizations = zeros(height(data),length(draws.(mcmc.thetaNames{1}).samples));
    for r = 1:length(draws.(mcmc.thetaNames{1}).samples)
        
        for p = 1:length(mcmc.thetaNames)
            modelParameters.(mcmc.thetaNames{p}) = draws.(mcmc.thetaNames{p}).samples(r);
        end
        
        [G, x] = computeGlicemia(modelParameters,data,model);
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
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
end