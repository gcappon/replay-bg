function [meal, mealDelayed, mealAnnouncement] = mealSetup(data,model,modelParameters,environment)
% function  mealSetup(data,model,modelParameters,environment)
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
%   step delayed by beta min [mg/min*kg];
%   - mealAnnouncements: is a vector containing the carbohydrate intake at each time
%   step that the user announces to the bolus calculator (g).                
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
            meal = zeros(model.TSTEPS,1);
            
            %Initialize the mealAnnouncements vector
            mealAnnouncement = zeros(model.TSTEPS,1);
            
            if(strcmp(environment.choSource,'data'))
                
                %Find the meals
                mIdx = find(data.CHO);

                %Set the meal vector
                for i = 1:length(mIdx)
                    meal((1+(mIdx(i)-1)*(model.YTS/model.TS)):(mIdx(i)*(model.YTS/model.TS))) = data.CHO(mIdx(i))*1000/modelParameters.BW; %mg/(kg*min)
                    mealAnnouncement((1+(mIdx(i)-1)*(model.YTS/model.TS))) = data.CHO(mIdx(i))*(model.YTS/model.TS); %mg/(kg*min)
                    
                end
                
            end
            
            %Add delay of main meal absorption
            mealDelay = round(modelParameters.beta/model.TS);
            firstMeal = meal;
            idxFirstMeal = find(firstMeal > 0,1,'first');
            firstMeal((idxFirstMeal+model.YTS):end) = 0;
            otherMeals = meal;
            otherMeals(1:(idxFirstMeal+model.YTS-1)) = 0;
            firstMealDelayed = [zeros(mealDelay,1); firstMeal];
            firstMealDelayed = firstMealDelayed(1:model.TSTEPS);
            mealDelayed = firstMealDelayed + otherMeals;
            
        case 'multi-meal'
            %Initialize the meal structure
            meal.breakfast = zeros(model.TSTEPS,1);
            meal.lunch = zeros(model.TSTEPS,1);
            meal.dinner = zeros(model.TSTEPS,1);
            meal.snack = zeros(model.TSTEPS,1);
            meal.hypotreatment = zeros(model.TSTEPS,1);
            
            %Inizialize the mealAnnouncement vector
            mealAnnouncement = zeros(model.TSTEPS,1);
            
            if(strcmp(environment.choSource,'data'))
                
                placeholder = ones(length(1:(model.YTS/model.TS)),1);

                bIdx = find(data.choLabel == 'B');
                lIdx = find(data.choLabel == 'L');
                dIdx = find(data.choLabel == 'D');
                sIdx = find(data.choLabel == 'S');
                hIdx = find(data.choLabel == 'H');

                %Set the meal vectors
                for i = 1:length(bIdx)
                    meal.breakfast((1+(bIdx(i)-1)*(model.YTS/model.TS)):(bIdx(i)*(model.YTS/model.TS))) = ...
                        placeholder*data.CHO(bIdx(i))*1000/modelParameters.BW + ...
                        meal.breakfast((1+(bIdx(i)-1)*(model.YTS/model.TS)):(bIdx(i)*(model.YTS/model.TS))); %mg/(kg*min)
                    mealAnnouncement((1+(bIdx(i)-1)*(model.YTS/model.TS))) = data.CHO(bIdx(i))*(model.YTS/model.TS); %g
                end
                for i = 1:length(lIdx)
                    meal.lunch((1+(lIdx(i)-1)*(model.YTS/model.TS)):(lIdx(i)*(model.YTS/model.TS))) = ...
                        placeholder*data.CHO(lIdx(i))*1000/modelParameters.BW + ...
                        meal.lunch((1+(lIdx(i)-1)*(model.YTS/model.TS)):(lIdx(i)*(model.YTS/model.TS))); %mg/(kg*min)
                    mealAnnouncement((1+(lIdx(i)-1)*(model.YTS/model.TS))) = data.CHO(lIdx(i))*(model.YTS/model.TS); %g
                end
                for i = 1:length(dIdx)
                    meal.dinner((1+(dIdx(i)-1)*(model.YTS/model.TS)):(dIdx(i)*(model.YTS/model.TS))) = ...
                        placeholder*data.CHO(dIdx(i))*1000/modelParameters.BW + ...
                        meal.dinner((1+(dIdx(i)-1)*(model.YTS/model.TS)):(dIdx(i)*(model.YTS/model.TS))); %mg/(kg*min)
                    mealAnnouncement((1+(dIdx(i)-1)*(model.YTS/model.TS))) = data.CHO(dIdx(i))*(model.YTS/model.TS); %g
                end
                for i = 1:length(sIdx)
                    meal.snack((1+(sIdx(i)-1)*(model.YTS/model.TS)):(sIdx(i)*(model.YTS/model.TS))) = ...
                        placeholder*data.CHO(sIdx(i))*1000/modelParameters.BW + ...
                        meal.snack((1+(sIdx(i)-1)*(model.YTS/model.TS)):(sIdx(i)*(model.YTS/model.TS))); %mg/(kg*min)
                    mealAnnouncement((1+(sIdx(i)-1)*(model.YTS/model.TS))) = data.CHO(sIdx(i))*(model.YTS/model.TS); %g
                end
                for i = 1:length(hIdx)
                    meal.hypotreatment((1+(hIdx(i)-1)*(model.YTS/model.TS)):(hIdx(i)*(model.YTS/model.TS))) = ...
                        placeholder*data.CHO(hIdx(i))*1000/modelParameters.BW + ...
                        meal.hypotreatment((1+(hIdx(i)-1)*(model.YTS/model.TS)):(hIdx(i)*(model.YTS/model.TS))); %mg/(kg*min)
                end
            
            end
            
            %Add delay of main meal absorption
            mealDelayB = round(modelParameters.betaB/model.TS);
            mealDelayL = round(modelParameters.betaL/model.TS);
            mealDelayD = round(modelParameters.betaD/model.TS);
            mealDelayS = round(modelParameters.betaS/model.TS);
            mealDelayH = round(modelParameters.betaH/model.TS);
            
            mealDelayed.breakfast = [zeros(mealDelayB,1); meal.breakfast];
            mealDelayed.breakfast = mealDelayed.breakfast(1:model.TSTEPS);
            mealDelayed.lunch = [zeros(mealDelayL,1); meal.lunch];
            mealDelayed.lunch = mealDelayed.lunch(1:model.TSTEPS);
            mealDelayed.dinner = [zeros(mealDelayD,1); meal.dinner];
            mealDelayed.dinner = mealDelayed.dinner(1:model.TSTEPS);
            mealDelayed.snack = [zeros(mealDelayS,1); meal.snack];
            mealDelayed.snack = mealDelayed.snack(1:model.TSTEPS);
            mealDelayed.hypotreatment = [zeros(mealDelayH,1); meal.hypotreatment];
            mealDelayed.hypotreatment = mealDelayed.hypotreatment(1:model.TSTEPS);
            
    end
    
    
end