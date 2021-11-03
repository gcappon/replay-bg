function model = initModel(data,sampleTime,cgmModel,glucoseModel, pathology, seed, environment)
% function  initModel(data,sampleTime,cgmModel,glucoseModel,seed)
% Initializes the 'model' core variable.
%
% Inputs:
%   - data: timetable which contains the data to be used by the tool;
%   - sampleTime: an integer that specifies the data sample time;
%   - cgmModel: a vector of characters that specifies the glucose 
%   - glucoseModel: a vector of characters that specifies the glucose 
%   model to use;
%   - pathology: a vector of characters that specifies the pathology 
%   related to the given data;
%   - seed: an integer that specifies the random seed. For reproducibility;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Outputs:
%   - model: a structure that contains general parameters of the
%   physiological model.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    %Time constants within the simulation
    model.TS = 1; %integration time
    model.YTS = sampleTime; %sample time
    model.TID = minutes(data.Time(end)-data.Time(1))+sampleTime; %from 1 to TID identify the model parameters. [min]
    model.TIDSTEPS = model.TID/model.TS; %from 1 to TID identify the model parameters. [integration steps]
    model.TIDYSTEPS = model.TID/model.YTS; %total identification simulation time [sample steps]
    
    %Data hyperparameters
    model.cgmModel = cgmModel; %glucose selection {'CGM','BG','IG'}
    model.glucoseModel = glucoseModel; %glucose selection {'BG','IG'}
    model.pathology = pathology; %model selection {'t1d','t2d','pbh'}
    
    %Model dimensionality
    switch(model.pathology)
        case 't1d'
            
            switch(environment.scenario)
                case 'single-meal'
                    model.nx = 9; %number of states
                case 'multi-meal'
                    model.nx = 21; %number of states
            end
            
        case 't2d'
            %TODO: implement t2d model
        case 'pbh'
            %TODO: implement pbh model
        case 'healthy'
            %TODO: implement healthy model
    end
    
    %Patient specific parameters
    model.seed = seed;
    
    %Set the rng seed
    rng(seed,'twister')
    
end