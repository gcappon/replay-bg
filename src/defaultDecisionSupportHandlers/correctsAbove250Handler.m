function [CB, dss] = correctsAbove250Handler(G,CHO,bolus,basal,time,timeIndex,dss)
% function  correctsAbove250Handler(G,CHO,bolus,basal,time,timeIndex,dss)
% Implements the default correction bolus strategy: "take a correction
% bolus of 1 U every 1 hour while above 250 mg/dl".
%
% Inputs:
%   - G: a glucose vector as long the simulation length containing all the 
%   simulated glucose concentrations up to timeIndex. The other values are
%   nan;
%   - CHO: is a vector that contains the CHO intakes input for the whole
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
%   - CB: the correction bolus to administer at time(timeIndex+1) (U/min);
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system.
%
% ---------------------------------------------------------------------
% NOTES:   
% - dss is also an output since it contains correctionBolusesHandlerParams 
%   that beside being a structure that contains the parameters to pass to 
%   this function, it also serves as memory area. It is possible to store   
%   values inside it and the correctsAbove250Handler function will be able 
%   to access to them in the next call of the function).
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    CB = 0;
    
    %If glucose is greater than 250...
    if(G(timeIndex) > 250)
        
        %...and if there are no boluses in the last 1 hour, then take a CB
        if(timeIndex > 60 && ~any(bolus((timeIndex - 60):timeIndex)))
            CB = 1; % U/min
        end
        
    end
    
end
        
