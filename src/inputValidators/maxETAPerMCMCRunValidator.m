function valid = maxETAPerMCMCRunValidator(maxETAPerMCMCRun,modality)
% function  maxETAPerMCMCRunValidator(maxETAPerMCMCRun)
% Validates the input parameter 'maxETAPerMCMCRun'.

    valid = isnumeric(maxETAPerMCMCRun);
    if(~valid)
        error("Must be a number.");
    end
    if(strcmp(modality,'replay'))
        disp("WARNING: you are trying to set the parameter 'maxETAPerMCMCRun' while using the 'replay' modality. It won't be used.");
    end
    
end