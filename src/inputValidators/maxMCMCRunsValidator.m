function valid = maxMCMCRunsValidator(maxMCMCRuns,modality)
% function  maxMCMCRunsValidator(maxMCMCRuns,modality)
% Validates the input parameter 'maxMCMCRuns'.

    valid = isnumeric(maxMCMCRuns) && ((maxMCMCRuns - round(maxMCMCRuns)) == 0);
    if(~valid)
        error("Must be an integer number.");
    end
    if(strcmp(modality,'replay'))
        disp("WARNING: you are trying to set the parameter 'maxMCMCRuns' while using the 'replay' modality. It won't be used.");
    end
    
end