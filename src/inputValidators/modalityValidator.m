function valid = modalityValidator(modality)
% function  modalityValidator(modality)
% Validates the input parameter 'modality'.
%
% Inputs:
%   - modality;
% Outputs:
%   - valid: a boolean defining if the input parameter is valid. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    expectedModalities = {'replay','identification'};

    valid = any(validatestring(modality,expectedModalities));
    if(~valid)
        error("Must be 'replay' or 'identification'.");
    end
    
end