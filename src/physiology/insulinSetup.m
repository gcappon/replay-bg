function [bolus, basal, bolusDelayed, basalDelayed] = insulinSetup(data,model,modelParameters,environment)
% function  insulinSetup(data,model,modelParameters)
% Generates the vector containing the insulin infusions to be used to
% simulate the physiological model.
%
% Inputs:
%   - data: a timetable which contains the data to be used by the tool;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - modelParameters: a struct containing the model parameters;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Outputs:
%   - bolus: is a vector containing the insulin bolus dose at each time
%   step [mU/min*kg];
%   - basal: is a vector containing the basal insulin value at each time
%   step [mU/min*kg];
%   - bolusDelayed: is a vector containing the insulin bolus dose at each time
%   step delayed by tau min [mU/min*kg];
%   - basalDelayed: is a vector containing the basal insulin value at each time
%   step delayed by tau min [mU/min*kg];
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    %Initialize the basal and bolus vectors
    basal = zeros(model.TSTEPS,1);
    bolus = zeros(model.TSTEPS,1);
    
    if(strcmp(environment.bolusSource,'data'))
        
        %Find the boluses
        bIdx = find(data.bolus);

        %Set the bolus vector
        for i = 1:length(bIdx)
            bolus((1+(bIdx(i)-1)*(model.YTS/model.TS)):(bIdx(i)*(model.YTS/model.TS))) = data.bolus(bIdx(i))*1000/modelParameters.BW; %mU/(kg*min)
        end
         
    end
    
    if(strcmp(environment.basalSource,'data'))
        
        %Set the basal vector
        for time = 1:length(0:model.YTS:(model.TSTEPS-1))
            basal((1+(time-1)*(model.YTS/model.TS)):(time*(model.YTS/model.TS))) = data.basal(time)*1000/modelParameters.BW; %mU/(kg*min)
        end
         
    end
        
    %Add delay in insulin absorption
    bolusDelay = floor(modelParameters.tau/model.TS); 
    
    bolusDelayed = [zeros(bolusDelay,1); bolus];
    bolusDelayed = bolusDelayed(1:model.TSTEPS);
    
    basalDelayed = [ones(bolusDelay,1)*basal(1); basal];
    basalDelayed = basalDelayed(1:model.TSTEPS);
        
end 
