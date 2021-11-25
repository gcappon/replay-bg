function [cgmErrorParameters, outputNoiseSD] = connectNewCGM(sensors)
% function  connectNewCGM(sensors)
% Connectsa new CGM sensors by sampling new error parameters 
%
% Inputs:
%   - sensors: a structure that contains general parameters of the
%   sensors models.
% Outputs:
%   - cgmErrorParameters: a vector containing the parameters of the CGM
%   error model;
%   - outputNoiseSD: the output standard deviation of the CGM error model.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2021 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

        % Sample a realization of model parameters, checking the stability of the AR(2) model of noise
        
        % Note: Maximum output SD of noise is set to sensors.cgm.maxOutputNoiseSD
        stable = 0; % Flag for stability of the AR(2) model
        outputNoiseSD = inf;
        while ~ stable || outputNoiseSD > sensors.cgm.maxOutputNoiseSD
            
            %Sample CGM error parameters
            cgmErrorParameters = mvnrnd(sensors.cgm.mu,sensors.cgm.sigma,1)';
            
            %Check the stability of the resulting AR(2) model
            stable = ((cgmErrorParameters(6)) >= -1) & ((cgmErrorParameters(6)) <= (1-abs(cgmErrorParameters(5))- sensors.cgm.toll));
            
            %Compute the output noise standard deviation
            outputNoiseSD = sqrt(cgmErrorParameters(7)^2 / (1- cgmErrorParameters(5)^2/(1-cgmErrorParameters(6)) - cgmErrorParameters(6)*(cgmErrorParameters(5)^2/(1-cgmErrorParameters(6))+cgmErrorParameters(6))));
        
        end
    
end