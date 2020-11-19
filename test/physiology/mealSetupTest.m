% Test units of the mealSetup function
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

%Initialize required variables
model.TS = 1;
model.YTS = 5;

time = datetime(2000,3,1,0,0,0):minutes(model.YTS):datetime(2000,3,1,0,0,0)+minutes(60);
data = timetable(zeros(length(time),1),'VariableNames', {'CHO'}, 'RowTimes', time);
data.CHO(5) = 20;

model.TID = minutes(data.Time(end)-data.Time(1))+model.YTS;
model.TIDSTEPS = model.TID/model.TS;

modelParameters.BW = 100;


%% Test 1: total sum of CHO 
meal = mealSetup(data,model,modelParameters);
assert(sum(data.CHO)*1000/modelParameters.BW*model.YTS/model.TS == sum(meal));

%% Test 2: length of meal 
meal = mealSetup(data,model,modelParameters);
assert(length(meal) == model.TIDSTEPS);

%% Test 3: change model.YTS
model.TS = 1;
model.YTS = 10;

time = datetime(2000,3,1,0,0,0):minutes(model.YTS):datetime(2000,3,1,0,0,0)+minutes(60);
data = timetable(zeros(length(time),1),'VariableNames', {'CHO'}, 'RowTimes', time);
data.CHO(5) = 20;

model.TID = minutes(data.Time(end)-data.Time(1))+model.YTS;
model.TIDSTEPS = model.TID/model.TS;

meal = mealSetup(data,model,modelParameters);
assert(sum(data.CHO)*1000/modelParameters.BW*model.YTS/model.TS == sum(meal));
assert(length(meal) == model.TIDSTEPS);