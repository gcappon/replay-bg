function [cgm, glucose, insulinBolus, correctionBolus, insulinBasal, CHO, hypotreatments] = replayScenario(data,modelParameters,draws,environment,model,sensors,mcmc,dss)
% function  replayScenario(data,modelParameters,draws,environment,model,sensors,mcmc,dss)
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
%   - sensors: a structure that contains general parameters of the
%   sensors models;
%   - mcmc: a structure that contains the hyperparameters of the MCMC
%   identification procedure;
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system.
% Outputs:
%   - cgm: a structure which contains the obtained cgm traces 
%   simulated via ReplayBG;
%   - glucose: a structure which contains the obtained glucose traces 
%   simulated via ReplayBG;
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
    cgm.realizations = zeros(model.TYSTEPS,length(draws.(mcmc.thetaNames{1}).samples));
    glucose.realizations = zeros(model.TSTEPS,length(draws.(mcmc.thetaNames{1}).samples));
    insulinBolus.realizations = zeros(model.TSTEPS,length(draws.(mcmc.thetaNames{1}).samples));
    correctionBolus.realizations = zeros(model.TSTEPS,length(draws.(mcmc.thetaNames{1}).samples));
    insulinBasal.realizations = zeros(model.TSTEPS,length(draws.(mcmc.thetaNames{1}).samples));
    CHO.realizations = zeros(model.TSTEPS,length(draws.(mcmc.thetaNames{1}).samples));
    hypotreatments.realizations = zeros(model.TSTEPS,length(draws.(mcmc.thetaNames{1}).samples));
    
    %physioCheck = zeros(length(draws.(mcmc.thetaNames{1}).samples),1);
    
    %For each parameter set...
    for r = 1:length(draws.(mcmc.thetaNames{1}).samples)
        
        %...set the modelParameter structure to such a set...
        for p = 1:length(mcmc.thetaNames)
            modelParameters.(mcmc.thetaNames{p}) = draws.(mcmc.thetaNames{p}).samples(r);
        end
        
        %Enforce model constraints
        modelParameters = enforceConstraints(modelParameters, model, environment);
        
        %...check model parameter physiological plausibility...
        %check = checkIdentifiedParameters(modelParameters);
        %physioCheck(r) = all(struct2array(check));
        
        %...and simulate the scenario using the given data
        [G, CGM, iB, cB, ib, C, ht, ~] = computeGlicemia(modelParameters,data,model,sensors,dss,environment);
        cgm.realizations(:,r) = CGM;
        glucose.realizations(:,r) = G;
        insulinBolus.realizations(:,r) = iB;
        correctionBolus.realizations(:,r) = cB;
        insulinBasal.realizations(:,r) = ib;
        CHO.realizations(:,r) = C;
        hypotreatments.realizations(:,r) = ht;
        
    end
    
    %Obtain the median cgm trace and confidence intervals
    cgm.median = zeros(model.TYSTEPS,1);
    cgm.ci25th = zeros(model.TYSTEPS,1);
    cgm.ci75th = zeros(model.TYSTEPS,1);
    cgm.ci5th = zeros(model.TYSTEPS,1);
    cgm.ci95th = zeros(model.TYSTEPS,1);
    
    for g = 1:length(cgm.median)
        
        cgm.median(g) = prctile(cgm.realizations(g,:),50);
        cgm.ci25th(g) = prctile(cgm.realizations(g,:),25);
        cgm.ci75th(g) = prctile(cgm.realizations(g,:),75);
        cgm.ci5th(g) = prctile(cgm.realizations(g,:),5);
        cgm.ci95th(g) = prctile(cgm.realizations(g,:),95);
        
    end
    
    %Obtain the median glucose trace and confidence intervals
    glucose.median = zeros(model.TSTEPS,1);
    glucose.ci25th = zeros(model.TSTEPS,1);
    glucose.ci75th = zeros(model.TSTEPS,1);
    glucose.ci5th = zeros(model.TSTEPS,1);
    glucose.ci95th = zeros(model.TSTEPS,1);
    
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