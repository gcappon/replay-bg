function [mcmc] = setNewMCMCParameters(pHat,mcmc)
% function  setNewMCMCParameters(pHat,mcmc)
% Computes the conditional standard deviation for all the estimated 
% parameters (as described in MCMC in practice, Gilks, pp. 123) and sets 
% the new values of mcmc.std and mcmc.theta0.
%
% Inputs:
%   - pHat: is a structure containing the parameter chians after a run of
%   the MCMC;
%   - mcmc: a structure that contains the hyperparameters of the MCMC
%   identification procedure.
% Output:
%   - mcmc: the updated structure that contains the hyperparameters 
%   of the MCMC identification procedure.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    %Construct a matrix on the parameters draws
    P = [];
    for p = 1:length(mcmc.std)
        P(:,p) = pHat.(mcmc.thetaNames{p});
    end
    
    
    for p = 1:length(mcmc.std)
        
        %Set the new mcmc.std
        Pp = P(:,p);
        Pmp = P;
        Pmp(:,p) = [];
        theta = Pmp\Pp; 
        Pphat = Pmp*theta; %regress the p-th component given the others
        mcmc.std(p) = 2.3*sqrt((Pp-Pphat)'*(Pp-Pphat)/(mcmc.n-2)); %compute the conditional std (by 2.3 times)
        mcmc.std = min([mcmc.std; mcmc.stdMax]); %limit std to a maximum value to avoid dangerous artifacts
        mcmc.std = max([mcmc.std; mcmc.stdMin]); %limit std to a maximum value to avoid dangerous artifacts
        
        %Set the new mcmc.theta0
        switch(mcmc.policyTheta0)
            case 'initial'
                mcmc.theta0(p) = mcmc.theta0(p);
            case 'mean'
                mcmc.theta0(p) = mean(Pp); %new starting point: mean
            case 'last'
                mcmc.theta0(p) = Pp(end); %new starting point: last value
        end
    end
    
end