function [bolus, basal] = insulinSetup(data,model,params)
% insulinSetup Function that generates the vector containing the insulin events.
% [bolus, basal] = insulinSetup(patient, simulation, params) returns  two vectors
% containing the insulin bolus dose and the basal insulin respectively
% at each time step.
% * Inputs:
%   - patient: is a table containing data coming from a simulation
%   (i.e. carbohydrate intakes, insulin boluses, basal insulin, glucose
%   measurements)
%   - simulation: is a structure containing the simulation
%   parameters.
%   - params: is a structure contining the appropriate model parameters.
% * Output:
%   - bolus: is a vector containing the insulin bolus dose at each time
%   step [mU/min]
%   - basal: is a vector containing the basal insulin value at each time
%   step [mU/min]

    %Set vector length
    TSTEPS = model.TIDSTEPS;
    T = model.TID;
    
    basal = zeros(TSTEPS,1);
    bolus = zeros(TSTEPS,1);
    
    for time = 1:length(0:5:(T-1))
        bolus((1+(time-1)*(model.YTS/model.TS)):(time*(model.YTS/model.TS))) = data.Bolus(time)*1000/params.BW; %mU/(kg*min)
        basal((1+(time-1)*(model.YTS/model.TS)):(time*(model.YTS/model.TS))) = data.Basal(time)*1000/params.BW; %mU/(kg*min)
    end
    
    
end %function insulinSetup
