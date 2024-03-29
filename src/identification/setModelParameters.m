function [modelParameters, mcmc, draws] = setModelParameters(data,BW,environment,mcmc,model,sensors, dss)
% function  setModelParameters(data,BW,environment,mcmc,model,sensors,dss)
% Sets the parameters of the physiological model.
%
% Inputs:
%   - data: timetable which contains the data to be used by the tool;
%   - BW: the patient's body weight;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG;
%   - mcmc: a structure that contains the hyperparameters of the MCMC
%   identification procedure;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - sensors: a structure that contains general parameters of the
%   sensors models;
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system.
% Outputs:
%   - modelParameters: a struct containing the model parameters;
%   - mcmc: the updated structure that contains the hyperparameters of the 
%   MCMC identification procedure;
%   - draws: a structure that contains 1000 realizations of modelParameter obtained with MCMC.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    if(strcmp(environment.modality,'identification'))
        
        if(environment.verbose)
            st = [mcmc.thetaNames{1}];
            for s = 2:mcmc.nPar
                st = [st ' ' mcmc.thetaNames{s}];
            end %for s
            tic;
            fprintf(['Identifying ReplayBG model using MCMC on ' st '...\n']);
        end
        
        %Connect a CGM sensor if sensors.cgmModel is CGM
        if(strcmp(sensors.cgm.model,'CGM'))
            [sensors.cgm.errorParameters, sensors.cgm.outputNoiseSD] = connectNewCGM(sensors);
        end
        
        %Identify model parameters (if modality: 'identification')
        [modelParameters, draws] = identifyModelParameters(data, BW, mcmc, model, sensors, dss, environment);
        
        % Check model parameters 
        draws.physiologicalPlausibility = checkPhysiologicalPlausibility(data,modelParameters,draws,environment,model,sensors,mcmc,dss);
        
    else
        
        if(environment.verbose)
            tic;
            fprintf(['Loading model parameters...']);
        end
        
        %Load the model parameters (if modality: 'replay')
        load(fullfile(environment.replayBGPath,'results','modelParameters',environment.saveFolder,['modelParameters_' environment.saveName]));
        load(fullfile(environment.replayBGPath,'results','distributions',environment.saveFolder,['distributions_' environment.saveName]));

    end
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
end