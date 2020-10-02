function model = initModel(data,sampleTime,glucoseModel,seed)
% initModel Function that initialize the model hyperparameters.
% model = initModel(patId,environment,dataset) returns a structure containing the
% model hyperparameters.
% * Inputs:
%   - data: is a timetable containing the input (Insulin, CHO) and output (Glucose) data.
%   parameters.
%   - sampleTime: is a number defining the discrete model sample time.
%   - measurementModel: is a char vector defining the measurement model to
%   use.
%   - seed: is a number defining the rng seed.
% * Output:
%   - model: is a structure containing the model hyperparameters.
    
    %Time constants within the simulation
    model.TS = 1; %integration time
    model.YTS = sampleTime; %sample time
    model.TID = minutes(data.Time(end)-data.Time(1))+sampleTime; %from 1 to TID identify the model parameters. [min]
    model.TIDSTEPS = model.TID/model.TS; %from 1 to TID identify the model parameters. [integration steps]
    model.TIDYSTEPS = model.TID/model.YTS; %total simulation time [sample steps]
    
    %Data hyperparameters
    %simulation.MEASUREMENT = 'CGM'; %measurement model selection {'BG','IG','CGM'}
    model.glucoseModel = glucoseModel; %glucose selection {'BG','IG'}
    %simulation.Y = 'CGM'; %patient glucose measurements selection {'BG','IG','CGM'}
    
    %Model dimensionality
    model.nx = 9; %number of states
    %simulation.NR = 2; %order of the CGM error model
    
    %Patient specific parameters
    model.seed = seed;
    
end