function valid = sampleTimeValidator(sampleTime)
% function  sampleTimeValidator(sampleTime)
% Validates the input parameter 'sampleTime'.

    valid = isnumeric(sampleTime) && ((sampleTime - round(sampleTime)) == 0);
    if(~valid)
        error("Must be an integer number.");
    end
    
end