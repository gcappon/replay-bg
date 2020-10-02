function [meal] = mealSetup(data,model,params)
% mealSetup Function that generates the vector containing the CHO intake events.
% meal = mealSetup(patient, simulation, params) returns a vector containing the 
% carbohydrate intake at each time step.
% * Inputs:
%   - patient: is a table containing data coming from a simulation
%   (i.e. carbohydrate intakes, insulin boluses, basal insulin, glucose
%   measurements)
%   - simulation: is a structure containing the simulation
%   parameters.
%   - params: is a structure contining the appropriate model parameters.
% * Output:
%   - meal: is a vector containing the carbohydrate intake at each time
%   step [mg/min]
    
    %Set the vector length
    TSTEPS = model.TIDSTEPS;
    T = model.TID;
   
    meal = zeros(TSTEPS,1);
    
    for time = 1:length(0:5:(T-1))
        meal((1+(time-1)*(5/model.TS)):(time*(5/model.TS))) = data.CHO(time)*1000/params.BW; %mg/(kg*min)
    end
    
end %function mealSetup