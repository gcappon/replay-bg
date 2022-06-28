function modelParameters = setDefaultModelParameters(data,BW,model,environment)
% function setDefaultModelParameters(data,BW,model,environment)
% Function that sets the default model parameter values.
%
% Input:
%   - data: timetable which contains the data to be used by the tool;
%   - BW: the patient's body weight;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Output:
%   - modelParameters: a struct containing the model parameters (complying
%   to constraints).
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2021 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    switch(model.pathology)
            case 't1d'

                switch(environment.scenario)
                    case 'single-meal'
                        
                        %Initial conditions
                        modelParameters.Xpb = 0; %Insulin action initial condition
                        modelParameters.Qgutb = 0; %Intestinal content initial condition

                        %Glucose-insulin submodel parameters
                        modelParameters.VG = 1.45; %dl/kg
                        modelParameters.SG = 2.5e-2; %1/min
                        modelParameters.Gb = 119.13; %mg/dL
                        modelParameters.r1 = 1.4407; %unitless
                        modelParameters.r2 = 0.8124; %unitless
                        modelParameters.alpha = 7; %1/min
                        modelParameters.SI = 10.35e-4/modelParameters.VG; %mL/(uU*min)
                        modelParameters.p2 = 0.012; %1/min
                        modelParameters.u2ss = mean(data.basal)*1000/BW; %mU/(kg*min)

                        %Subcutaneous insulin absorption submodel parameters
                        modelParameters.VI = 0.126; %L/kg
                        modelParameters.ke = 0.127; %1/min
                        modelParameters.kd = 0.026; %1/min
                        modelParameters.ka1 = 0.0034; %1/min (virtually 0 in 77% of the cases)
                        modelParameters.ka1 = 0;
                        modelParameters.ka2 = 0.014; %1/min
                        modelParameters.tau = 8; %min

                        %Oral glucose absorption submodel parameters
                        modelParameters.kabs = 0.012; % 1/min
                        modelParameters.kgri = 0.18; %=kmax % 1/min
                        modelParameters.kempt = 0.18; %1/min 
                        modelParameters.beta = 0; %min
                        modelParameters.f = 0.9; %dimensionless

                        %Patient specific parameters
                        modelParameters.BW = BW; %kg

                        %Measurement noise specifics
                        modelParameters.typeN = 'SD';
                        modelParameters.SDn = 5;
                        
                        %Initial conditions
                        modelParameters.G0 = modelParameters.Gb;
                        

                    case 'multi-meal'
                        
                        %Initial conditions
                        modelParameters.Xpb = 0; %Insulin action initial condition
                        modelParameters.QgutbB = 0; %Intestinal content initial condition
                        modelParameters.QgutbL = 0; %Intestinal content initial condition
                        modelParameters.QgutbD = 0; %Intestinal content initial condition
                        modelParameters.QgutbS = 0; %Intestinal content initial condition
                        modelParameters.QgutbH = 0; %Intestinal content initial condition

                        %Glucose-insulin submodel parameters
                        modelParameters.VG = 1.45; %dl/kg
                        modelParameters.SG = 2.5e-2; %1/min
                        modelParameters.Gb = 119.13; %mg/dL
                        modelParameters.Gbdawn = 140; %mg/dL
                        modelParameters.r1 = 1.4407; %unitless
                        modelParameters.r2 = 0.8124; %unitless
                        modelParameters.alpha = 7; %1/min
                        modelParameters.SIB = 10.35e-4/modelParameters.VG; %mL/(uU*min)
                        modelParameters.SIL = 10.35e-4/modelParameters.VG; %mL/(uU*min)
                        modelParameters.SID = 10.35e-4/modelParameters.VG; %mL/(uU*min)
                        modelParameters.p2 = 0.012; %1/min
                        modelParameters.u2ss = mean(data.basal)*1000/BW; %mU/(kg*min)

                        %Subcutaneous insulin absorption submodel parameters
                        modelParameters.VI = 0.126; %L/kg
                        modelParameters.ke = 0.127; %1/min
                        modelParameters.kd = 0.026; %1/min
                        modelParameters.ka1 = 0.0034; %1/min (virtually 0 in 77% of the cases)
                        modelParameters.ka1 = 0;
                        modelParameters.ka2 = 0.014; %1/min
                        modelParameters.tau = 8; %min

                        %Oral glucose absorption submodel parameters
                        modelParameters.kabsB = 0.012; % 1/min
                        modelParameters.kabsL = 0.012; % 1/min
                        modelParameters.kabsD = 0.012; % 1/min
                        modelParameters.kabsS = 0.012; % 1/min
                        modelParameters.kabsH = 0.012; % 1/min
                        modelParameters.kgri = 0.18; %=kmax % 1/min
                        modelParameters.kempt = 0.18; %1/min 
                        modelParameters.betaB = 0; %min
                        modelParameters.betaL = 0; %min
                        modelParameters.betaD = 0; %min
                        modelParameters.betaS = 0; %min
                        modelParameters.betaH = 0; %min
                        modelParameters.f = 0.9; %dimensionless

                        %Patient specific parameters
                        modelParameters.BW = BW; %kg

                        %Measurement noise specifics
                        modelParameters.typeN = 'SD';
                        modelParameters.SDn = 5;
                        
                        %Initial conditions
                        modelParameters.G0 = modelParameters.Gb;

                end
            
        case 't2d'
            %TODO: implement t2d model
        case 'pbh'
            %TODO: implement pbh model
        case 'healthy'
            %TODO: implement healthy model
    end
 end