function valid = modalityValidator(modality)
% function  modalityValidator(modality)
% Validates the input parameter 'modality'.

    expectedModalities = {'replay','identification'};

    valid = any(validatestring(modality,expectedModalities));
    if(~valid)
        error("Must be 'replay' or 'identification'.");
    end
    
end