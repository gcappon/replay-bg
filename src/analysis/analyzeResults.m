function analysis = analyzeResults(cgm, glucose, insulinBolus, correctionBolus, insulinBasal, CHO, hypotreatments,data,environment)
% function  analyzeResults(cgm, glucose, insulinBolus, correctionBolus, insulinBasal, CHO, hypotreatments,data,environment)
% Analyses the simulated glucose traces obtained using ReplayBG.
%
% Inputs:
%   - cgm: a structure which contains the obtained cgm traces 
%   simulated via ReplayBG;
%   - glucose: a structure which contains the obtained glucose traces 
%   simulated via ReplayBG; 
%   - insulinBolus: a structure containing the input bolus insulin used to
%   obtain glucose (U/min);
%   - correctionBolus: a structure containing the correction bolus insulin used to
%   obtain glucose (U/min);
%   - insulinBasal: a structure containing the input basal insulin used to
%   obtain glucose (U/min);
%   - CHO: a structure containing the input CHO used to obtain glucose
%   (g/min);
%   - hypotreatments: a structure containing the input hypotreatments used 
%   to obtain glucose (g/min);
%   - data: timetable which contains the data to be used by the tool;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG;
% Output:
%   - analysis: a structure that contains the results of the analysis of
%   the simulated glucose traces obtained using ReplayBG.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    if(environment.verbose)
        tic;
        fprintf('Analyzing results...');
    end    

    %Add libs to the current path
    addpath(genpath(fullfile(environment.replayBGPath,'libs','agata','src'))); %AGATA will be used to analyze the resulting glucose profile

    %Fields to evaluate 
    fields = {'median','ci5th','ci25th','ci75th','ci95th'};

    %Evaluate
    for field = fields
        
        %Transform the glucose profile under examination into a timetable
        glucoseProfile = glucoseVectorToTimetable(glucose.(field{:}),minutes(data.Time(2)-data.Time(1)));
        
        %Analyze the glucose profile
        analysis.(field{:}).glucose = analyzeGlucoseProfile(glucoseProfile);
        
        %Transform the cgm profile under examination into a timetable
        cgmProfile = glucoseVectorToTimetable(cgm.(field{:}),minutes(data.Time(2)-data.Time(1)));
        
        %Analyze the glucose profile
        analysis.(field{:}).cgm = analyzeGlucoseProfile(cgmProfile);
        
    end
    
    % ---------- Compute also insulin and meal "events" metrics
    
    %Initialize insulin amount variables 
    totalInsulin = zeros(length(insulinBolus.realizations),1);
    totalBolusInsulin = zeros(length(insulinBolus.realizations),1);
    totalCorrectionBolusInsulin = zeros(length(insulinBolus.realizations),1);
    totalBasalInsulin = zeros(length(insulinBolus.realizations),1);
    %Initialize CHO amount variables 
    totalCHO = zeros(length(insulinBolus.realizations),1);
    totalHypotreatments = zeros(length(insulinBolus.realizations),1);
    %Initialize counting variables
    correctionBolusInsulinNumber = zeros(length(insulinBolus.realizations),1);
    hypotreatmentNumber = zeros(length(insulinBolus.realizations),1);
    
    for r = 1:size(insulinBolus.realizations,2)
        
        %Compute insulin amounts for each realization
        totalInsulin(r) = sum(insulinBolus.realizations(:,r)) + sum(insulinBasal.realizations(:,r));
        totalBolusInsulin(r) = sum(insulinBolus.realizations(:,r));
        totalCorrectionBolusInsulin(r) = sum(correctionBolus.realizations(:,r));
        totalBasalInsulin(r) = sum(insulinBasal.realizations(:,r));
        
        %Compute CHO amounts for each realization
        totalCHO(r) = sum(CHO.realizations(:,r));
        totalHypotreatments(r) = sum(hypotreatments.realizations(:,r));
        
        %Compute numbers for each realization
        correctionBolusInsulinNumber(r) = length(find(correctionBolus.realizations(:,r)));
        hypotreatmentNumber(r) = length(find(hypotreatments.realizations(:,r)));
        
    end
    
    p = [50, 5, 25, 75, 95];
    for f = 1:length(fields)
        
        analysis.(fields{f}).event.totalInsulin = prctile(totalInsulin,p(f)); %[U]
        analysis.(fields{f}).event.totalBolusInsulin  = prctile(totalBolusInsulin,p(f));%[U]
        analysis.(fields{f}).event.totalCorrectionBolusInsulin = prctile(totalCorrectionBolusInsulin,p(f));%[U]
        analysis.(fields{f}).event.totalBasalInsulin = prctile(totalBasalInsulin,p(f));%[U]
        
        analysis.(fields{f}).event.totalCHO = prctile(totalCHO,p(f));%[g]
        analysis.(fields{f}).event.totalHypotreatments = prctile(totalHypotreatments,p(f));%[g]
        
        analysis.(fields{f}).event.correctionBolusInsulinNumber = prctile(correctionBolusInsulinNumber,p(f));%[#]
        analysis.(fields{f}).event.hypotreatmentNumber = prctile(hypotreatmentNumber,p(f));%[#]
        
    end
    
    %  ---------- Compute identification error metrics (if modality = 'identification')
    
    if(strcmp(environment.modality,'identification'))
        
        for field = fields
            
            %Transform the glucose profile under examination into a timetable
            dataHat = glucoseVectorToTimetable(glucose.(field{:}),minutes(data.Time(2)-data.Time(1)),data.Time(1));
            
            analysis.(field{:}).identification.RMSE = rmse(data,dataHat); % [mg/dl]
            analysis.(field{:}).identification.MARD = mard(data,dataHat); 
            analysis.(field{:}).identification.CEGA = clarke(data,dataHat); % [%]
            analysis.(field{:}).identification.COD = cod(data,dataHat); % [%]
            analysis.(field{:}).identification.GRMSE = gRMSE(data,dataHat); % [%]
            analysis.(field{:}).identification.DELAY = timeDelay(data,dataHat); % [%]

        end
    
    end

    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
end