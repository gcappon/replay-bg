function mcmc = initMarkovChainMonteCarlo(maxETAPerMCMCRun,maxMCMCIterations,maxMCMCRuns, maxMCMCRunsWithMaxETA, MCMCTheta0Policy, bayesianEstimator,preFilterData, saveChains, adaptiveSCMH,environment,model)
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
%   non-adaptive;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG;
%   - model: a structure that contains general parameters of the
%   physiological model.
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
    
    %Type 1 diabetes initial conditions
    
    switch(model.pathology)
        case 't1d'
            
            switch(environment.scenario)
                case 'single-meal'
                    SG0 = 2.5e-2;
                    SI0 = 10.35e-4/1.45;
                    Gb0 = 119.13;
                    p20 = 0.012;
                    kempt0 = 0.18;
                    kabs0 = 0.012;
                    ka20 = 0.014;
                    kd0 = 0.026;
                    beta0 = 15;

                    %MCMC vectors assignment
                    mcmc.thetaNames = {'SG','SI','Gb','p2','kempt','kabs','kd','ka2','beta'}; %names of the parameters to identify
                    mcmc.std = [5e-4, 1e-6, 1, 1e-3, 5e-3, 1e-3, 1e-3, 1e-3, 0.5]; %initial guess for the SD of each parameter
                    mcmc.theta0 = [SG0, SI0, Gb0, p20, kempt0, kabs0, kd0, ka20, beta0]; %initial guess for the parameter values...
                    mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3, 1e-2, 5e-3, 5e-3, 5e-3, 1]*inf; %initial guess for the SD of each parameter
                    mcmc.stdMin = [0, 0, 0, 0, 0, 0, 0, 0, 0.25]; %minimum allowed SD of each parameter
                    
                    %Assign the block of each parameter (for Single-Component M-H)
                    mcmc.parBlock = [1, 1, 1, 2, 2, 2, 3, 3, 2]; 
    
                case 'multi-meal'
                    SG0 = 2.5e-2;
                    SIB0 = 10.35e-4/1.45;
                    SIL0 = 10.35e-4/1.45;
                    SID0 = 10.35e-4/1.45;
                    Gb0 = 119.13;
                    p20 = 0.012;
                    kempt0 = 0.18;
                    kabsB0 = 0.012;
                    kabsL0 = 0.012;
                    kabsD0 = 0.012;
                    kabsS0 = 0.012;
                    kabsH0 = 0.012;
                    ka20 = 0.014;
                    kd0 = 0.026;
                    betaB0 = 15;
                    betaL0 = 15;
                    betaD0 = 15;
                    betaS0 = 15;
                    betaH0 = 0;

                    %MCMC vectors assignment
                    mcmc.thetaNames = {'SG','SIB','SIL','SID','Gb','p2',...
                        'kempt','kabsB','kabsL','kabsD','kabsS','kabsH',...
                        'kd','ka2',...
                        'betaB','betaL','betaD','betaS'}; %names of the parameters to identify
                    mcmc.std = [5e-4, 1e-6, 1e-6, 1e-6, 1, 1e-3,...
                        5e-3, 1e-3, 1e-3, 1e-3, 1e-3, 1e-3,...
                        1e-3, 1e-3,...
                        0.5, 0.5, 0.5, 0.5]; %initial guess for the SD of each parameter
                    mcmc.theta0 = [SG0, SIB0, SIL0, SID0, Gb0, p20,...
                        kempt0, kabsB0, kabsL0, kabsD0, kabsS0, kabsH0,...
                        kd0, ka20,...
                        betaB0,betaL0,betaD0,betaS0]; %initial guess for the parameter values...
                    mcmc.stdMax = [1e-3, 1e-5, 1e-5, 1e-5, 2, 2e-3,...
                        1e-2, 5e-3, 5e-3, 5e-3, 5e-3, 5e-3,...
                        5e-3, 5e-3,...
                        1, 1, 1, 1]*inf; %initial guess for the SD of each parameter
                    mcmc.stdMin = [0, 0, 0, 0, 0, 0,...
                        0, 0, 0, 0, 0, 0,...
                        0, 0,...
                        0.25, 0.25, 0.25, 0.25]; %minimum allowed SD of each parameter
                    
                    %Assign the block of each parameter (for Single-Component M-H)
                    mcmc.parBlock = [1, 1, 1, 1, 1, 2,...
                        2, 2, 2, 2, 2, 2,...
                        3, 3,...
                        4, 4, 4, 4]; 
            end
            
        case 't2d'
            %TODO: implement t2d model
        case 'pbh'
            %TODO: implement pbh model
        case 'healthy'
            %TODO: implement healthy model
    end
    
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
    switch(environment.scenario)
        case 'single-meal'
            mcmc.adaptationFrequency = 1000;
        case 'multi-meal'
            mcmc.adaptationFrequency = 2000;
    end
    
end
