function valid = gtValidator(GT)
% function  gtValidator(GT)
% Validates the input parameter 'GT'.
%
% Inputs:
%   - GT;
% Outputs:
%   - valid: a boolean defining if the input parameter is valid. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2022 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    valid = isnumeric(GT) || isnan(GT);
    if(~valid)
        error('Must be a number.');
    end
    
end