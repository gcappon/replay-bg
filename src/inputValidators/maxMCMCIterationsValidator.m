function valid = maxMCMCIterationsValidator(maxMCMCIterations,modality)
% function  maxMCMCIterationsValidator(maxMCMCIterations,modality)
% Validates the input parameter 'maxMCMCIterations'.

    valid = isnumeric(maxMCMCIterations) && ((maxMCMCIterations - round(maxMCMCIterations)) == 0);
    if(~valid)
        error("Must be an integer number.");
    end
    if(strcmp(modality,'replay'))
        disp("WARNING: you are trying to set the parameter 'maxMCMCIterations' while using the 'replay' modality. It won't be used.");
    end
    
end