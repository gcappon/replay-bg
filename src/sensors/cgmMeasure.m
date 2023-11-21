function CGM = cgmMeasure(IG, t, sensors)
% function  cgmMeasure(IG, t, sensors)
% Function that provide a CGM measure using the model of Vettoretti et al.,
% Sensors, 2019.
%
% Inputs:
%   - IG: interstitial glucose concentration at current time (mg/dl);
%   - t: current time in days from the start of CGM sensor;
%   - sensors: a structure that contains general parameters of the
%   sensors models.
% Outputs:
%   - CGM: the CGM measurement at current time (mg/dl).
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
%     e = filter(1,[1, -sensors.cgm.errorParameters(5), -sensors.cgm.errorParameters(6)],u);
    e = u + sensors.cgm.errorParameters(5) * sensors.ekm1 + sensors.cgm.errorParameters(6) * sensors.ekm2;

    sensors.ekm2 = sensors.ekm1;
    sensors.ekm1 = e;

    % Get final CGM
    CGM = IGs + e;
    
end
