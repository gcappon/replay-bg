function [G, x] = computeGlicemia(mP,data,model)
% function  computeGlicemia(mP,data,model)
% Generates the vector containing the CHO intake events to be used to
% simulate the physiological model.
%
% Inputs:
%   - mP: a struct containing the model parameters.
%   - data: a timetable which contains the data to be used by the tool;
%   - model: a structure that contains general parameters of the
%   physiological model.
% Outputs:
%   - G: is a vector containing the simulated glucose trace [mg/dl]; 
%   - x: is a matrix containing the simulated model states. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    %Initial model conditions
    x = zeros(model.nx,model.TIDSTEPS);
    x(1:9,1) = [data.glucose(1);...                                                                            %G(0)
          mP.Xpb; ...                                                                                          %X(0)
          mP.u2ss/(mP.ka1+mP.kd); ...                                                                          %Isc1(0)                              
          (mP.kd/mP.ka2)*mP.u2ss/(mP.ka1+mP.kd); ...                                                           %Isc2(0)
          (mP.ka1/mP.ke)*mP.u2ss/(mP.ka1+mP.kd) + (mP.ka2/mP.ke)*(mP.kd/mP.ka2)*mP.u2ss/(mP.ka1+mP.kd); ...    %Ip(0) 
          0; ...                                                                                               %Qsto1(0)
          0; ...                                                                                               %Qsto2(0)
          mP.Qgutb; ...                                                                                        %Qgut(0)
          data.glucose(1)];                                                                                    %IG(0)                                                                                    
    
    %Initialize the glucose vector
    G = zeros(1,model.TIDSTEPS);
    
    %Set the initial glucose value
    switch(model.glucoseModel)
        case 'IG' 
            G(1) = x(9,1); %y(k) = IG(k)
        case 'BG'
            G(1) = x(1,1); %y(k) = BG(k)
    end
    
    %initialize inputs (basal, bolus, meal) with the initial condition (meal
    %intake + its bolus)
    [bolus, basal] = insulinSetup(data,model,mP);
    [meal] = mealSetup(data,model,mP);
    bolusDelay = floor(mP.tau/model.TS); 
    mealDelay = round(mP.beta/model.TS);
    meal = [zeros(mealDelay,1); meal; zeros(bolusDelay,1)];
    bolus = [zeros(bolusDelay,1); bolus; zeros(mealDelay,1)];
    basal = [basal; ones(bolusDelay+mealDelay,1)*basal(1)];
    
    %Simulate the physiological model
    for k = 2:model.TIDSTEPS
        
        %Integration step
        x(:,k) = modelStep(x(:,k-1),basal(k) + bolus(k), meal(k), mP, x(:,k), model); %metto gli input all'istante k per dato che uso Eulero all'indietro
        
        %Get the glucose
        switch(model.glucoseModel)
            case 'IG' 
                G(k) = x(9,k); %y(k) = IG(k)
            case 'BG'
                G(k) = x(1,k); %y(k) = BG(k)
        end
        
        %TODO: HERE INSERT DSS
        
    end
    
end