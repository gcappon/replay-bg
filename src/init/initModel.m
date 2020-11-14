function model = initModel(data,sampleTime,glucoseModel,seed)
% function  initModel(data,sampleTime,glucoseModel,seed)
% Initializes the 'model' core variable.
%
% Inputs:
%   - data: timetable which contains the data to be used by the tool;
%   - sampleTime: an integer that specifies the data sample time;
%   - glucoseModel: a vector of characters that specifies the glucose 
%   model to use;
%   - seed: an integer that specifies the random seed. For reproducibility. 
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
    model.glucoseModel = glucoseModel; %glucose selection {'BG','IG'}
    
    %Model dimensionality
    model.nx = 9; %number of states
    
    %Patient specific parameters
    model.seed = seed;
    
    %Set the rng seed
    rng(seed,'twister')
    
end