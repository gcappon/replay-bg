function check = checkIdentifiedParameters(mP)
% function  checkIdentifiedParameters()
% Checks the identified parameters physiological plausibility.
% 
% Input:
%   - mP: a struct containing the model parameters;
% Output:
%   - prior: a structure containing the check flags for the given model 
%   parameters.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2021 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    %Glucose-insulin submodel parameters
    check.SI = gamcdf(mP.SI*mP.VG,3.3,5e-4); % From: Dalla Man et
    %al.,Minimal model estimation of glucose absorption and insulin
    %sensitivity from oral test: validation with a tracer method.
    check.SI = check.SI >= 0.05 && check.SI <= 0.95;
    
    check.SG = logncdf(mP.SG,-3.8,0.5);
    check.SG = check.SG >= 0.05 && check.SG <= 0.95;
    
    check.p2 = normcdf(sqrt(mP.p2),0.11,0.004)*(mP.p2>0);
    check.p2 = check.p2 >= 0.05 && check.p2 <= 0.95;
    
    check.Gb = normcdf(mP.Gb,119.13,25)*(mP.Gb<=180)*(mP.Gb>=70);
    check.Gb = check.Gb >= 0.05 && check.Gb <= 0.95;
    check.r1 = (mP.r1>=0)*normcdf(mP.r1,1.4407,0.0562);
    check.r1 = check.r1 >= 0.05 && check.r1 <= 0.95;
    check.r2 = (mP.r2>=0)*normcdf(mP.r2,0.8124,0.0171);
    check.r2 = check.r2 >= 0.05 && check.r2 <= 0.95;
    check.alpha = 1;
    
    %Subcutaneous insulin absorption submodel
    check.VI = logncdf(mP.VI,-2.0568,0.1128);
    check.VI = check.VI >= 0.05 && check.VI <= 0.95;
    check.ke = logncdf(mP.ke,-2.0811,0.2977);
    check.ke = check.ke >= 0.05 && check.ke <= 0.95;
    check.kd = logncdf(mP.kd,-3.5090,0.6187);
    check.kd = check.kd >= 0.05 && check.kd <= 0.95;
    check.ka1 = logncdf(mP.ka1,-5.7775,0.6545);
    check.ka1 = check.ka1 >= 0.05 && check.ka1 <= 0.95;
    check.ka1 = 1; %Forced to ok since simplified
    check.ka2 = logncdf(mP.ka2,-4.2875,0.4274);
    check.ka2 = check.ka2 >= 0.05 && check.ka2 <= 0.95;
    check.tau = logncdf(mP.tau,1.7869,1.1586)*(mP.tau <= 45);
    check.tau = mP.tau < 1 || (check.tau >= 0.05 && check.tau <= 0.95);
    
    %Oral glucose absorption sumodel
    check.kabs = logncdf(mP.kabs,-5.4591,1.4396)*(mP.kempt>=mP.kabs);
    check.kabs = check.kabs >= 0.05 && check.kabs <= 0.95;
    check.kempt = logncdf(mP.kempt,-1.9646,0.7069)*(mP.kempt>=mP.kabs);
    check.kempt = check.kempt >= 0.05 && check.kempt <= 0.95;
    check.beta = 1*(mP.beta>=0 && mP.beta<=60);
    check.beta = 1;
    
 end