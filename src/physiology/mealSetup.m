function [meal, mealDelayed] = mealSetup(data,model,modelParameters,environment)
% function  mealSetup(data,model,modelParameters)
% Generates the vector containing the CHO intake events to be used to
% simulate the physiological model.
%
% Inputs:
%   - data: a timetable which contains the data to be used by the tool;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - modelParameters: a struct containing the model parameters;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Outputs:
%   - meal: is a vector containing the carbohydrate intake at each time
%   step [mg/min*kg];
%   - mealDelayed: is a vector containing the carbohydrate intake at each time
%   step delayed by beta min [mg/min*kg].
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
        
    switch(environment.scenario)
        case 'single-meal'
            
            %Initialize the meal vector
            meal = zeros(model.TIDSTEPS,1);


            %Set the meal vector
            for time = 1:length(0:model.YTS:(model.TID-1))
                meal((1+(time-1)*(model.YTS/model.TS)):(time*(model.YTS/model.TS))) = data.CHO(time)*1000/modelParameters.BW; %mg/(kg*min)
            end


            %Add delay of main meal absorption
            mealDelay = round(mP.beta/model.TS);
            mealDelayed = [zeros(mealDelay,1); meal];
            mealDelayed = mealDelayed(1:model.TIDSTEPS);
            
        case 'multi-meal'
            %Initialize the meal structure
            meal.breakfast = zeros(model.TIDSTEPS,1);
            meal.breakfastO = zeros(model.TIDSTEPS,1);
            meal.lunch = zeros(model.TIDSTEPS,1);
            meal.dinner = zeros(model.TIDSTEPS,1);
            meal.snack = zeros(model.TIDSTEPS,1);
            meal.hypotreatment = zeros(model.TIDSTEPS,1);
            
            placeholder = ones(length(1:(model.YTS/model.TS)),1);
            
            bIdx = find(data.choLabel == 'B');
            lIdx = find(data.choLabel == 'L');
            dIdx = find(data.choLabel == 'D');
            sIdx = find(data.choLabel == 'S');
            hIdx = find(data.choLabel == 'H');
            
            %Set the meal vectors
            for i = bIdx
                meal.breakfast((1+(i-1)*(model.YTS/model.TS)):(i*(model.YTS/model.TS))) = placeholder*data.CHO(bIdx)*1000/modelParameters.BW + meal.breakfast((1+(i-1)*(model.YTS/model.TS)):(i*(model.YTS/model.TS))); %mg/(kg*min)
            end
            for i = lIdx
                meal.lunch((1+(i-1)*(model.YTS/model.TS)):(i*(model.YTS/model.TS))) = placeholder*data.CHO(lIdx)*1000/modelParameters.BW + meal.lunch((1+(i-1)*(model.YTS/model.TS)):(i*(model.YTS/model.TS))); %mg/(kg*min)
            end
            for i = dIdx
                meal.dinner((1+(i-1)*(model.YTS/model.TS)):(i*(model.YTS/model.TS))) = placeholder*data.CHO(dIdx)*1000/modelParameters.BW + meal.dinner((1+(i-1)*(model.YTS/model.TS)):(i*(model.YTS/model.TS))); %mg/(kg*min)
            end
            for i = sIdx
                meal.snack((1+(i-1)*(model.YTS/model.TS)):(i*(model.YTS/model.TS))) = placeholder*data.CHO(sIdx)*1000/modelParameters.BW + meal.snack((1+(i-1)*(model.YTS/model.TS)):(i*(model.YTS/model.TS))); %mg/(kg*min)
            end
            for i = hIdx
                meal.hypotreatment((1+(i-1)*(model.YTS/model.TS)):(i*(model.YTS/model.TS))) = placeholder*data.CHO(hIdx)*1000/modelParameters.BW + meal.hypotreatment((1+(i-1)*(model.YTS/model.TS)):(i*(model.YTS/model.TS))); %mg/(kg*min)
            end
            
            %Add delay of main meal absorption
            mealDelayB = round(modelParameters.betaB/model.TS);
            mealDelayL = round(modelParameters.betaL/model.TS);
            mealDelayD = round(modelParameters.betaD/model.TS);
            mealDelayS = round(modelParameters.betaS/model.TS);
            mealDelayH = round(modelParameters.betaH/model.TS);
            
            mealDelayed.breakfast = [zeros(mealDelayB,1); meal.breakfast];
            mealDelayed.breakfast = mealDelayed.breakfast(1:model.TIDSTEPS);
            mealDelayed.lunch = [zeros(mealDelayL,1); meal.lunch];
            mealDelayed.lunch = mealDelayed.lunch(1:model.TIDSTEPS);
            mealDelayed.dinner = [zeros(mealDelayD,1); meal.dinner];
            mealDelayed.dinner = mealDelayed.dinner(1:model.TIDSTEPS);
            mealDelayed.snack = [zeros(mealDelayS,1); meal.snack];
            mealDelayed.snack = mealDelayed.snack(1:model.TIDSTEPS);
            mealDelayed.hypotreatment = [zeros(mealDelayH,1); meal.hypotreatment];
            mealDelayed.hypotreatment = mealDelayed.hypotreatment(1:model.TIDSTEPS);
            
    end
    
    
end