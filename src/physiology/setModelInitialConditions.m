function x0 = setModelInitialConditions(data,modelParameters,model,environment)
% function  setModelInitialConditions(data,modelParameters,model,environment)
% Compute the glycemic profile obtained with the ReplayBG physiological
% model using the given inputs and model parameters.
%
% Inputs:
%   - data: a timetable which contains the data to be used by the tool;
%   - modelParameters: a struct containing the model parameters;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Outputs:
%   - x0: is a vector containing the model initial conditions. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2021 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    %Change name for the sake of brevity
    mP = modelParameters;
    
    %Initial model conditions
    x0 = zeros(model.nx,model.TSTEPS);
                        
    switch(model.pathology)
            case 't1d'

                switch(environment.scenario)
                    case 'single-meal'
                        
                        %Find the first non-nan glucose value to be set as
                        %initial condition for plansma and interstitial
                        %glucose
                        idxFirstNonNan = find(~isnan(data.glucose),1,'first');
                        
                        %Set initial conditions 
                        x0(1:model.nx,1) = [data.glucose(idxFirstNonNan); ...                                 %G(0)
                              mP.X0; ...                                                                                          %X(0)
                              mP.u2ss/(mP.ka1+mP.kd); ...                                                                          %Isc1(0)                              
                              (mP.kd/mP.ka2)*mP.u2ss/(mP.ka1+mP.kd); ...                                                           %Isc2(0)
                              (mP.ka1/mP.ke)*mP.u2ss/(mP.ka1+mP.kd) + (mP.ka2/mP.ke)*(mP.kd/mP.ka2)*mP.u2ss/(mP.ka1+mP.kd) + mP.Ip0; ...    %Ip(0) 
                              0; ...                                                                                               %Qsto1(0)
                              0; ...                                                                                               %Qsto2(0)
                              mP.Qgut0; ...                                                                                        %Qgut(0)
                              data.glucose(idxFirstNonNan)];                                                 %IG(0)  

                    case 'multi-meal'
                        
                        %Find the first non-nan glucose value to be set as
                        %initial condition for plansma and interstitial
                        %glucose
                        idxFirstNonNan = find(~isnan(data.glucose),1,'first');
                        
                        %Set initial conditions
                        x0(1:model.nx,1) = [data.glucose(idxFirstNonNan); ...                                 %G(0)
                              mP.Xpb; ...                                                                                          %X(0)
                              mP.u2ss/(mP.ka1+mP.kd); ...                                                                          %Isc1(0)                              
                              (mP.kd/mP.ka2)*mP.u2ss/(mP.ka1+mP.kd); ...                                                           %Isc2(0)
                              (mP.ka1/mP.ke)*mP.u2ss/(mP.ka1+mP.kd) + (mP.ka2/mP.ke)*(mP.kd/mP.ka2)*mP.u2ss/(mP.ka1+mP.kd); ...    %Ip(0) 
                              0; ...                                                                                               %Qsto1B(0)
                              0; ...                                                                                               %Qsto2B(0)
                              mP.QgutbB; ...                                                                                        %QgutB(0)
                              0; ...                                                                                               %Qsto1L(0)
                              0; ...                                                                                               %Qsto2L(0)
                              mP.QgutbL; ...                                                                                        %QgutL(0)
                              0; ...                                                                                               %Qsto1D(0)
                              0; ...                                                                                               %Qsto2D(0)
                              mP.QgutbD; ...                                                                                        %QgutD(0)
                              0; ...                                                                                               %Qsto1S(0)
                              0; ...                                                                                               %Qsto2S(0)
                              mP.QgutbS; ...                                                                                        %QgutS(0)
                              0; ...                                                                                               %Qsto1H(0)
                              0; ...                                                                                               %Qsto2H(0)
                              mP.QgutbH; ...                                                                                        %QgutH(0)
                              data.glucose(idxFirstNonNan)];                                                 %IG(0) 
                          
                end
            
        case 't2d'
            %TODO: implement t2d model
        case 'pbh'
            %TODO: implement pbh model
        case 'healthy'
            %TODO: implement healthy model
    end                                                                                  
    
end