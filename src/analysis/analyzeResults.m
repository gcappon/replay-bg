function analysis = analyzeResults(glucose, insulinBolus, correctionBolus, insulinBasal, CHO, hypotreatments,data,environment)
% function  analyzeResults(glucose,data,environment)
% Analyses the simulated glucose traces obtained using ReplayBG.
%
% Inputs:
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
        fprintf(['Analyzing results...']);
    end

    %Compute glucose control metrics
    analysis.control.tHypo.median = 100*sum(glucose.median < 70)/length(glucose.median); % [%]
    analysis.control.tHypo.ci5th = 100*sum(glucose.ci5th < 70)/length(glucose.ci5th); % [%]
    analysis.control.tHypo.ci25th = 100*sum(glucose.ci25th < 70)/length(glucose.ci25th); % [%]
    analysis.control.tHypo.ci75th = 100*sum(glucose.ci75th < 70)/length(glucose.ci75th); % [%]
    analysis.control.tHypo.ci95th = 100*sum(glucose.ci95th < 70)/length(glucose.ci95th); % [%]
    
    analysis.control.tHyper.median = 100*sum(glucose.median > 180)/length(glucose.median); % [%]
    analysis.control.tHyper.ci5th = 100*sum(glucose.ci5th > 180)/length(glucose.ci5th); % [%]
    analysis.control.tHyper.ci25th = 100*sum(glucose.ci25th > 180)/length(glucose.ci25th); % [%]
    analysis.control.tHyper.ci75th = 100*sum(glucose.ci75th > 180)/length(glucose.ci75th); % [%]
    analysis.control.tHyper.ci95th = 100*sum(glucose.ci95th > 180)/length(glucose.ci95th); % [%]
        
    analysis.control.tEu.median = 100 - analysis.control.tHypo.median - analysis.control.tHyper.median; % [%]
    analysis.control.tEu.ci5th = 100 - analysis.control.tHypo.ci5th - analysis.control.tHyper.ci5th; % [%]
    analysis.control.tEu.ci25th = 100 - analysis.control.tHypo.ci25th - analysis.control.tHyper.ci25th; % [%]
    analysis.control.tEu.ci75th = 100 - analysis.control.tHypo.ci75th - analysis.control.tHyper.ci75th; % [%]
    analysis.control.tEu.ci95th = 100 - analysis.control.tHypo.ci95th - analysis.control.tHyper.ci95th; % [%]
    
    analysis.control.meanGlucose.median = mean(glucose.median); % [mg/dl]
    analysis.control.meanGlucose.ci5th = mean(glucose.ci5th); % [mg/dl]
    analysis.control.meanGlucose.ci25th = mean(glucose.ci25th); % [mg/dl]
    analysis.control.meanGlucose.ci75th = mean(glucose.ci75th); % [mg/dl]
    analysis.control.meanGlucose.ci95th = mean(glucose.ci95th); % [mg/dl]
    
    analysis.control.stdGlucose.median = std(glucose.median); % [mg/dl]
    analysis.control.stdGlucose.ci5th = std(glucose.ci5th); % [mg/dl]
    analysis.control.stdGlucose.ci25th = std(glucose.ci25th); % [mg/dl]
    analysis.control.stdGlucose.ci75th = std(glucose.ci75th); % [mg/dl]
    analysis.control.stdGlucose.ci95th = std(glucose.ci95th); % [mg/dl]
    
    %Compute "events" metrics
    totalInsulin = zeros(length(insulinBolus.realizations),1);
    totalBolusInsulin = zeros(length(insulinBolus.realizations),1);
    totalCorrectionBolusInsulin = zeros(length(insulinBolus.realizations),1);
    totalBasalInsulin = zeros(length(insulinBolus.realizations),1);
    
    totalCHO = zeros(length(insulinBolus.realizations),1);
    totalHypotreatments = zeros(length(insulinBolus.realizations),1);
    
    correctionBolusInsulinNumber = zeros(length(insulinBolus.realizations),1);
    hypotreatmentNumber = zeros(length(insulinBolus.realizations),1);
    
    for r = 1:length(insulinBolus.realizations)
        
        %Compute insulin amounts
        totalInsulin(r) = sum(insulinBolus.realizations(:,r)) + sum(insulinBasal.realizations(:,r));
        totalBolusInsulin(r) = sum(insulinBolus.realizations(:,r));
        totalCorrectionBolusInsulin(r) = sum(correctionBolus.realizations(:,r));
        totalBasalInsulin(r) = sum(insulinBasal.realizations(:,r));
        
        %Compute CHO amounts
        totalCHO(r) = sum(CHO.realizations(:,r));
        totalHypotreatments(r) = sum(hypotreatments.realizations(:,r));
        
        %Compute numbers 
        correctionBolusInsulinNumber(r) = length(find(correctionBolus.realizations(:,r)));
        hypotreatmentNumber(r) = length(find(hypotreatments.realizations(:,r)));
        
    end
    
    analysis.events.totalInsulin.median = median(totalInsulin); %[U]
    analysis.events.totalInsulin.ci5th = prctile(totalInsulin,5);%[U]
    analysis.events.totalInsulin.ci25th = prctile(totalInsulin,25);%[U]
    analysis.events.totalInsulin.ci75th = prctile(totalInsulin,75);%[U]
    analysis.events.totalInsulin.ci95th = prctile(totalInsulin,95);%[U]
    
    analysis.events.totalBolusInsulin.median = median(totalBolusInsulin);      %[U]
    analysis.events.totalBolusInsulin.ci5th = prctile(totalBolusInsulin,5);%[U]
    analysis.events.totalBolusInsulin.ci25th = prctile(totalBolusInsulin,25);%[U]
    analysis.events.totalBolusInsulin.ci75th = prctile(totalBolusInsulin,75);%[U]
    analysis.events.totalBolusInsulin.ci95th = prctile(totalBolusInsulin,95);%[U]
    
    analysis.events.totalCorrectionBolusInsulin.median = median(totalCorrectionBolusInsulin);%[U]
    analysis.events.totalCorrectionBolusInsulin.ci5th = prctile(totalCorrectionBolusInsulin,5);%[U]
    analysis.events.totalCorrectionBolusInsulin.ci25th = prctile(totalCorrectionBolusInsulin,25);%[U]
    analysis.events.totalCorrectionBolusInsulin.ci75th = prctile(totalCorrectionBolusInsulin,75);%[U]
    analysis.events.totalCorrectionBolusInsulin.ci95th = prctile(totalCorrectionBolusInsulin,95);%[U]
    
    analysis.events.totalBasalInsulin.median = median(totalBasalInsulin);%[U]
    analysis.events.totalBasalInsulin.ci5th = prctile(totalBasalInsulin,5);%[U]
    analysis.events.totalBasalInsulin.ci25th = prctile(totalBasalInsulin,25);%[U]
    analysis.events.totalBasalInsulin.ci75th = prctile(totalBasalInsulin,75);%[U]
    analysis.events.totalBasalInsulin.ci95th = prctile(totalBasalInsulin,95);%[U]
    
    analysis.events.totalCHO.median = median(totalCHO);%[g]
    analysis.events.totalCHO.ci5th = prctile(totalCHO,5);%[g]
    analysis.events.totalCHO.ci25th = prctile(totalCHO,25);%[g]
    analysis.events.totalCHO.ci75th = prctile(totalCHO,75);%[g]
    analysis.events.totalCHO.ci95th = prctile(totalCHO,95);%[g]
    
    analysis.events.totalHypotreatments.median = median(totalHypotreatments);%[g]
    analysis.events.totalHypotreatments.ci5th = prctile(totalHypotreatments,5);%[g]
    analysis.events.totalHypotreatments.ci25th = prctile(totalHypotreatments,25);%[g]
    analysis.events.totalHypotreatments.ci75th = prctile(totalHypotreatments,75);%[g]
    analysis.events.totalHypotreatments.ci95th = prctile(totalHypotreatments,95);%[g]
    
    analysis.events.correctionBolusInsulinNumber.median = median(correctionBolusInsulinNumber);%[#]
    analysis.events.correctionBolusInsulinNumber.ci5th = prctile(correctionBolusInsulinNumber,5);%[#]
    analysis.events.correctionBolusInsulinNumber.ci25th = prctile(correctionBolusInsulinNumber,25);%[#]
    analysis.events.correctionBolusInsulinNumber.ci75th = prctile(correctionBolusInsulinNumber,75);%[#]
    analysis.events.correctionBolusInsulinNumber.ci95th = prctile(correctionBolusInsulinNumber,95);%[#]
    
    analysis.events.hypotreatmentNumber.median = median(hypotreatmentNumber);%[#]
    analysis.events.hypotreatmentNumber.ci5th = prctile(hypotreatmentNumber,5);%[#]
    analysis.events.hypotreatmentNumber.ci25th = prctile(hypotreatmentNumber,25);%[#]
    analysis.events.hypotreatmentNumber.ci75th = prctile(hypotreatmentNumber,75);%[#]
    analysis.events.hypotreatmentNumber.ci95th = prctile(hypotreatmentNumber,95);%[#]
    
    
    %Compute identification metrics (if modality = 'identification')
    if(strcmp(environment.modality,'identification'))
        analysis.identification.RMSE.median = sqrt(mean((glucose.median-data.glucose).^2)); % [mg/dl]
        analysis.identification.RMSE.ci5th = sqrt(mean((glucose.ci5th-data.glucose).^2)); % [mg/dl]
        analysis.identification.RMSE.ci25th = sqrt(mean((glucose.ci25th-data.glucose).^2)); % [mg/dl]
        analysis.identification.RMSE.ci75th = sqrt(mean((glucose.ci75th-data.glucose).^2)); % [mg/dl]
        analysis.identification.RMSE.ci95th = sqrt(mean((glucose.ci95th-data.glucose).^2)); % [mg/dl]
        
    	analysis.identification.MARD.median = mean(abs(glucose.median-data.glucose)./data.glucose)*100; % [%]
        analysis.identification.MARD.ci5th = mean(abs(glucose.ci5th-data.glucose)./data.glucose)*100; % [%]
        analysis.identification.MARD.ci25th = mean(abs(glucose.ci25th-data.glucose)./data.glucose)*100; % [%]
        analysis.identification.MARD.ci75th = mean(abs(glucose.ci75th-data.glucose)./data.glucose)*100; % [%]
        analysis.identification.MARD.ci95th = mean(abs(glucose.ci95th-data.glucose)./data.glucose)*100; % [%]
    end
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
end