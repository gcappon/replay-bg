function [B, dss] = standardBolusCalculatorHandler(G, mealAnnouncements,bolus,basal,time,timeIndex,dss)
% function  standardBolusCalculatorHandler(G,CHO,bolus,basal,time,timeIndex,dss)
% Implements the default insulin bolus calculator formula: B = CHO/CR + (GC -GT)/CF - IOB.
%
% Inputs:
%   - G: a glucose vector as long the simulation length containing all the 
%   simulated glucose concentrations up to timeIndex. The other values are
%   nan;
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
%   - B: the computed insulin bolus to administer at time(timeIndex+1) (U/min);
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system.
%
% ---------------------------------------------------------------------
% NOTES:   
% - dss is also an output since it contains bolusCalculatorHandlerParams 
%   that beside being a structure that contains the parameters to pass to 
%   this function, it also serves as memory area. It is possible to store   
%   values inside it and the standardBolusCalculatorHandler function will be able 
%   to access to them in the next call of the function).
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2022 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    B = 0;
    
    %If a meal is announced...
    if(mealAnnouncements(timeIndex) > 0)
        
        %...give a bolus
        B = mealAnnouncements(timeIndex)/dss.CR + (G(timeIndex) - dss.GT) / dss.CF - iobCalculation(bolus(1:timeIndex),5);
        
    end
    
end

function [IOB] = iobCalculation(insulin,Ts)

    % define 6 hour curve
    k1 = 0.0173;
    k2 = 0.0116;
    k3 = 6.75;
    IOB_6h_curve = zeros(360,1);
    for t = 1:360
        IOB_6h_curve(t)= 1 - ...
            0.75*((-k3/(k2*(k1-k2))*(exp(-k2*(t)/0.75)-1) + ...
            k3/(k1*(k1-k2))*(exp(-k1*(t)/0.75)-1))/(2.4947e4));
    end
    IOB_6h_curve = IOB_6h_curve(Ts:Ts:end);

    % IOB is the convolution of insulin data with IOB curve
    IOB = conv(insulin, IOB_6h_curve);
    IOB = IOB(length(insulin));

end
        
