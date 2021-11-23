% Test units of the insulinSetup function
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
data = timetable(ones(length(time),1),zeros(length(time),1),'VariableNames', {'basal','bolus'}, 'RowTimes', time);
data.bolus(5) = 2;

model.T = minutes(data.Time(end)-data.Time(1))+model.YTS;
model.TSTEPS = model.T/model.TS;

modelParameters.BW = 100;


%% Test 1: total sum of insulin 
[bolus, basal] = insulinSetup(data,model,modelParameters);
assert(sum(data.bolus)*1000/modelParameters.BW*model.YTS/model.TS == sum(bolus));
assert(sum(data.basal)*1000/modelParameters.BW*model.YTS/model.TS == sum(basal));

%% Test 2: length of basal and bolus 
[bolus, basal] = insulinSetup(data,model,modelParameters);
assert(length(basal) == model.TSTEPS);
assert(length(bolus) == model.TSTEPS);

%% Test 3: change model.YTS
model.TS = 1;
model.YTS = 10;

time = datetime(2000,3,1,0,0,0):minutes(model.YTS):datetime(2000,3,1,0,0,0)+minutes(60);
data = timetable(ones(length(time),1),zeros(length(time),1),'VariableNames', {'basal','bolus'}, 'RowTimes', time);
data.bolus(5) = 2;

model.T = minutes(data.Time(end)-data.Time(1))+model.YTS;
model.TSTEPS = model.T/model.TS;

[bolus, basal] = insulinSetup(data,model,modelParameters);
assert(sum(data.bolus)*1000/modelParameters.BW*model.YTS/model.TS == sum(bolus));
assert(sum(data.basal)*1000/modelParameters.BW*model.YTS/model.TS == sum(basal));
assert(length(basal) == model.TSTEPS);
assert(length(bolus) == model.TSTEPS);