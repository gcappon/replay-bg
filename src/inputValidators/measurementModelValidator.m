function valid = measurementModelValidator(measurementModel)
% function  measurementModelValidator(measurementModel)
% Validates the input parameter 'measurementModel'.

    expectedMeasurementModels = {'BG','IG'};

    valid = any(validatestring(measurementModel,expectedMeasurementModels));
    if(~valid)
        error("Must be 'IG' or 'BG'.");
    end
    
end