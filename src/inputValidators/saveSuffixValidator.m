function valid = saveSuffixValidator(saveSuffix)
% function  saveSuffixValidator(saveSuffix)
% Validates the input parameter 'saveSuffix'.

    valid = ischar(saveSuffix);
    if(~valid)
        error('Must be a vector of characters.');
    end
    
end