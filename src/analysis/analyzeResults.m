function analysis = analyzeResults(glucose,data,environment)
    
    %Glucose control metrics
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
    
    %Identification metrics
    if(strcmp(environment.modality,'identifyReplayBGModel'))
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
    
end