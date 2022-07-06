function [C, MA, type, dss] = defaultMealGeneratorHandler(G, meal, mealAnnouncements,bolus,basal,time,timeIndex,dss)
% function  defaultMealGeneatorHandler(G,meal,mealAnnouncements,bolus,basal,time,timeIndex,dss)
% Implements the default meal generation policy: put a snack meal of 50g of CHO
% in the first instant and announce only 40g.
%
% Inputs:
%   - G: a glucose vector as long the simulation length containing all the 
%   simulated glucose concentrations up to timeIndex. The other values are
%   nan;
%   - meal: is a vector that contains the meal intakes input for the whole
%   replay simulation (g/min);
%   - mealAnnouncements: is a vector that contains the meal announcements intakes input for the whole
%   replay simulation (g/min);
%   - bolus: is a vector that contains the bolus insulin input for the
%   whole replay simulation (U/min);
%   - basal: is a vector that contains the basal insulin input for the
%   whole replay simulation (U/min);
%   - time: is a vector that contains the time instants of current replay
%   simulation. Contains one value for each integration step;
%   - timeIndex: is a number that defines the current time instant in the
%   replay simulation;
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system.
% Output:
%   - C: the generated meal intake to administer at time(timeIndex+1) (g/min);
%   - MA: the generated meal announcement intake to administer at time(timeIndex+1) (g/min);
%   - type: the type of the meal. Can be 'B' for breakfast, 'L' for lunch,
%   'D' for dinner, 'S' for snack, '' for no meal;
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system.
%
% ---------------------------------------------------------------------
%
% NOTES:   
% - dss is also an output since it contains mealGeneratorHandlerParams 
%   that beside being a structure that contains the parameters to pass to 
%   this function, it also serves as memory area. It is possible to store   
%   values inside it and the defaultMealGeneratorHandler function will be able 
%   to access to them in the next call of the function).
% - if the scenario is single-meal, type is ignored.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2022 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    %Default output values
    C = 0;
    MA = 0;
    type = '';
    
    %If this is the first time instant...
    if(timeIndex == 1)
        
        %...generate a snack meal of 50g and announce just 40g.
        C = 50;
        MA = 40;
        type = 'S';
        
    end
    
end

