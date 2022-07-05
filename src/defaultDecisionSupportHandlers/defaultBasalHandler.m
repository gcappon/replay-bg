function [B, dss] = defaultBasalHandler(G, mealAnnouncements,bolus,basal,time,timeIndex,dss)
% function  defaultBasalHandler(G,mealAnnouncements,bolus,basal,time,timeIndex,dss)
% Implements the default basal rate controller: if G < 70, basal = 0,
% otherwise basal = basal(1). 
%
% Inputs:
%   - G: a glucose vector as long the simulation length containing all the 
%   simulated glucose concentrations up to timeIndex. The other values are
%   nan;
%   - mealAnnouncements: is a vector that contains the meal announcements intakes input for the whole
%   replay simulation (g);
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
%   - B: the computed basal to administer at time(timeIndex+1) (U/min);
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system.
%
% ---------------------------------------------------------------------
% NOTES:   
% - dss is also an output since it contains basalHandlerParams 
%   that beside being a structure that contains the parameters to pass to 
%   this function, it also serves as memory area. It is possible to store   
%   values inside it and the defaultBasalHandler function will be able 
%   to access to them in the next call of the function).
% - basal(1) = u2ss (the average basal rate used during identification in mU/(kg*min)
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2022 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    B = basal(1);
    
    %If G < 70...
    if(G(timeIndex) < 70)
        
        %...set basal rate to 0.
        B = 0;
        
    end
    
end

