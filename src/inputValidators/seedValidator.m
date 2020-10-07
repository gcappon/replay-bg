function valid = seedValidator(seed)
% function  seedValidator(seed)
% Validates the input parameter 'seed'.

    valid = isnumeric(seed) && ((seed - round(seed)) == 0);
    if(~valid)
        error("Must be an integer number.");
    end
    
end