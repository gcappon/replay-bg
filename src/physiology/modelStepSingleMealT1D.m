function xk = modelStepSingleMealT1D(xkm1,B,CHO,mP,xk,model)
% function  modelStepSingleMealT1D(xkm1,B,CHO,mP,xk,model)
% Simulates a step of the single-meal t1d physiological model.
%
% Inputs:
%   - xkm1: is a vector containing the model state at time k-1;
%   - B: is the insulin at time k;
%   - CHO: is the CHO at time k;
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
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    G = xkm1(1); %mg/dL
    %Gss = Gb (assuming Xss = 0 and Rass = 0)
    X = xkm1(2); %1/min
    %Xss = 0 (over-basal insulin action)
    Isc1 = xkm1(3); %mU/kg
    %Isc1ss = u2ss / ( ka1 + kd )
    Isc2 = xkm1(4); %mU/kg
    %Isc2ss = kd / ka2 * u2ss / ( ka1 + kd )
    Ip = xkm1(5); %mU/kg
    %Ipss = ka1 / ke * u2ss / ( ka1 + kd ) + ka2 / ke * kd / ka2 * u2ss / ( ka1 + kd ) 
    Qsto1 = xkm1(6); %mg/kg
    %Qsto1ss = 0
    Qsto2 = xkm1(7); %mg/kg
    %Qsto2ss = 0
    Qgut = xkm1(8); %mg/kg
    %Qgutss = 0
    IG = xkm1(9); %mg/dL  
    %IGss = Gb
    
    %Compute the basal plasmatic insulin
    Ipb = (mP.ka1/mP.ke)*(mP.u2ss)/(mP.ka1+mP.kd) + (mP.ka2/mP.ke)*(mP.kd/mP.ka2)*(mP.u2ss)/(mP.ka1+mP.kd); %from eq. 5 steady-state    

    %Compute the hypoglycemic risk
    risk = computeHypoglycemicRisk(G,mP);
        
    %Compute the model state at time k using backward Euler method
    xk(6) = (Qsto1 + model.TS*CHO)/(1+model.TS*mP.kgri);
    xk(7) = (Qsto2 + model.TS*mP.kgri*xk(6))/(1+model.TS*mP.kempt);
    xk(8) = (Qgut + model.TS*mP.kempt*xk(7))/(1+model.TS*mP.kabs);
    
    Ra = mP.f*mP.kabs*xk(8);
    
    xk(3) = (Isc1 + model.TS*B)/(1+model.TS*(mP.ka1+mP.kd));
    xk(4) = (Isc2 + model.TS*mP.kd*xk(3))/(1+model.TS*mP.ka2);
    xk(5) = (Ip + model.TS*(mP.ka1*xk(3)+mP.ka2*xk(4)))/(1+model.TS*mP.ke);
    
    xk(2) = (X + model.TS*mP.p2*(mP.SI/mP.VI)*(xk(5)-Ipb))/(1+model.TS*mP.p2);
    
    xk(1) = (G + model.TS*(mP.SG*mP.Gb+Ra/mP.VG))/(1+model.TS*(mP.SG + (1+mP.r1*risk)*xk(2)));
    xk(9) = (IG + (model.TS/mP.alpha)*xk(1))/(1+model.TS/mP.alpha);
    
end %function model