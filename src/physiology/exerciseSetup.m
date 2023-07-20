function vo2 = exerciseSetup(data,model,modelParameters,environment)
% function  exerciseSetup(data,model,modelParameters,environment)
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
%   - vo2: is a vector containing the normalized VO2 at each time when
%   there is exercise (-).
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2023 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    %Initialize the basal and bolus vectors
    vo2 = zeros(model.TSTEPS,1);
    
    %if(strcmp(environment.bolusSource,'data'))
    
    if(model.exercise)
        %Find the boluses
        eIdx = find(data.exercise);

        %Set the bolus vector
        for i = 1:length(eIdx)
            vo2((1+(eIdx(i)-1)*(model.YTS/model.TS)):(eIdx(i)*(model.YTS/model.TS))) = data.exercise(eIdx(i)); % here I am simply "spreading" the event
        end
        
    end
         
    %end
    
    
end 
