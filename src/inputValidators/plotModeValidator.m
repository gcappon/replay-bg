function valid = plotModeValidator(plotMode)
% function  plotModeValidator(plotModel)
% Validates the input parameter 'plotMode'.

    valid = plotMode == 0 || plotMode == 1;
    if(~valid)
        error('Must be 0 or 1.');
    end
    
end