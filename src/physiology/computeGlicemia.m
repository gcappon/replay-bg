function [G, insulinBolus, correctionBolus, insulinBasal, CHO, hypotreatments, x] = computeGlicemia(mP,data,model,dss,environment)
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
%   decision support system;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
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
    x = setModelInitialConditions(data,mP,model,environment);
    
    %Initialize the glucose vector
    G = nan(model.TIDSTEPS,1);
    
    %Set the initial glucose value
    switch(model.glucoseModel)
        case 'IG' 
            G(1) = x(model.nx,1); %y(k) = IG(k)
        case 'BG'
            G(1) = x(1,1); %y(k) = BG(k)
    end
    
    %initialize inputs (basal, bolus, meal) with the initial condition (meal
    %intake + its bolus)
    [bolus, basal, bolusDelayed, basalDelayed] = insulinSetup(data,model,mP,environment);
    [meal,mealDelayed] = mealSetup(data,model,mP,environment);
    
    %Time vector for DSS
    switch(environment.scenario)
        case 'single-meal'
            time = data.Time(1):minutes(1):(data.Time(1) + minutes(length(meal) - 1));
        case 'multi-meal'
            time = data.Time(1):minutes(1):(data.Time(1) + minutes(length(meal.breakfast) - 1));
    end
    
    
    %Hour of the day vector for multi-meal simulations
    hourOfTheDay = hour(time);
    
    %Initialize the 'event' vectors
    insulinBasal = basal/1000*mP.BW;
    insulinBolus = bolus/1000*mP.BW;
    correctionBolus = insulinBolus*0;
    
    switch(environment.scenario)
        case 'single-meal'
            CHO = meal/1000*mP.BW;
            hypotreatments = CHO*0;
        case 'multi-meal'
            CHO = (meal.breakfast + meal.lunch + meal.dinner + meal.snack) /1000*mP.BW;
            hypotreatments = meal.hypotreatment/1000*mP.BW;
    end

    %glucose = CHO*nan;
    
    %Simulate the physiological model
    for k = 2:model.TIDSTEPS
        
        %Add hypotreatments if needed
        if(dss.enableHypoTreatments)
            [HT, dss] = feval(dss.hypoTreatmentsHandler,G,CHO,hypotreatments,insulinBolus,insulinBasal,time,k-1,dss);
            
            switch(environment.scenario)
                case 'single-meal'
                    mealDelayed(k) = mealDelayed(k) + HT*1000/mP.BW;                    
                case 'multi-meal'
                    mealDelayed.hypotreatment(k) = mealDelayed.hypotreatment(k) + HT*1000/mP.BW;
            end
            
            %Update the CHO event vectors
            
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
        switch(model.pathology)
            case 't1d'
            
                switch(environment.scenario)
                    case 'single-meal'
                        x(:,k) = modelStepSingleMealT1D(x(:,k-1),basalDelayed(k) + bolusDelayed(k), mealDelayed(k), mP, x(:,k), model); %input at k since using Backwards Euler's algorithm
                    case 'multi-meal'
                        x(:,k) = modelStepMultiMealT1D(x(:,k-1),basalDelayed(k) + bolusDelayed(k), mealDelayed.breakfast(k), mealDelayed.lunch(k), mealDelayed.dinner(k), mealDelayed.snack(k), mealDelayed.hypotreatment(k), hourOfTheDay(k), mP, x(:,k), model); %input at k since using Backwards Euler's algorithm
                end

            case 't2d'
                %TODO: implement t2d model
            case 'pbh'
                %TODO: implement pbh model
            case 'healthy'
                %TODO: implement healthy model
        end     
        %Get the glucose
        switch(model.glucoseModel)
            case 'IG' 
                G(k) = x(model.nx,k); %y(k) = IG(k)
            case 'BG'
                G(k) = x(1,k); %y(k) = BG(k)
        end   
        
    end
    
end