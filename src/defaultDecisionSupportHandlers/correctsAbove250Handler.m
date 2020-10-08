function CB = correctsAbove250Handler(G,CHO,bolus,basal,time,timeIndex)
% function  correctsAbove250Handler(G,CHO,bolus,basal,time,timeIndex)
% Implements the default correction bolus strategy: "take a correction
% bolus of 1 U every 1 hour while above 250 mg/dl".
%
% Inputs:
%   - G: the glucose concentration at time(timeIndex) 
%   - CHO: is a vector that contains the CHO intakes input for the whole
%   replay simulation (g/min);
%   - bolus: is a vector that contains the bolus insulin input for the
%   whole replay simulation (U/min);
%   - basal: is a vector that contains the basal insulin input for the
%   whole replay simulation (U/min);
%   - time: is a vector that contains the time istants of current replay
%   simulation. Contains one value for each integration step;
%   - timeIndex: is a number that defines the current time istant in the
%   replay simulation.
% Outputs:
%   - CB: the correction bolus to administer at time(timeIndex+1) (U/min).
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
    if(G > 250)
        
        %...and if there are no boluses in the last 1 hour, then take a CB
        if(timeIndex > 60 && ~any(bolus((timeIndex - 60):timeIndex)))
            CB = 1; % g/min
        end
        
    end
    
end
        
