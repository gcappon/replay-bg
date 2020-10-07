function valid = verboseValidator(verbose)
% function  verboseValidator(verbose)
% Validates the input parameter 'verbose'.

    valid = verbose == 0 || verbose == 1;
    if(~valid)
        error('Must be 0 or 1.');
    end
    
end