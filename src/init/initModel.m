function model = initModel(data,sampleTime,glucoseModel, pathology, seed, environment)
% function  initModel(data,sampleTime,glucoseModel, pathology, seed, environment)
% Initializes the 'model' core variable.
%
% Inputs:
%   - data: timetable which contains the data to be used by the tool;
%   - sampleTime: an integer that specifies the data sample time;
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
    
    if(environment.verbose)
            fprintf('Setting up the model hyperparameters...');
            tic;
    end
    
    %Time constants within the simulation
    model.TS = 1; %integration time
    model.YTS = sampleTime; %sample time
    model.T = minutes(data.Time(end)-data.Time(1))+sampleTime; %simulation timespan [min]
    model.TSTEPS = model.T/model.TS; %total simulation length [integration steps]
    model.TYSTEPS = model.T/model.YTS; %total simulation length [sample steps]
    
    %Data hyperparameters
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
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
end