function valid = pathologyValidator(pathology,data)
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

    valid = any(strcmp(data.Properties.VariableNames,'choLabel'));
    
    if(~valid)
        error("Must contain a column named 'choLabel'.");
    end
    
    okLabels = ["B","L","D","S","H"];
    labels = data.choLabel(data.CHO > 0);
    valid = valid && all(contains(labels,okLabels));
    if(~valid)
        error("Must contain a label for every CHO and they must be 'B', 'L', 'D', 'S', or 'H'.");
    end
    
    expectedPathologies = {'t1d','t2d','pbh','healthy'};

    valid = any(validatestring(pathology,expectedPathologies));
    if(~valid)
        error("Must be 't1d', 't2d', 'pbh', or 'healthy'.");
    end
    
    
end