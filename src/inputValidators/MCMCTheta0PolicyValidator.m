function valid = MCMCTheta0PolicyValidator(MCMCTheta0Policy,modality)
% function  MCMCTheta0PolicyValidator(MCMCTheta0Policy,modality)
% Validates the input parameter 'MCMCTheta0Policy'.
%
% Inputs:
%   - MCMCTheta0Policy;
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

    expectedMCMCTheta0Policy = {'initial','mean','last'};

    valid = any(validatestring(MCMCTheta0Policy,expectedMCMCTheta0Policy));
    if(~valid)
        error("Must be 'initial' or 'mean' or 'last'.");
    end
    
    if(strcmp(modality,'replay'))
        warning("You are trying to set the parameter 'MCMCTheta0Policy' while using the 'replay' modality. It won't be used.");
    end
    
end