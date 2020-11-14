function [glucose, insulinBolus, correctionBolus, insulinBasal, CHO, hypotreatments] = replayScenario(data,modelParameters,draws,environment,model,mcmc,dss)
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
%   identification procedure;
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system.
% Outputs:
%   - glucose: a structure which contains the obtained glucose traces 
%   simulated via ReplayBG
%   - insulinBolus: a structure containing the input bolus insulin used to
%   obtain glucose (U/min);
%   - correctionBolus: a structure containing the correction bolus insulin used to
%   obtain glucose (U/min);
%   - insulinBasal: a structure containing the input basal insulin used to
%   obtain glucose (U/min);
%   - CHO: a structure containing the input CHO used to obtain glucose
%   (g/min);
%   - hypotreatments: a structure containing the input hypotreatments used 
%   to obtain glucose (g/min).
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

    %Obtain the glicemic realizations using the copula-generated parameter samples
    
    %Initialize the structures
    glucose.realizations = zeros(height(data),length(draws.(mcmc.thetaNames{1}).samples));
    insulinBolus.realizations = zeros(model.TIDSTEPS,length(draws.(mcmc.thetaNames{1}).samples));
    correctionBolus.realizations = zeros(model.TIDSTEPS,length(draws.(mcmc.thetaNames{1}).samples));
    insulinBasal.realizations = zeros(model.TIDSTEPS,length(draws.(mcmc.thetaNames{1}).samples));
    CHO.realizations = zeros(model.TIDSTEPS,length(draws.(mcmc.thetaNames{1}).samples));
    hypotreatments.realizations = zeros(model.TIDSTEPS,length(draws.(mcmc.thetaNames{1}).samples));
    
    %For each parameter set...
    for r = 1:length(draws.(mcmc.thetaNames{1}).samples)
        
        %...set the modelParameter structure to such a set...
        for p = 1:length(mcmc.thetaNames)
            modelParameters.(mcmc.thetaNames{p}) = draws.(mcmc.thetaNames{p}).samples(r);
        end
        modelParameters.kgri = modelParameters.kempt;
        
        %...and simulate the scenario using the given data
        [G, iB, cB, ib, C, ht, ~] = computeGlicemia(modelParameters,data,model,dss);
        glucose.realizations(:,r) = G(1:model.YTS:end);
        insulinBolus.realizations(:,r) = iB;
        correctionBolus.realizations(:,r) = cB;
        insulinBasal.realizations(:,r) = ib;
        CHO.realizations(:,r) = C;
        hypotreatments.realizations(:,r) = ht;
        
    end
    
    %Obtain the median glucose trace and confidence intervals
    glucose.median = zeros(height(data),1);
    glucose.ci25th = zeros(height(data),1);
    glucose.ci75th = zeros(height(data),1);
    glucose.ci5th = zeros(height(data),1);
    glucose.ci95th = zeros(height(data),1);
    
    for g = 1:length(glucose.median)
        
        glucose.median(g) = prctile(glucose.realizations(g,:),50);
        glucose.ci25th(g) = prctile(glucose.realizations(g,:),25);
        glucose.ci75th(g) = prctile(glucose.realizations(g,:),75);
        glucose.ci5th(g) = prctile(glucose.realizations(g,:),5);
        glucose.ci95th(g) = prctile(glucose.realizations(g,:),95);
        
    end
    
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
end