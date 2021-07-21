function HT = adaHypoTreatmentsHandler(G,CHO,bolus,basal,time,timeIndex,dss)
% function  adaHypoTreatmentsHandler(G,CHO,bolus,basal,time,timeIndex)
% Implements the default hypotreatment strategy: "take an hypotreatment of 
% 10 g every 15 minutes while in hypoglycemia".
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
% Output:
%   - HT: the hypotreatment to administer at time(timeIndex+1) (g/min).
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    HT = 0;
    
    %If glucose is lower than 70...
    if(G(timeIndex) < 70)
        
        %...and if there are no CHO intakes in the last 15 minutes, then take an HT
        if(timeIndex > 15 && ~any(CHO((timeIndex - 15):timeIndex)))
            HT = 15; % g/min
        end
        
    end
    
end
        