function mcmc = initMarkovChainMonteCarlo(maxETAPerMCMCRun,maxMCMCIterations,maxMCMCRuns, maxMCMCRunsWithMaxETA)
% initMarkovChainMonteCarlo Function that initialize the parameters needed 
% for the MCMC algorithm.
% mcmc = initMarkovChainMonteCarlo(maxETAPerMCMCRun,maxMCMCIterations,maxMCMCRuns) returns a structure containing the
% parameters needed by the MCMC algorithm.
% * Input:
%   - maxETAPerMCMCRun: the maximum running time [hours] allowed to
%   each MCMC run.
%   - maxMCMCIterations: the maximum number of iterations allowed to each
%   MCMC run.
%   - maxMCMCRuns: the maximum number of allowed MCMC runs.
% * Output:
%   - mcmc: is a structure containing the parameters needed by the MCMC
%   algorithm.
    
    mcmc.thetaNames = {'SG','SI','Gb','p2','kabs','kempt'}; %names of the parameters to identify
    mcmc.std = [5e-4, 1e-6, 1, 1e-3, 1e-3,5e-3]; %initial guess for the SD of each parameter
    theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.012,0.18]; %initial guess for the parameter values...
    mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3, 5e-3,1e-2]; %initial guess for the SD of each parameter
    
    %mcmc.thetaNames = {'SG','SI','Gb','p2','ka1','ka2','kempt','kabs','Xpb','Qgutb','beta'}; %names of the parameters to identify
    %mcmc.std = [5e-4, 1e-6, 1, 1e-3,  1e-4,1e-4,5e-3, 1e-3,1e-4,5,0.5]; %initial guess for the SD of each parameter
    %theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.0034, 0.014,0.18, 0.012,0,0,0]; %initial guess for the parameter values...
    %mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3,  1e-3,1e-3, 1e-2, 5e-3,5e-4,20,1]; %initial guess for the SD of each parameter
    
    %mcmc.thetaNames = {'SG','SI','Gb','p2','kd','ka2','kempt','kabs','Xpb','beta'}; %names of the parameters to identify
    %mcmc.std = [5e-4, 1e-6, 1, 1e-3,  5e-4,1e-4,5e-3, 1e-3,1e-4,0.5]; %initial guess for the SD of each parameter
    %theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.028, 0.014,0.18, 0.012,0,0]; %initial guess for the parameter values...
    %mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3,  5e-3 ,1e-3, 1e-2, 5e-3,5e-4,1]; %initial guess for the SD of each parameter
    
    %mcmc.thetaNames = {'SG','SI','Gb','p2','kd','ka2','kempt','kabs','Xpb'}; %names of the parameters to identify
    %mcmc.std = [5e-4, 1e-6, 1, 1e-3,  5e-4,1e-4,5e-3, 1e-3,1e-4]; %initial guess for the SD of each parameter
    %theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.028, 0.014,0.18, 0.012,0]; %initial guess for the parameter values...
    %mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3,  5e-3 ,1e-3, 1e-2, 5e-3,5e-4]; %initial guess for the SD of each parameter
    
    mcmc.thetaNames = {'SG','SI','Gb','p2','kd','ka2','kempt','kabs'}; %names of the parameters to identify
    mcmc.std = [5e-4, 1e-6, 1, 1e-3,  5e-4,1e-4,5e-3, 1e-3]; %initial guess for the SD of each parameter
    theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.028, 0.014,0.18, 0.012]; %initial guess for the parameter values...
    mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3,  5e-3 ,1e-3, 1e-2, 5e-3]; %initial guess for the SD of each parameter
    
    mcmc.thetaNames = {'SG','SI','Gb','p2','kd','ka2','kempt','kabs','r1','r2'}; %names of the parameters to identify
    mcmc.std = [5e-4, 1e-6, 1, 1e-3,  5e-4,1e-4,5e-3, 1e-3, 1e-3, 1e-3]; %initial guess for the SD of each parameter
    theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.028, 0.014,0.18, 0.012, 0.8, 1.44]; %initial guess for the parameter values...
    mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3,  5e-3 ,1e-3, 1e-2, 5e-3, 1e-2, 1e-2]; %initial guess for the SD of each parameter
    
    
    %Test 4
    %mcmc.thetaNames = {'SG','SI','Gb','p2','kd','ka2','kempt','kabs','beta'}; %names of the parameters to identify
    %mcmc.std = [5e-4, 1e-6, 1, 1e-3,  5e-4,1e-4,5e-3, 1e-3, 0.5]; %initial guess for the SD of each parameter
    %theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.028, 0.014,0.18, 0.012, 0]; %initial guess for the parameter values...
    %mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3,  5e-3 ,1e-3, 1e-2, 5e-3, 1]; %initial guess for the SD of each parameter
    
    %THIS WORKS WELL IN SILICO, NOT FOR BASAL MODIFICATIONS
    mcmc.thetaNames = {'SG','SI','Gb','p2','kempt','kabs'}; %names of the parameters to identify
    mcmc.std = [5e-4, 1e-6, 1, 1e-3, 5e-3, 1e-3]; %initial guess for the SD of each parameter
    theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.18, 0.012]; %initial guess for the parameter values...
    mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3, 1e-2, 5e-3]; %initial guess for the SD of each parameter
    
    %OK FOR IN SILICO AND ALSO BASAL MODIFICATIONS
    mcmc.thetaNames = {'SG','SI','Gb','p2','kempt','kabs','r1','r2'}; %names of the parameters to identify
    mcmc.std = [5e-4, 1e-6, 1, 1e-3, 5e-3, 1e-3, 1e-3, 1e-3]; %initial guess for the SD of each parameter
    theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.18, 0.012, 0.8, 1.44]; %initial guess for the parameter values...
    mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3, 1e-2, 5e-3, 1e-2, 1e-2]; %initial guess for the SD of each parameter
    
    %REAL DATA - OK
    mcmc.thetaNames = {'SG','SI','Gb','p2','kempt','kabs','r1','r2','beta'}; %names of the parameters to identify
    mcmc.std = [5e-4, 1e-6, 1, 1e-3, 5e-3, 1e-3, 1e-3, 1e-3,0.5]; %initial guess for the SD of each parameter
    theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.18, 0.012, 0.8, 1.44,5]; %initial guess for the parameter values...
    mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3, 1e-2, 5e-3, 1e-2, 1e-2,1]; %initial guess for the SD of each parameter
    
    mcmc.thetaNames = {'SG','SI','Gb','p2','kempt','kabs','r1','r2','beta','Xpb'}; %names of the parameters to identify
    mcmc.std = [5e-4, 1e-6, 1, 1e-3, 5e-3, 1e-3, 1e-3, 1e-3,1, 1e-4]; %initial guess for the SD of each parameter
    theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.18, 0.012, 0.8, 1.44,15,0]; %initial guess for the parameter values...
    mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3, 1e-2, 5e-3, 1e-2, 1e-2,1, 5e-4]; %initial guess for the SD of each parameter
    mcmc.stdMin = [0,0,0,0,0,0,0,0,0.25,0]; %initial guess for the SD of each parameter
    
    %mcmc.thetaNames = {'SG','SI','Gb','p2','kd','ka2','kempt','kabs','Qgutb','Xpb'}; %names of the parameters to identify
    %mcmc.std = [5e-4, 1e-6, 1, 1e-3,  5e-4,1e-4,5e-3, 1e-3, 5, 1e-4]; %initial guess for the SD of each parameter
    %theta0 = [1.7e-2, 2e-4, 120, 1e-2, 0.028, 0.014,0.18, 0.012, 0, 0]; %initial guess for the parameter values...
    %mcmc.stdMax = [1e-3, 1e-5, 2, 2e-3,  5e-3 ,1e-3, 1e-2, 5e-3, 20, 5e-4]; %initial guess for the SD of each parameter
    
    mcmc.theta0 = theta0+randn(1,length(mcmc.thetaNames)).*(0.2*theta0); %...plus a random variation
    while(sum(mcmc.theta0>=0) < length(mcmc.theta0)) %cant be negative, if so resample
        mcmc.theta0 = theta0+randn(1,length(mcmc.thetaNames)).*(0.1*theta0);
    end %while


    mcmc.parBlock = [1, 1, 1, 2, 2, 2]; %block assignment of each parameter 
    mcmc.parBlock = [1, 1, 1, 2, 2, 2, 3, 3]; %block assignment of each parameter 
    mcmc.parBlock = [1, 1, 1, 2, 2, 2, 3, 3, 4, 5]; %block assignment of each parameter 
    %mcmc.parBlock = [1, 1, 1, 2, 3, 3, 4, 4, 3]; %block assignment of each parameter 
    %mcmc.parBlock = [1, 1, 1, 2, 3, 3, 4, 4, 5, 5]; %block assignment of each parameter 
    mcmc.nBlocks = max(mcmc.parBlock); %number of blocks

    %Parameters of the Raftery-Lewis criterion
    mcmc.raftLewQ = 0.025; 
    mcmc.raftLewR = 0.0125;
    mcmc.raftLewS = 0.95;
    mcmc.raftLewNmin = fix(norminv((mcmc.raftLewS+1)/2)^2*(1-mcmc.raftLewQ)*mcmc.raftLewQ/mcmc.raftLewR^2+1);

    mcmc.maxETAPerMCMCRun = maxETAPerMCMCRun; %run ETA limit (in hours)
    mcmc.maxMCMCIterations = maxMCMCIterations; 
    mcmc.maxMCMCRuns = maxMCMCRuns; %maximum number of MCMC iterations
    mcmc.maxMCMCRunsWithMaxETA = maxMCMCRunsWithMaxETA; %maximum number of MCMC iterations having limitETA as ETA
    
    mcmc.policyTheta0 = "mean"; %policy for choosing the theta0 for the next run {initial, last, mean} 
    mcmc.estimator = "map"; %Bayesian estimator used to compute parameter estimates
    
    mcmc.nPar = length(mcmc.thetaNames); %number of parameters to be identified
    mcmc.filter = 0; %Do you want to lightly smooth training data? (it could help)
    mcmc.saveChains = 1; %Do you want to save the intermediate mcmc chains 
end
