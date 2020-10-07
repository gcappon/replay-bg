function valid = maxMCMCRunsWithMaxETAValidator(maxMCMCRunsWithMaxETA,modality)
% function  maxMCMCRunsWithMaxETAValidator(maxMCMCRunsWithMaxETA,modality)
% Validates the input parameter 'maxMCMCRunsWithMaxETA'.

    valid = isnumeric(maxMCMCRunsWithMaxETA) && ((maxMCMCRunsWithMaxETA - round(maxMCMCRunsWithMaxETA)) == 0);
    if(~valid)
        error("Must be an integer number.");
    end
    if(strcmp(modality,'replay'))
        disp("WARNING: you are trying to set the parameter 'maxMCMCRunsWithMaxETA' while using the 'replay' modality. It won't be used.");
    end
    
end