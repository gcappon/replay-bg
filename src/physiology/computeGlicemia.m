function [G, CGM, insulinBolus, correctionBolus, insulinBasal, CHO, hypotreatments, mealAnnouncements, x] = computeGlicemia(mP,data,model,sensors,dss,environment)
% function  computeGlicemia(mP,data,model,sensors,dss,environment)
% Compute the glycemic profile obtained with the ReplayBG physiological
% model using the given inputs and model parameters.
%
% Inputs:
%   - mP: a struct containing the model parameters.
%   - data: a timetable which contains the data to be used by the tool;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - sensors: a structure that contains general parameters of the
%   sensors models;
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Outputs:
%   - G: is a vector containing the simulated glucose trace [mg/dl]; 
%   - CGM: is a vector containing the simulated cgm trace [mg/dl]; 
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
%   - mealAnnouncements: is a vector containing the carbohydrate intake at each time
%   step that the user announces to the bolus calculator (g/min);  
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
    
    %Initialize the glucose and cgm vectors
    G = nan(model.TSTEPS,1);
    CGM = nan(model.TYSTEPS,1);
    
    %Set the initial glucose value
    switch(model.glucoseModel)
        case 'IG' 
            G(1) = x(model.nx,1); %y(k) = IG(k)
        case 'BG'
            G(1) = x(1,1); %y(k) = BG(k)
    end
    
    %Set the initial cgm value
    switch(sensors.cgm.model)
        case 'IG' 
            CGM(1) = x(model.nx,1); %y(k) = IG(k)
        case 'BG'
            CGM(1) = x(1,1); %y(k) = BG(k)
        case 'CGM'
            CGM(1) = cgmMeasure(x(model.nx,1),0,sensors);
    end
    
    %initialize inputs (basal, bolus, meal) with the initial condition (meal
    %intake + its bolus)
    [bolus, basal, bolusDelayed, basalDelayed] = insulinSetup(data,model,mP,environment);
    [meal,mealDelayed, mealAnnouncements] = mealSetup(data,model,mP,environment);
    
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
            hypotreatments = CHO*0; %Hypotreatments definition is not present in single-meal --> set to 0
        case 'multi-meal'
            CHO = (meal.breakfast + meal.lunch + meal.dinner + meal.snack) /1000*mP.BW;
            hypotreatments = meal.hypotreatment/1000*mP.BW;
    end
    
    %Simulate the physiological model
    for k = 2:model.TSTEPS
        
        if(strcmp(environment.choSource,'generated'))
            
            %Call the meal generator function handler
            [C, MA, type, dss] = feval(dss.mealGeneratorHandler, G, meal, mealAnnouncements, insulinBolus,basal,time,k-1,dss);
            
            %Add the meal to meal model input if needed (remember
            %to add meal absorption delay). Do not add delay to the
            %announcement.
            switch(environment.scenario)
                case 'single-meal'
                    if(k+mP.beta <= model.TSTEPS)
                        mealDelayed(k+mP.beta) = mealDelayed(k+mP.beta) + C*1000/mP.BW;
                    end
                   
                case 'multi-meal'
                    
                    switch(type)
                        case 'B'
                            if(k+round(mP.betaB) <= model.TSTEPS)
                                mealDelayed.breakfast(k+round(mP.betaB)) = mealDelayed.breakfast(k+round(mP.betaB)) + C*1000/mP.BW;
                            end
                        case 'L'
                            if(k+round(mP.betaL) <= model.TSTEPS)
                                mealDelayed.lunch(k+round(mP.betaL)) = mealDelayed.lunch(k+round(mP.betaL)) + C*1000/mP.BW;
                            end
                        case 'D'
                            if(k+round(mP.betaD) <= model.TSTEPS)
                                mealDelayed.dinner(k+round(mP.betaD)) = mealDelayed.dinner(k+round(mP.betaD)) + C*1000/mP.BW;
                            end
                        case 'S'
                            if(k+round(mP.betaS) <= model.TSTEPS)
                                mealDelayed.snack(k+round(mP.betaS)) = mealDelayed.snack(k+round(mP.betaS)) + C*1000/mP.BW;
                            end
                        case ''
                            
                        otherwise
                            error("The specified meal type must be 'B', 'L', 'D', 'S', or ''.");
                    end
            end
            
            %Add the meal announcement for bolus calculation
            mealAnnouncements(k) = mealAnnouncements(k) + MA;
            
            %Update the CHO event vectors
            CHO(k) = CHO(k) + C;
        
        end
        if(strcmp(environment.bolusSource,'dss'))
        
            %Call the bolus calculator function handler
            [B, dss] = feval(dss.bolusCalculatorHandler, G, mealAnnouncements, insulinBolus,basal,time,k-1,dss);
            
            %Add insulin boluses to insulin bolus input if needed (remember to add insulin
            %absorption delay)
            if(k+mP.tau <= model.TSTEPS)
                bolusDelayed(k+mP.tau) = bolusDelayed(k+mP.tau) + B*1000/mP.BW;
            end
            
            %Update the insulin bolus event vectors
            insulinBolus(k) = insulinBolus(k) + B;
        end
        
        if(strcmp(environment.basalSource,'dss'))
        
            %Call the bolus calculator function handler
            [B, dss] = feval(dss.basalHandler, G, mealAnnouncements, insulinBolus,basal,time,k-1,dss);
            
            %Add insulin basal to insulin basal input if needed (remember to add insulin
            %absorption delay)
            if(k+mP.tau <= model.TSTEPS)
                basalDelayed(k+mP.tau) = basalDelayed(k+mP.tau) + B*1000/mP.BW;
            end
            
            %Update the insulin bolus event vectors
            insulinBasal(k) = insulinBasal(k) + B;
        end
        
        %Use the hypotreatments module if it is enabled
        if(dss.enableHypoTreatments)
            
            %Call the hypotreatment function handler
            [HT, dss] = feval(dss.hypoTreatmentsHandler,G,CHO,hypotreatments,insulinBolus,insulinBasal,time,k-1,dss);
            
            %Add the hypotreatments to meal model input if needed (remember
            %to add meal absorption delay). NO need to announce an HT.
            switch(environment.scenario)
                case 'single-meal'
                    mealDelayed(k) = mealDelayed(k) + HT*1000/mP.BW;                    
                case 'multi-meal'
                    mealDelayed.hypotreatment(k) = mealDelayed.hypotreatment(k) + HT*1000/mP.BW;
            end
            
            %Update the CHO event vectors
            hypotreatments(k) = hypotreatments(k) + HT;
            
        end
        
        %Use the correction bolus delivery module if it is enabled
        if(dss.enableCorrectionBoluses)
            
            %Call the hypotreatment function handler
            [CB, dss] = feval(dss.correctionBolusesHandler,G,CHO,insulinBolus,insulinBasal,time,k-1,dss);
            
            %Add correction boluses to insulin bolus input if needed (remember to add insulin
            %absorption delay)
            if(k+mP.tau <= model.TSTEPS)
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
        
        %Get the cgm
        if(mod(k-1,sensors.cgm.TS) == 0)
            switch(sensors.cgm.model)
                case 'IG' 
                    CGM(((k-1)/sensors.cgm.TS) + 1) = x(model.nx,k); %y(k) = IG(k)
                case 'BG'
                    CGM(((k-1)/sensors.cgm.TS) + 1) = x(1,k); %y(k) = IG(k)
                case 'CGM'
                    CGM(((k-1)/sensors.cgm.TS) + 1) = cgmMeasure(x(model.nx,k),(k-1)/(24*60),sensors);
            end
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