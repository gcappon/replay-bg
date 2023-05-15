function xk = modelStepSingleMealExerciseT1D(xkm1,I,CHO,VO2,mP,xk,model)
% function  modelStepSingleMealExerciseT1D(xkm1,I,CHO,mP,xk,model)
% Simulates a step of the single-meal t1d physiological model.
%
% Inputs:
%   - xkm1: is a vector containing the model state at time k-1;
%   - I: is the insulin at time k;
%   - CHO: is the CHO at time k;
%   - VO2: is the VO2 at time k;
%   - mP: is a struct containing the model parameters;
%   - xk: is the preallocated vector that will contain the model state at 
%   time k;
%   - model: a structure that contains general parameters of the
%   physiological model.
% Outputs:
%   - xk: is a vector containing the model state at time k.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2023 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    G = xkm1(1); %Plasma glucose concentration (mg/dL)
    %Gss = Gb (assuming Xss = 0 and Rass = 0)
    X = xkm1(2); %(Over-basal) insulin action (1/min)
    %Xss = 0 (over-basal --> 0)
    Isc1 = xkm1(3); %Subcutaneous insulin concentration in a non-monomeric state (mU/kg)
    %Isc1ss = u2ss / ( ka1 + kd )
    Isc2 = xkm1(4); %Subcutaneous insulin concentration in a monomeric state (mU/kg)
    %Isc2ss = kd / ka2 * u2ss / ( ka1 + kd )
    Ip = xkm1(5); %Plasma insulin concentration (mU/kg)
    %Ipss = ka1 / ke * u2ss / ( ka1 + kd ) + ka2 / ke * kd / ka2 * u2ss / ( ka1 + kd ) 
    Qsto1 = xkm1(6); %Glucose concentration in the stomach in a solid state (mg/kg)
    %Qsto1ss = 0
    Qsto2 = xkm1(7); %Glucose concentration in the stomach in a liquid state (mg/kg)
    %Qsto2ss = 0
    Qgut = xkm1(8); %Glucose concentration in the intestin (mg/kg)
    %Qgutss = 0
    te = xkm1(9);
    %tess = -
    IG = xkm1(10); %Interstitial glucose concentration (mg/dL)  
    %IGss = Gb
    
    %Compute the basal plasmatic insulin
    Ipb = (mP.ka1/mP.ke)*(mP.u2ss)/(mP.ka1+mP.kd) + (mP.ka2/mP.ke)*(mP.kd/mP.ka2)*(mP.u2ss)/(mP.ka1+mP.kd); %from eq. 5 steady-state    

    %Compute the hypoglycemic risk
    risk = computeHypoglycemicRisk(G,mP);
    
    %Compute the time from exercise start
    if(VO2 == 0)
        xk(9) = 0;
    else
        xk(9) = (te + model.TS)/60;
    end
    
    %Compute exercise model terms 
    PVO2 = (VO2 - mP.VO2rest)/(mP.VO2max - mP.VO2rest);
    inc1 = mP.e1*PVO2;
    inc2 = mP.e2*(PVO2 + xk(9));
    
    %Compute the model state at time k using backward Euler method
    xk(6) = (Qsto1 + model.TS*CHO)/(1+model.TS*mP.kgri);
    xk(7) = (Qsto2 + model.TS*mP.kgri*xk(6))/(1+model.TS*mP.kempt);
    xk(8) = (Qgut + model.TS*mP.kempt*xk(7))/(1+model.TS*mP.kabs);
    
    Ra = mP.f*mP.kabs*xk(8);
    
    xk(3) = (Isc1 + model.TS*I)/(1+model.TS*(mP.ka1+mP.kd));
    xk(4) = (Isc2 + model.TS*mP.kd*xk(3))/(1+model.TS*mP.ka2);
    xk(5) = (Ip + model.TS*(mP.ka1*xk(3)+mP.ka2*xk(4)))/(1+model.TS*mP.ke);
    
    xk(2) = (X + model.TS*mP.p2*(1+inc2)*(mP.SI/mP.VI)*(xk(5)-Ipb))/(1+model.TS*mP.p2);
    
    xk(1) = (G + model.TS*(mP.SG*(1+inc1)*mP.Gb+Ra/mP.VG))/(1+model.TS*(mP.SG + (1+mP.r1*risk)*xk(2)));
    xk(10) = (IG + (model.TS/mP.alpha)*xk(1))/(1+model.TS/mP.alpha);
    
end %function model