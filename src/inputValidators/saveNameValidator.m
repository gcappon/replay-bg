function valid = saveNameValidator(saveName)
% function  saveNameValidator(saveName)
% Validates the input parameter 'saveName'.

    valid = ischar(saveName);
    if(~valid)
        error("Must be a vector of characters.");
    end
    
end