function [bolus, basal] = insulinSetup(data,model,modelParameters)
% function  insulinSetup(data,model,modelParameters)
% Generates the vector containing the insulin infusions to be used to
% simulate the physiological model.
%
% Inputs:
%   - data: a timetable which contains the data to be used by the tool;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - modelParameters: a struct containing the model parameters.
% Outputs:
%   - bolus: is a vector containing the insulin bolus dose at each time
%   step [mU/min];
%   - basal: is a vector containing the basal insulin value at each time
%   step [mU/min].
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    %Initialize the basal and bolus vectors
    basal = zeros(model.TIDSTEPS,1);
    bolus = zeros(model.TIDSTEPS,1);
    
    %Set the basal and bolus vectors
    for time = 1:length(0:5:(model.TID-1))
        bolus((1+(time-1)*(model.YTS/model.TS)):(time*(model.YTS/model.TS))) = data.bolus(time)*1000/modelParameters.BW; %mU/(kg*min)
        basal((1+(time-1)*(model.YTS/model.TS)):(time*(model.YTS/model.TS))) = data.basal(time)*1000/modelParameters.BW; %mU/(kg*min)
    end
    
end 
