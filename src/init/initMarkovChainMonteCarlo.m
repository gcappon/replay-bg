function mcmc = initMarkovChainMonteCarlo(maxETAPerMCMCRun,maxMCMCIterations,maxMCMCRuns, maxMCMCRunsWithMaxETA)
% function  initMarkovChainMonteCarlo(maxETAPerMCMCRun,maxMCMCIterations,maxMCMCRuns, maxMCMCRunsWithMaxETA)
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
    
    %It works on in silico data (for bolus and CHO modfications) NOT FOR BASAL MODIFICATIONS
    mcmc.thetaNames = {'SG','SI','Gb','p2','kempt','kabs'}; %names of the parameters to identify
    mcmc.std = [5e-4, 1e-6, 1, 1e-3, 5e-3, 1e-3]; %initial guess for the SD of each parameter
    theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.18, 0.012]; %initial guess for the parameter values...
    mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3, 1e-2, 5e-3]; %initial guess for the SD of each parameter
    mcmc.stdMin = [0, 0, 0, 0, 0, 0]; %minimum allowed SD of each parameter
    
    %It works on in silico data (for bolus and CHO modfications) NEEDS TO BE TESTED FOR BASAL MODIFICATIONS"
    mcmc.thetaNames = {'SG','SI','Gb','p2','kempt','kabs','r1','r2'}; %names of the parameters to identify
    mcmc.std = [5e-4, 1e-6, 1, 1e-3, 5e-3, 1e-3, 1e-3, 1e-3]; %initial guess of the SD of each parameter
    theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.18, 0.012, 0.8, 1.44]; %initial guess of the parameter values...
    mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3, 1e-2, 5e-3, 1e-2, 1e-2]; %initial guess of the SD of each parameter
    mcmc.stdMin = [0, 0, 0, 0, 0, 0, 0, 0]; %minimum allowed SD of each parameter
    
    %REAL DATA - seems OK (wait for Giulia's assessment)
    mcmc.thetaNames = {'SG','SI','Gb','p2','kempt','kabs','r1','r2','beta'}; %names of the parameters to identify
    mcmc.std = [5e-4, 1e-6, 1, 1e-3, 5e-3, 1e-3, 1e-3, 1e-3,0.5]; %initial guess of the SD of each parameter
    theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.18, 0.012, 0.8, 1.44,5]; %initial guess of the parameter values...
    mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3, 1e-2, 5e-3, 1e-2, 1e-2,1]; %initial guess of the SD of each parameter
    mcmc.stdMin = [0, 0, 0, 0, 0, 0, 0, 0, 0.25]; %minimum allowed SD of each parameter
    
    %REAL DATA - seems OK (wait for Giulia's assessment)
    mcmc.thetaNames = {'SG','SI','Gb','p2','kempt','kabs','r1','r2','beta','Xpb'}; %names of the parameters to identify
    mcmc.std = [5e-4, 1e-6, 1, 1e-3, 5e-3, 1e-3, 1e-3, 1e-3,1, 1e-4]; %initial guess of the SD of each parameter
    theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.18, 0.012, 0.8, 1.44,15,0]; %initial guess of the parameter values
    mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3, 1e-2, 5e-3, 1e-2, 1e-2,1, 5e-4]; %maximum allowed SD of each parameter
    mcmc.stdMin = [0, 0, 0, 0, 0, 0, 0, 0, 0.25, 0]; %minimum allowed SD of each parameter
    
    %Randomize the initial guess of the parameter values
    mcmc.theta0 = theta0+randn(1,length(mcmc.thetaNames)).*(0.2*theta0); %...plus a random variation
    while(sum(mcmc.theta0>=0) < length(mcmc.theta0)) %cant be negative, if so resample
        mcmc.theta0 = theta0+randn(1,length(mcmc.thetaNames)).*(0.1*theta0);
    end %while

    %Assign the block of each parameter (for Single-Component M-H)
    mcmc.parBlock = [1, 1, 1, 2, 2, 2]; 
    mcmc.parBlock = [1, 1, 1, 2, 2, 2, 3, 3]; 
    mcmc.parBlock = [1, 1, 1, 2, 2, 2, 3, 3, 4];
    mcmc.parBlock = [1, 1, 1, 2, 2, 2, 3, 3, 4, 5];

    %Set the number of blocks
    mcmc.nBlocks = max(mcmc.parBlock);

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
    mcmc.policyTheta0 = "mean"; 
    
    %Set the Bayesian estimator used to compute the parameter point estimates
    mcmc.estimator = "map"; 
    
    %Set the number of parameters to be identified
    mcmc.nPar = length(mcmc.thetaNames);
    
    %Do you want to lightly smooth training data? (it could help)
    mcmc.filter = 0; 
    
    %Do you want to save the intermediate mcmc chains 
    mcmc.saveChains = 1; 
    
end
