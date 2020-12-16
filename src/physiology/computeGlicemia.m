function [G, insulinBolus, correctionBolus, insulinBasal, CHO, hypotreatments, x] = computeGlicemia(mP,data,model,dss)
% function  computeGlicemia(mP,data,model)
% Compute the glycemic profile obtained with the ReplayBG physiological
% model using the given inputs and model parameters.
%
% Inputs:
%   - mP: a struct containing the model parameters.
%   - data: a timetable which contains the data to be used by the tool;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system.
% Outputs:
%   - G: is a vector containing the simulated glucose trace [mg/dl]; 
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
    G = nan(model.TIDSTEPS,1);
    
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
    
    %Add delay of main meal absorption
    mealDelay = round(mP.beta/model.TS);
    mealDelayed = [zeros(mealDelay,1); meal];
    mealDelayed = mealDelayed(1:model.TIDSTEPS);
    
    %Add delay in insulin absorption
    bolusDelay = floor(mP.tau/model.TS); 
    bolusDelayed = [zeros(bolusDelay,1); bolus];
    bolusDelayed = bolusDelayed(1:model.TIDSTEPS);
    basalDelayed = basal;
    
    %Time vector for DSS
    time = data.Time(1):minutes(1):(data.Time(1) + minutes(length(meal) - 1));
    
    %Initialize the 'event' vectors
    insulinBasal = basal/1000*mP.BW;
    insulinBolus = bolus/1000*mP.BW;
    correctionBolus = insulinBolus*0;
    CHO = meal/1000*mP.BW;
    hypotreatments = CHO*0;
    glucose = CHO*nan;
    
    %Simulate the physiological model
    for k = 2:model.TIDSTEPS
        
        %Add hypotreatments if needed
        if(dss.enableHypoTreatments)
            HT = feval(dss.hypoTreatmentsHandler,G,CHO,insulinBolus,insulinBasal,time,k-1,dss);
            mealDelayed(k) = mealDelayed(k) + HT*1000/mP.BW;
            
            %Update the CHO event vectors
            CHO(k) = CHO(k) + HT;
            hypotreatments(k) = hypotreatments(k) + HT;
        end
        
        %Add correction boluses if needed (remember to add insulin
        %absorption delay to the boluses)
        if(dss.enableCorrectionBoluses)
            CB = feval(dss.correctionBolusesHandler,G,CHO,insulinBolus,insulinBasal,time,k-1,dss);
            if(k+mP.tau <= model.TIDSTEPS)
                bolusDelayed(k+mP.tau) = bolusDelayed(k+mP.tau) + CB*1000/mP.BW;
            end
            
            %Update the insulin bolus event vectors
            insulinBolus(k) = insulinBolus(k) + CB;
            correctionBolus(k) = correctionBolus(k) + CB;
        end

        %Integration step
        x(:,k) = modelStep(x(:,k-1),basalDelayed(k) + bolusDelayed(k), mealDelayed(k), mP, x(:,k), model); %input at k since using Backwards Euler's algorithm
        
        %Get the glucose
        switch(model.glucoseModel)
            case 'IG' 
                G(k) = x(9,k); %y(k) = IG(k)
            case 'BG'
                G(k) = x(1,k); %y(k) = BG(k)
        end   
        
    end
    
end