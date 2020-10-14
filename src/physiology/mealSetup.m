function [meal] = mealSetup(data,model,modelParameters)
% function  mealSetup(data,model,modelParameters)
% Generates the vector containing the CHO intake events to be used to
% simulate the physiological model.
%
% Inputs:
%   - data: a timetable which contains the data to be used by the tool;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - modelParameters: a struct containing the model parameters.
% Outputs:
%   - meal: is a vector containing the carbohydrate intake at each time
%   step [mg/min*kg].
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    %Initialize the meal vector
    meal = zeros(model.TIDSTEPS,1);
    
    %Set the meal vector
    for time = 1:length(0:5:(model.TID-1))
        meal((1+(time-1)*(5/model.TS)):(time*(5/model.TS))) = data.CHO(time)*1000/modelParameters.BW; %mg/(kg*min)
    end
    
end