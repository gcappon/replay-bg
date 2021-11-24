function CGM = cgmMeasure(IG, t, sensors )
% function  computeGlicemia(mP,data,model,dss,environment)
% Compute the glycemic profile obtained with the ReplayBG physiological
% model using the given inputs and model parameters.
%
% Inputs:
%   - IG: interstitial glucose concentration at current time (mg/dl);
%   - t: current time. Minutes from the start of CGM sensor;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - sensors: a structure that contains general parameters of the
%   sensors models;
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Outputs:
%   - G: is a vector containing the simulated glucose trace [mg/dl]; 
%   - CGM: is a vector containing the simulated cgm trace [mg/dl]; 
%   - insulinBolus: is a vector containing the input bolus insulin used to
%   obtain G (U/min);
%   - correctionBolus: a vector containing the correction bolus insulin used to
%   obtain G (U/min);
%   - insulinBasal: a vector containing the input basal insulin used to
%   obtain G (U/min);
%   - CHO: a vector containing the input CHO used to obtain glucose
%   (g/min);
%   - hypotreatments: a vector containing the input hypotreatments used 
%   to obtain G (g/min);
%   - x: is a matrix containing the simulated model states. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2021 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
                    
    % Apply calibration error
    IGs = (sensors.cgm.errorParameters(1) + sensors.cgm.errorParameters(2)*t + sensors.cgm.errorParameters(3)*t^2)*IG + sensors.cgm.errorParameters(4);

    % Generate noise
    z = randn(1);
    u = sensors.cgm.errorParameters(7)*z;
    e = filter(1,[1, -sensors.cgm.errorParameters(5), -sensors.cgm.errorParameters(6)],u);

    % Get final CGM
    CGM = IGs + e;
    
end