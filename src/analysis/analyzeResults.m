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
        fprintf('Analyzing results...');
    end
    
    %Compute glucose control metrics
    
    %Fields to evaluate 
    fields = {'median','ci5th','ci25th','ci75th','ci95th'};
    
    
    for field = fields
        
        %Time spent in glycemic zones
        analysis.control.tHypo.(field{:}) = 100*sum(glucose.(field{:}) < 70)/length(glucose.(field{:})); % [%]
        analysis.control.tHyper.(field{:}) = 100*sum(glucose.(field{:}) > 180)/length(glucose.(field{:})); % [%]  
        analysis.control.tEu.(field{:}) = 100 - analysis.control.tHypo.(field{:}) - analysis.control.tHyper.(field{:}); % [%]
        
        %Glycemic variability
        analysis.control.meanGlucose.(field{:}) = mean(glucose.(field{:})); % [mg/dl]
        analysis.control.stdGlucose.(field{:}) = std(glucose.(field{:})); % [mg/dl]
        analysis.control.cvGlucose.(field{:}) = 100*analysis.control.stdGlucose.(field{:})/analysis.control.meanGlucose.(field{:}); % [%]
    
    end
    
    %Compute "events" metrics
    
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
    
    for r = 1:length(insulinBolus.realizations)
        
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
        
        analysis.events.totalInsulin.(fields{f}) = prctile(totalInsulin,p(f)); %[U]
        analysis.events.totalBolusInsulin.(fields{f})  = prctile(totalBolusInsulin,p(f));%[U]
        analysis.events.totalCorrectionBolusInsulin.(fields{f}) = prctile(totalCorrectionBolusInsulin,p(f));%[U]
        analysis.events.totalBasalInsulin.(fields{f}) = prctile(totalBasalInsulin,p(f));%[U]
        
        analysis.events.totalCHO.(fields{f}) = prctile(totalCHO,p(f));%[g]
        analysis.events.totalHypotreatments.(fields{f}) = prctile(totalHypotreatments,p(f));%[g]
        
        analysis.events.correctionBolusInsulinNumber.(fields{f}) = prctile(correctionBolusInsulinNumber,p(f));%[#]
        analysis.events.hypotreatmentNumber.(fields{f}) = prctile(hypotreatmentNumber,p(f));%[#]
        
    end
    
    %Compute identification metrics (if modality = 'identification')
    if(strcmp(environment.modality,'identification'))
        
        for f = fields
        
            analysis.identification.RMSE.(f) = sqrt(mean((glucose.(f)-data.glucose).^2)); % [mg/dl]
            analysis.identification.MARD.(f) = mean(abs(glucose.(f)-data.glucose)./data.glucose)*100; % [%]
            analysis.identification.CEGA.(f) = clarke(data.glucose,glucose.(f)); % [%]

        end
    
    end
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
end