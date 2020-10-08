function valid = saveChainsValidator(saveChains,modality)
% function  saveChainsValidator(saveChains,modality)
% Validates the input parameter 'saveChains'.
%
% Inputs:
%   - saveChains;
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


    valid = saveChains == 0 || saveChains == 1;
    if(~valid)
        error("Must be 0 or 1.");
    end
    
    if(strcmp(modality,'replay'))
        disp("WARNING: you are trying to set the parameter 'saveChains' while using the 'replay' modality. It won't be used.");
    end
    
end