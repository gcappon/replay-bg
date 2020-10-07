function valid = seedValidator(seed)
% function  seedValidator(seed)
% Validates the input parameter 'seed'.
%
% Inputs:
%   - seed;
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

    valid = isnumeric(seed) && ((seed - round(seed)) == 0);
    if(~valid)
        error("Must be an integer number.");
    end
    
end