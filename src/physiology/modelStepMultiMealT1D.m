function xk = modelStepMultiMealT1D(xkm1,B,CHOB,CHOL,CHOD,CHOS,CHOH,hourOfTheDay,mP,xk,model)
% function  modelStepMultiMealT1D(xkm1,B,CHO,mP,xk,model)
% Simulates a step of the multi-meal t1d physiological model.
%
% Inputs:
%   - xkm1: is a vector containing the model state at time k-1;
%   - B: is the insulin at time k;
%   - CHOB: is the CHO breakfast at time k;
%   - CHOL: is the CHO lunch at time k;
%   - CHOD: is the CHO dinner at time k;
%   - CHOS: is the CHO snack at time k;
%   - CHOH: is the CHO hypotreatment at time k;
%   - hourOfTheDay: the hour of the day of the current time step;
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
    Qsto1B = xkm1(6); %mg/kg
    %Qsto1ss = 0
    Qsto2B = xkm1(7); %mg/kg
    %Qsto2ss = 0
    QgutB = xkm1(8); %mg/kg
    %Qgutss = 0
    Qsto1L = xkm1(9); %mg/kg
    %Qsto1ss = 0
    Qsto2L = xkm1(10); %mg/kg
    %Qsto2ss = 0
    QgutL = xkm1(11); %mg/kg
    %Qgutss = 0
    Qsto1D = xkm1(12); %mg/kg
    %Qsto1ss = 0
    Qsto2D = xkm1(13); %mg/kg
    %Qsto2ss = 0
    QgutD = xkm1(14); %mg/kg
    %Qgutss = 0
    Qsto1S = xkm1(15); %mg/kg
    %Qsto1ss = 0
    Qsto2S = xkm1(16); %mg/kg
    %Qsto2ss = 0
    QgutS = xkm1(17); %mg/kg
    %Qgutss = 0
    Qsto1H = xkm1(18); %mg/kg
    %Qsto1ss = 0
    Qsto2H = xkm1(19); %mg/kg
    %Qsto2ss = 0
    QgutH = xkm1(20); %mg/kg
    %Qgutss = 0
    IG = xkm1(21); %mg/dL  
    %IGss = Gb
    
    if(hourOfTheDay<4 || hourOfTheDay >= 17)
        SI = mP.SID;
    else
        if(hourOfTheDay>=4 && hourOfTheDay < 11)
            SI = mP.SIB;
        else
            SI = mP.SIL;
        end
    end
    
    %Compute the basal plasmatic insulin
    Ipb = (mP.ka1/mP.ke)*(mP.u2ss)/(mP.ka1+mP.kd) + (mP.ka2/mP.ke)*(mP.kd/mP.ka2)*(mP.u2ss)/(mP.ka1+mP.kd); %from eq. 5 steady-state    

    %Compute the hypoglycemic risk
    risk = computeHypoglycemicRisk(G,mP);
        
    %Compute the model state at time k using backward Euler method
    xk(6) = (Qsto1B + model.TS*CHOB)/(1+model.TS*mP.kgri);
    xk(7) = (Qsto2B + model.TS*mP.kgri*xk(6))/(1+model.TS*mP.kempt);
    xk(8) = (QgutB + model.TS*mP.kempt*xk(7))/(1+model.TS*mP.kabsB);
    
    xk(9) = (Qsto1L + model.TS*CHOL)/(1+model.TS*mP.kgri);
    xk(10) = (Qsto2L + model.TS*mP.kgri*xk(9))/(1+model.TS*mP.kempt);
    xk(11) = (QgutL + model.TS*mP.kempt*xk(10))/(1+model.TS*mP.kabsL);
    
    xk(12) = (Qsto1D + model.TS*CHOD)/(1+model.TS*mP.kgri);
    xk(13) = (Qsto2D + model.TS*mP.kgri*xk(12))/(1+model.TS*mP.kempt);
    xk(14) = (QgutD + model.TS*mP.kempt*xk(13))/(1+model.TS*mP.kabsD);
    
    xk(15) = (Qsto1S + model.TS*CHOS)/(1+model.TS*mP.kgri);
    xk(16) = (Qsto2S + model.TS*mP.kgri*xk(15))/(1+model.TS*mP.kempt);
    xk(17) = (QgutS + model.TS*mP.kempt*xk(16))/(1+model.TS*mP.kabsS);
    
    xk(18) = (Qsto1H + model.TS*CHOH)/(1+model.TS*mP.kgri);
    xk(19) = (Qsto2H + model.TS*mP.kgri*xk(18))/(1+model.TS*mP.kempt);
    xk(20) = (QgutH + model.TS*mP.kempt*xk(19))/(1+model.TS*mP.kabsH);
    
    RaB = mP.f*mP.kabsB*xk(8);
    RaL = mP.f*mP.kabsL*xk(11);
    RaD = mP.f*mP.kabsD*xk(14);
    RaS = mP.f*mP.kabsS*xk(17);
    RaH = mP.f*mP.kabsH*xk(20);
    
    xk(3) = (Isc1 + model.TS*B)/(1+model.TS*(mP.ka1+mP.kd));
    xk(4) = (Isc2 + model.TS*mP.kd*xk(3))/(1+model.TS*mP.ka2);
    xk(5) = (Ip + model.TS*(mP.ka1*xk(3)+mP.ka2*xk(4)))/(1+model.TS*mP.ke);
    
    xk(2) = (X + model.TS*mP.p2*(SI/mP.VI)*(xk(5)-Ipb))/(1+model.TS*mP.p2);
    
    xk(1) = (G + model.TS*(mP.SG*mP.Gb+(RaB + RaL + RaD + RaS + RaH)/mP.VG))/(1+model.TS*(mP.SG + (1+mP.r1*risk)*xk(2)));
    xk(21) = (IG + (model.TS/mP.alpha)*xk(1))/(1+model.TS/mP.alpha);
    
end %function model