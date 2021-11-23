function valid = adaptiveSCMHValidator(adaptiveSCMH, modality)
% function  adaptiveSCMHValidator(adaptiveSCMH,modality)
% Validates the input parameter 'adaptiveSCMH'.
%
% Inputs:
%   - adaptiveSCMH;
%   - modality;
% Output:
%   - valid: a boolean defining if the input parameter is valid. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    valid = adaptiveSCMH == 0 || adaptiveSCMH == 1;
    if(~valid)
        error('Must be 0 or 1.');
    end
    
    if(strcmp(modality,'replay'))
        warning("You are trying to set the parameter 'adaptiveSCMH' while using the 'replay' modality. It won't be used.");
    end
    
end