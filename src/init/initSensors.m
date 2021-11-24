function sensors = initSensors(cgmModel, model, environment)
% function  initSensors(cgmModel,glucoseModel, pathology, seed, environment)
% Initializes the 'sensors' core variable.
%
% Inputs:
%   - cgmModel: a vector of characters that specifies the glucose;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Outputs:
%   - sensors: a structure that contains general parameters of the
%   sensors models.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    if(environment.verbose)
            fprintf('Setting up the sensors hyperparameters...');
            tic;
    end
    
    
    sensors.cgm.TS = model.YTS; %sample time of the cgm sensor. Set equal to the sample time of the measurements.
    
    sensors.cgm.model = cgmModel; %glucose selection {'CGM','BG','IG'}
    
    %If the CGM model is selected, then set its parameters
    if(strcmp(sensors.cgm.model,'CGM'))
        
        %Load  Mean vector and covariance matrix of the parameter vector
        load(fullfile(environment.replayBGPath,'src','sensors','cgmErrorDistribution'));
        
        sensors.cgm.mu = MU;
        sensors.cgm.sigma = Sigma;
        % Modulation factor of the covariance of the parameter vector not to generate too extreme realizations of parameter vector
        f = 0.70;
        
        % Maximum output noise SD allowed
        maxOutputNoiseSD = 10; % mg/dl

        % Modulate the covariance matrix
        sensors.cgm.sigma = sensors.cgm.sigma*f;

        % Sample a realization of model parameters, checking the stability of the AR(2) model of noise
        % Note: Maximum output SD of noise is set to max_output_noise_sd
        stable = 0; % Flag for stability of the AR(2) model
        outputNoiseSD = 100;
        toll = 0.02;
        while ~ stable || outputNoiseSD > maxOutputNoiseSD
            cgmErrorParameters = mvnrnd(sensors.cgm.mu,sensors.cgm.sigma,1)';
            stable = ((cgmErrorParameters(6)) >= -1) & ((cgmErrorParameters(6)) <= (1-abs(cgmErrorParameters(5))-toll));
            outputNoiseSD = sqrt(cgmErrorParameters(7)^2 / (1- cgmErrorParameters(5)^2/(1-cgmErrorParameters(6)) - cgmErrorParameters(6)*(cgmErrorParameters(5)^2/(1-cgmErrorParameters(6))+cgmErrorParameters(6))));
        end
        sensors.cgm.errorParameters = cgmErrorParameters;
        sensors.cgm.outputNoiseSD = outputNoiseSD;

    end
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
end