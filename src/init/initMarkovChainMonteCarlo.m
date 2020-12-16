function mcmc = initMarkovChainMonteCarlo(maxETAPerMCMCRun,maxMCMCIterations,maxMCMCRuns, maxMCMCRunsWithMaxETA, MCMCTheta0Policy, bayesianEstimator,preFilterData, saveChains, adaptiveSCMH)
% function  initMarkovChainMonteCarlo(maxETAPerMCMCRun,maxMCMCIterations,maxMCMCRuns, maxMCMCRunsWithMaxETA, MCMCTheta0Policy)
% Initializes the 'mcmc' core variable. 
%
% Inputs:
%   - maxETAPerMCMCRun: a number that specifies the maximum time in hours 
%   allowed for each MCMC run; 
%   - maxMCMCIterations: an integer that specifies the maximum number of 
%   iterations for each MCMC run; 
%   - maxMCMCRuns: an integer that specifies the maximum number of MCMC 
%   runs; 
%   - maxMCMCRunsWithMaxETA: an integer that specifies the maximum number 
%   of MCMC runs having maximum ETA; 
%   - MCMCTheta0Policy: a vector of characters defining the policy used by
%   the MCMC procedure to set the initial MCMC chains values;
%   - bayesianEstimator: a vector of characters defining which Bayesian
%   estimator to use to obtain a point estimate of model parameters;
%   - preFilterData: a numerical flag that specifies whether to filter the 
%   glucose data before performing the model identification;
%   - saveChains: a numerical flag that specifies whether to save the 
%   resulting mcmc chains in dedicated files (one for each MCMC run) for 
%   future analysis or not.
%   - adaptiveSCMH: a numerical flag that specifies whether to make the 
%   Single Components Metropolis Hastings algorithm adaptive or 
%   non-adaptive. 
% Outputs:
%   - mcmc: a structure that contains the hyperparameters of the MCMC
%   identification procedure.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    SG0 = 2.5e-2;
    SI0 = 10.35e-4/1.45;
    Gb0 = 119.13;
    p20 = 0.012;
    kempt0 = 0.18;
    kabs0 = 0.012;
    ka20 = 0.014;
    kd0 = 0.026;
    beta0 = 15;
    
    mcmc.thetaNames = {'SG','SI','Gb','p2','kempt','kabs','kd','ka2'}; %names of the parameters to identify
    mcmc.std = [5e-4, 1e-6, 1, 1e-3, 5e-3, 1e-3, 1e-3, 1e-3]; %initial guess for the SD of each parameter
    mcmc.theta0 = [SG0, SI0, Gb0, p20, kempt0, kabs0, kd0, ka20]; %initial guess for the parameter values...
    mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3, 1e-2, 5e-3, 5e-3, 5e-3]*inf; %initial guess for the SD of each parameter
    mcmc.stdMin = [0, 0, 0, 0, 0, 0, 0, 0]; %minimum allowed SD of each parameter
    
    %It works on pete-jacobs simulator data
    %mcmc.thetaNames = {'SG','SI','p2','kempt','kabs'}; %names of the parameters to identify
    %mcmc.std = [5e-4, 1e-6, 1e-3, 5e-3, 1e-3]; %initial guess for the SD of each parameter
    %mcmc.theta0 = [SG0, SI0, p20, kempt0, kabs0]; %initial guess for the parameter values...
    %mcmc.stdMax = [1e-3, 1e-5, 2e-3, 1e-2, 5e-3]; %initial guess for the SD of each parameter
    %mcmc.stdMin = [0, 0, 0, 0, 0]; %minimum allowed SD of each parameter
    
    %REAL DATA 
    mcmc.thetaNames = {'SG','SI','Gb','p2','kempt','kabs','kd','ka2','beta'}; %names of the parameters to identify
    mcmc.std = [5e-4, 1e-6, 1, 1e-3, 5e-3, 1e-3, 1e-3, 1e-3, 0.5]; %initial guess for the SD of each parameter
    mcmc.theta0 = [SG0, SI0, Gb0, p20, kempt0, kabs0, kd0, ka20, beta0]; %initial guess for the parameter values...
    mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3, 1e-2, 5e-3, 5e-3, 5e-3, 1]*inf; %initial guess for the SD of each parameter
    mcmc.stdMin = [0, 0, 0, 0, 0, 0, 0, 0, 0.25]; %minimum allowed SD of each parameter
    

    %Assign the block of each parameter (for Single-Component M-H)
    mcmc.parBlock = [1, 1, 1, 2, 2, 2, 3, 3]; 
    %mcmc.parBlock = [1, 1, 1, 2, 2]; 
    mcmc.parBlock = [1, 1, 1, 2, 2, 2, 3, 3, 2]; 
    
    %Set the number of blocks
    mcmc.nBlocks = max(mcmc.parBlock);

    %Initialize the covariance matrix
    for b = 1:mcmc.nBlocks
        mcmc.covar{b} = diag(mcmc.std(mcmc.parBlock == b).^2);
    end

    %Parameters of the Raftery-Lewis criterion
    mcmc.raftLewQ = 0.025; 
    mcmc.raftLewR = 0.0125;
    mcmc.raftLewS = 0.95;
    mcmc.raftLewNmin = fix(norminv((mcmc.raftLewS+1)/2)^2*(1-mcmc.raftLewQ)*mcmc.raftLewQ/mcmc.raftLewR^2+1);

    %Set the limits 
    mcmc.maxETAPerMCMCRun = maxETAPerMCMCRun; 
    mcmc.maxMCMCIterations = maxMCMCIterations;
    mcmc.maxMCMCRuns = maxMCMCRuns;
    mcmc.maxMCMCRunsWithMaxETA = maxMCMCRunsWithMaxETA;
    
    %Set the policy for choosing the theta0 for the next run can be {'initial', 'last', 'mean'} 
    mcmc.MCMCTheta0Policy = MCMCTheta0Policy; 
    
    %Set the Bayesian estimator used to compute the parameter point estimates
    mcmc.bayesianEstimator = bayesianEstimator; 
    
    %Set the number of parameters to be identified
    mcmc.nPar = length(mcmc.thetaNames);
    
    %Do you want to lightly filter training data? (it could help)
    mcmc.preFilterData = preFilterData; 
    
    %Do you want to save the intermediate mcmc chains 
    mcmc.saveChains = saveChains; 
    
    %Do you want to make Metroplis Adaptive?
    mcmc.adaptiveSCMH = adaptiveSCMH;
    mcmc.adaptationFrequency = 1000;
    
    
    
end
