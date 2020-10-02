function [mcmc] = setNewMCMCParameters(pHat,mcmc)
% setNewParameters Function that compute the conditional standard deviation 
% for all the estimated parameters (as described in MCMC in practice,
% Gilks, pp. 123).
% mcmc = setNewMCMCParameters(pHat,mcmc) returns a structure containing the
% hyperparameters of the MCMC simulation. In particular, it has mcmc.std
% updated.
% * Inputs:
%   - pHat: is a structure containing the parameter draws.
%   - mcmc: is a structure containing the MCMC hyperparameters.
% * Output:
%   - mcmc: is the updated structure containing the MCMC hyperparameters
%   having new mcmc.std.

    %Construct a matrix on the parameters draws
    P = [];
    for p = 1:length(mcmc.std)
        P(:,p) = pHat.(mcmc.thetaNames{p});
    end
    
    
    for p = 1:length(mcmc.std)
        Pp = P(:,p);
        Pmp = P;
        Pmp(:,p) = [];
        theta = Pmp\Pp; 
        Pphat = Pmp*theta; %regress the p-th component given the others
        mcmc.std(p) = 2.3*sqrt((Pp-Pphat)'*(Pp-Pphat)/(mcmc.n-2)); %compute the conditional std (by 2.3 times)
        mcmc.std = min([mcmc.std; mcmc.stdMax]); %limit std to a maximum value to avoid dangerous artifacts
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