function physiologicalPlausibility = checkPhysiologicalPlausibility(data,modelParameters,draws,environment,model,sensors,mcmc,dss)
% function  physiologicalPlausibility = checkPhysiologicalPlausibility(data,modelParameters,draws,environment,model,sensors,dss)
% Replays the given scenario defined by the given data.
%
% Inputs:
%   - data: timetable which contains the data to be used by the tool;
%   - modelParameters: a struct containing the model parameters;
%   - draws: a structure that contains the modelParameter draws obtained
%   with MCMC;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - sensors: a structure that contains general parameters of the
%   sensors models;
%   - mcmc: a structure that contains the hyperparameters of the MCMC
%   identification procedure;
%   - dss: a structure that contains the hyperparameters of the integrated
%   decision support system.
% Outputs:
%   - physiologicalPlausibility: a vector of logical flags (one for each 
%   model parameter draw) indicating if the given draw is physiologically
%   plausible. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2023 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    if(environment.verbose)
        tic;
        fprintf('Checking parameter physiological plausibility...');
    end

    %Initialize the return vector
    physiologicalPlausibility.test1 = ones(length(draws.(mcmc.thetaNames{1}).samples),1);
    physiologicalPlausibility.test2 = ones(length(draws.(mcmc.thetaNames{1}).samples),1);
    physiologicalPlausibility.test3 = ones(length(draws.(mcmc.thetaNames{1}).samples),1);
    physiologicalPlausibility.test4 = ones(length(draws.(mcmc.thetaNames{1}).samples),1);
    
    %Set "fake" model core variable for simulation
    modelFake = model;
    modelFake.TSTEPS = 1440;
    modelFake.TYSTEPS = modelFake.TSTEPS/modelFake.YTS;
    modelFake.glucoseModel = 'IG';
    if(model.exercise)
        modelFake.exercise = 0;
        modelFake.nx = model.nx-1;
    end
    
    %Set "fake" environment core variable for simulation
    environmentFake = environment;
    environmentFake.modality = 'replay';
    
    %Set "fake" data for simulation
    toAttach = max([0 modelFake.TYSTEPS - height(data)]);
    dataFakeTime = data.Time;
    dataFakeTime = [dataFakeTime; (dataFakeTime(end)+minutes(modelFake.YTS):minutes(modelFake.YTS):dataFakeTime(end)+minutes(modelFake.YTS)*toAttach)'];
    dataFakeTime = dataFakeTime(1:modelFake.TYSTEPS);
    glucose = zeros(modelFake.TYSTEPS,1);
    basal = zeros(modelFake.TYSTEPS,1);
    bolus = zeros(modelFake.TYSTEPS,1);
    bolusLabel = repmat("",modelFake.TYSTEPS,1);
    CHO = zeros(modelFake.TYSTEPS,1);
    choLabel = repmat("",modelFake.TYSTEPS,1);
    %exercise = repmat(missing(),modelFake.TYSTEPS,1);
    Time = dataFakeTime;
    dataFake = timetable(glucose,basal,bolus,bolusLabel,CHO,choLabel,'RowTimes',Time);
    
    %% Test 1: "if no insulin is injected, BG must go above 300 mg/dl in 1000 min"
    
    %Set simulation data
    dataFakeTest1 = dataFake;
    
    %For each parameter set...
    for r = 1:length(draws.(mcmc.thetaNames{1}).samples)
        
        %...set the modelParameter structure to such a set...
        for p = 1:length(mcmc.thetaNames)
            modelParameters.(mcmc.thetaNames{p}) = draws.(mcmc.thetaNames{p}).samples(r);
        end
        
        
        %If the CGM model is selected...
        if(strcmp(sensors.cgm.model,'CGM'))
            
            %..connect a new CGM sensor
            [sensors.cgm.errorParameters, sensors.cgm.outputNoiseSD] = connectNewCGM(sensors);
        
        end
        
        %Enforce model constraints
        modelParameters = enforceConstraints(modelParameters, model, environment);
        
        %...and simulate the scenario using the given data
        [G, CGM, iB, cB, ib, C, ht, mA, v, ~] = computeGlicemia(modelParameters,dataFakeTest1,modelFake,sensors,dss,environmentFake);

        %Check G
        if(~any(G > 300))
            physiologicalPlausibility.test1(r) = 0;
        end
    end
    
    %% Test 2: "if a bolus of 15 U is injected, BG should drop below 100 mg/dl"
    
    %Set simulation data
    dataFakeTest2 = dataFake;
    dataFakeTest2.basal(:) = mean(data.basal);
    dataFakeTest2.bolus(1) = 3;
    if(hour(dataFakeTest2.Time(1))<4 || hour(dataFakeTest2.Time(1)) >= 17)
        dataFakeTest2.bolusLabel(1) = "D";
    else
        if(hour(dataFakeTest2.Time(1))>=4 && hour(dataFakeTest2.Time(1)) < 11)
            dataFakeTest2.bolusLabel(1) = "B";
        else
            dataFakeTest2.bolusLabel(1) = "L";
        end
    end
    
    %For each parameter set...
    for r = 1:length(draws.(mcmc.thetaNames{1}).samples)
        
        %...set the modelParameter structure to such a set...
        for p = 1:length(mcmc.thetaNames)
            modelParameters.(mcmc.thetaNames{p}) = draws.(mcmc.thetaNames{p}).samples(r);
        end
        
        
        %If the CGM model is selected...
        if(strcmp(sensors.cgm.model,'CGM'))
            
            %..connect a new CGM sensor
            [sensors.cgm.errorParameters, sensors.cgm.outputNoiseSD] = connectNewCGM(sensors);
        
        end
        
        %Enforce model constraints
        modelParameters = enforceConstraints(modelParameters, model, environment);
        
        %...and simulate the scenario using the given data
        [G, CGM, iB, cB, ib, C, ht, mA, v, ~] = computeGlicemia(modelParameters,dataFakeTest2,modelFake,sensors,dss,environmentFake);

        %Check G
        if(~any(G < 100))
            physiologicalPlausibility.test2(r) = 0;
        end
    end
    
    %% Test 3: "it exists a basal insulin value such that glucose stays between 90 and 160 mg/dl", 
    
    %Set simulation data
    dataFakeTest3 = dataFake;
    
    maxCheck = 25;
    check = 1;
    lBasal = 0;
    rBasal = 0.5;
    dataFakeTest3.basal(:) = (rBasal+lBasal)/2;
    
    %For each parameter set...
    for r = 1:length(draws.(mcmc.thetaNames{1}).samples)
        
        %...set the modelParameter structure to such a set...
        for p = 1:length(mcmc.thetaNames)
            modelParameters.(mcmc.thetaNames{p}) = draws.(mcmc.thetaNames{p}).samples(r);
        end
        
        
        %If the CGM model is selected...
        if(strcmp(sensors.cgm.model,'CGM'))
            
            %..connect a new CGM sensor
            [sensors.cgm.errorParameters, sensors.cgm.outputNoiseSD] = connectNewCGM(sensors);
        
        end
        
        %Enforce model constraints
        modelParameters = enforceConstraints(modelParameters, model, environment);
        
        
        
        converged = 0;
        
        while(check < maxCheck && ~converged)
            
            %...and simulate the scenario using the given data
            [G, CGM, iB, cB, ib, C, ht, mA, v, ~] = computeGlicemia(modelParameters,dataFakeTest3,modelFake,sensors,dss,environmentFake);

            %Check G
            if(all(G >= 90 & G <= 160))
                converged = 1;
            else
                if(any(G < 90) && any(G > 160))
                    physiologicalPlausibility.test3(r) = 0;
                    converged = 1;
                else
                    if(any(G < 90))
                        rBasal = dataFakeTest3.basal(1);
                        dataFakeTest3.basal(:) = (rBasal+lBasal)/2;
                    else
                        lBasal = dataFakeTest3.basal(1);
                        dataFakeTest3.basal(:) = (rBasal+lBasal)/2;
                    end
                    check = check + 1;
                end

            end
            
        end
        
    end
    
    %% Test 4: "a variation of basal insulin of 0.01 U/h does not vary basal glucose more than 20 mg/dl"
    
    %Set simulation data
    dataFakeTest4 = dataFake;
    dataFakeTest4.basal(:) = mean(data.basal);
    
    %For each parameter set...
    for r = 1:length(draws.(mcmc.thetaNames{1}).samples)
        
        %...set the modelParameter structure to such a set...
        for p = 1:length(mcmc.thetaNames)
            modelParameters.(mcmc.thetaNames{p}) = draws.(mcmc.thetaNames{p}).samples(r);
        end
        
        
        %If the CGM model is selected...
        if(strcmp(sensors.cgm.model,'CGM'))
            
            %..connect a new CGM sensor
            [sensors.cgm.errorParameters, sensors.cgm.outputNoiseSD] = connectNewCGM(sensors);
        
        end
        
        %Enforce model constraints
        modelParameters = enforceConstraints(modelParameters, model, environment);
        
        %...and simulate the scenario using the given data
        [G, CGM, iB, cB, ib, C, ht, mA, v, ~] = computeGlicemia(modelParameters,dataFakeTest4,modelFake,sensors,dss,environmentFake);
        mean1 = mean(G(length(G)/2:end));
        
        dataFakeTest4.basal(:) = mean(data.basal)+0.01;
        [G, CGM, iB, cB, ib, C, ht, mA, v, ~] = computeGlicemia(modelParameters,dataFakeTest4,modelFake,sensors,dss,environmentFake);
        mean2 = mean(G(length(G)/2:end));
        
        if(abs(mean2-mean1) > 20)
            physiologicalPlausibility.test4(r) = 0;
        end
        
    end
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
end