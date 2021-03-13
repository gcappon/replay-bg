function prior = definePriorPDF()
% function  definePriorPDF()
% Defines the a priori probability density functions of model parameters.
%
% Output:
%   - prior: a structure containing the anonymous functions defining the
%   a priori probability density functions of model parameters.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    %Glucose-insulin submodel parameters
    prior.SI = @(mP) gampdf(mP.SI*mP.VG,3.3,5e-4); % From: Dalla Man et
    %al.,Minimal model estimation of glucose absorption and insulin
    %sensitivity from oral test: validation with a tracer method.
    prior.SG = @(mP) lognpdf(mP.SG,-3.8,0.5);
    prior.p2 = @(mP) normpdf(sqrt(mP.p2),0.11,0.004)*(mP.p2>0);
    prior.Gb = @(mP) normpdf(mP.Gb,119.13,7.11)*(mP.Gb<=180)*(mP.Gb>=70);
    prior.r1 = @(mP) (mP.r1>=0)*normpdf(mP.r1,1.4407,0.0562);
    prior.r2 = @(mP) (mP.r2>=0)*normpdf(mP.r2,0.8124,0.0171);
    prior.alpha = @(mP) 1*(mP.alpha>0);
    
    %Subcutaneous insulin absorption submodel
    prior.VI = @(mP) lognpdf(mP.VI,-2.0568,0.1128);
    prior.ke = @(mP) lognpdf(mP.ke,-2.0811,0.2977);
    prior.kd = @(mP) lognpdf(mP.kd,-3.5090,0.6187);
    prior.ka1 = @(mP) lognpdf(mP.ka1,-5.7775,0.6545);
    prior.ka2 = @(mP) lognpdf(mP.ka2,-4.2875,0.4274);
    prior.tau = @(mP) lognpdf(mP.tau,1.7869,1.1586)*(mP.tau <= 45);
    
    %Oral glucose absorption sumodel
    prior.kabs = @(mP) lognpdf(mP.kabs,-5.4591,1.4396)*(mP.kempt>=mP.kabs);
    prior.kempt = @(mP) lognpdf(mP.kempt,-1.9646,0.7069)*(mP.kempt>=mP.kabs);
    prior.beta = @(mP) 1*(mP.beta>=0 && mP.beta<=60);
    
 end