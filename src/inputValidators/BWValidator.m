function valid = BWValidator(BW)
% function  BWValidator(BW)
% Validates the input parameter 'BW'.

    valid = isnumeric(BW);
    if(~valid)
        error('Must be a number.');
    end
    
end