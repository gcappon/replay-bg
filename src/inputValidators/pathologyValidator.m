function valid = pathologyValidator(pathology)
% function  pathologyValidator(pathology)
% Validates the input parameter 'pathology'.
%
% Inputs:
%   - pathology.
% Outputs:
%   - valid: a boolean defining if the input parameter is valid. 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2021 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    expectedPathologies = {'t1d','t2d','pbh','healthy'};

    valid = any(validatestring(pathology,expectedPathologies));
    if(~valid)
        error("Must be 't1d', 't2d', 'pbh', or 'healthy'.");
    end
    
    
end