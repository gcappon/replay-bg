function [mcmc] = setNewMCMCParameters(pHat,mcmc)
% function  setNewMCMCParameters(pHat,mcmc)
% Computes the emprical standard deviation for all the parameter to be 
% estimated and sets the new values of mcmc.covar and mcmc.theta0.
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

    
    %Set the new mcmc.covar
    for b = 1:mcmc.nBlocks
        blockIdxs = find(mcmc.parBlock == b);
        
        %Transform pHat to a matrix K
        K = zeros(length(pHat.(mcmc.thetaNames{1})),length(blockIdxs));
        for p = 1:length(blockIdxs)
            K(:,p) = pHat.(mcmc.thetaNames{blockIdxs(p)});
        end 
        
        %Set the new covariance matrix by discarding the parameter
        %covariances
        mcmc.covar{b} = diag(diag(cov(K)));
        
    end
    
    %Set the new mcmc.theta0
    for p = 1:length(mcmc.std)
        
        switch(mcmc.MCMCTheta0Policy)
            case 'initial'
                mcmc.theta0(p) = mcmc.theta0(p);
            case 'mean'
                mcmc.theta0(p) = mean(pHat.(mcmc.thetaNames{p})); %new starting point: mean
            case 'last'
                mcmc.theta0(p) = pHat.(mcmc.thetaNames{p})(end); %new starting point: last value
        end
        
    end
    
end