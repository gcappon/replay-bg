function parametersOK = checkCopulaExtractions(draws, mcmc, modelParameters, model, environment)
% function  checkCopulaExtractions(draws, mcmc, model, environment)
% Checks if the parameters extracted by the copula at the end of the
% identification are ok.
%
% Input:
%   - draws: a structure which contains the parameters extracted by the
%   copula and the downsapled MCMC chains;
%   - mcmc: a structure that contains the hyperparameters of the MCMC
%   identification procedure;
%   - modelParameters: is a struct containing all the identified model 
%   parameters (point estimates);
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Output:
%   - parametersOK: a boolean vector which tells if a given parameter
%   vector is ok or not.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2021 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    switch(model.pathology)
            case 't1d'

                switch(environment.scenario)
                    case 'single-meal'
                        %Glucose-insulin submodel parameters
                        limits.SI = @(x,mP) logical((x*mP.VG>0).*((x*mP.VG)<1e-2));
                        limits.SG = @(x,mP) logical(x>0).*(x<1);
                        limits.p2 = @(x,mP) logical(x>0).*(x<1);
                        limits.Gb = @(x,mP) logical(x>=70).*(x<=180);
                        limits.r1 = @(x,mP) logical(x>0);
                        limits.r2 = @(x,mP) logical(x>0);
                        limits.alpha = @(x,mP) logical(x>0);

                        %Subcutaneous insulin absorption submodel
                        limits.VI = @(x,mP) logical(x>0);
                        limits.ke = @(x,mP) logical(x>0).*(x<1);
                        limits.kd = @(x,mP) logical(x>0).*(x<1);
                        limits.ka1 = @(x,mP) logical(x>0).*(x<1);
                        limits.ka2 = @(x,mP) logical(x>0).*(x<1);
                        limits.tau = @(x,mP) logical(x>=0).*(x<=45);

                        %Oral glucose absorption submodel
                        limits.kabs = @(x1,x2,mP) logical(x1>0).*(x1<1).*(x1<x2); %x1 = kabs, x2 = kempt
                        limits.kempt = @(x,mP) logical(x>0).*(x<1);
                        limits.beta = @(x,mP) logical(x>=0).*(x<=60);
                        
                        %Exercise submodel (from Alkhateeb et al, PLoS One,
                        %2021 - Supplementary Material)
                        limits.e1 = @(x,mP) logical(x>=0).*(x<=4);
                        limits.e2 = @(x,mP) logical(x>=0).*(x<=4);
                        
                        parametersOK = true(mcmc.tbe,1);
                        for p = 1:length(mcmc.thetaNames)
                            if(nargin(limits.(mcmc.thetaNames{p}) == 2))
                                pOK = limits.(mcmc.thetaNames{p})(draws.(mcmc.thetaNames{p}).samples,modelParameters);
                                parametersOK = parametersOK & pOK';
                            else
                                if(strcmp(mcmc.thetaNames{p},'ka2'))
                                    
                                    if(any(strcmp(mcmc.thetaNames,'kd')))
                                        pOK = limits.(mcmc.thetaNames{p})(draws.(mcmc.thetaNames{p}).samples,draws.kd.samples,modelParameters);
                                    else
                                        pOK = limits.(mcmc.thetaNames{p})(draws.(mcmc.thetaNames{p}).samples,modelParameters.kd*ones(length(draws.(mcmc.thetaNames{p}).samples),1),modelParameters);
                                    end
                                    parametersOK = parametersOK & pOK';
                                else
                                    if(any(strcmp(mcmc.thetaNames,'kempt')))
                                        pOK = limits.(mcmc.thetaNames{p})(draws.(mcmc.thetaNames{p}).samples,draws.kempt.samples,modelParameters);
                                    else
                                        pOK = limits.(mcmc.thetaNames{p})(draws.(mcmc.thetaNames{p}).samples,modelParameters.kempt*ones(length(draws.(mcmc.thetaNames{p}).samples),1),modelParameters);
                                    end
                                    parametersOK = parametersOK & pOK';
                                end
                            end
                        end

                    case 'multi-meal'
                        %Glucose-insulin submodel parameters
                        limits.SIB = @(x,mP) logical((x*mP.VG>0).*((x*mP.VG)<1e-2));
                        limits.SIL = @(x,mP) logical((x*mP.VG>0).*((x*mP.VG)<1e-2));
                        limits.SID = @(x,mP) logical((x*mP.VG>0).*((x*mP.VG)<1e-2));
                        limits.SG = @(x,mP) logical(x>0).*(x<1);
                        limits.p2 = @(x,mP) logical(x>0).*(x<1);
                        limits.Gb = @(x,mP) logical(x>=70).*(x<=180);
                        limits.Gbdawn = @(x,mP) logical(x>=70).*(x<=250);
                        limits.r1 = @(x,mP) logical(x>0);
                        limits.r2 = @(x,mP) logical(x>0);
                        limits.alpha = @(x,mP) logical(x>0);

                        %Subcutaneous insulin absorption submodel
                        limits.VI = @(x,mP) logical(x>0);
                        limits.ke = @(x,mP) logical(x>0).*(x<1);
                        limits.kd = @(x,mP) logical(x>0).*(x<1);
                        limits.ka1 = @(x,mP) logical(x>0).*(x<1);
                        limits.ka2 = @(x1,x2,mP) logical(x1>0).*(x1<1).*(x1<=x2); %x1 = ka2, x2 = kd
                        limits.tau = @(x,mP) logical(x>=0).*(x<=45);

                        %Oral glucose absorption submodel
                        limits.kabsB = @(x1,x2,mP) logical(x1>0).*(x1<1).*(x1<x2); %x1 = kabsB, x2 = kempt
                        limits.kabsL = @(x1,x2,mP) logical(x1>0).*(x1<1).*(x1<x2); %x1 = kabsL, x2 = kempt
                        limits.kabsD = @(x1,x2,mP) logical(x1>0).*(x1<1).*(x1<x2); %x1 = kabsD, x2 = kempt
                        limits.kabsS = @(x1,x2,mP) logical(x1>0).*(x1<1).*(x1<x2); %x1 = kabsS, x2 = kempt
                        limits.kabsH = @(x1,x2,mP) logical(x1>0).*(x1<1).*(x1<x2); %x1 = kabsH, x2 = kempt
                        limits.kempt = @(x,mP) logical(x>0).*(x<1);
                        limits.betaB = @(x,mP) logical(x>=0).*(x<=60);
                        limits.betaL = @(x,mP) logical(x>=0).*(x<=60);
                        limits.betaD = @(x,mP) logical(x>=0).*(x<=60);
                        limits.betaS = @(x,mP) logical(x>=0).*(x<=60);
                        limits.betaH = @(x,mP) logical(x>=0).*(x<=60);
                        
                        %Exercise submodel (from Alkhateeb et al, PLoS One,
                        %2021 - Supplementary Material)
                        limits.e1 = @(x,mP) logical(x>=0).*(x<=4);
                        limits.e2 = @(x,mP) logical(x>=0).*(x<=4);
                        
                        parametersOK = true(mcmc.tbe,1);
                        for p = 1:length(mcmc.thetaNames)
                            %mcmc.thetaNames{p}
                            if(nargin(limits.(mcmc.thetaNames{p})) == 2)
                                pOK = limits.(mcmc.thetaNames{p})(draws.(mcmc.thetaNames{p}).samples,modelParameters);
                                parametersOK = parametersOK & pOK';
                            else
                                if(strcmp(mcmc.thetaNames{p},'ka2'))
                                    
                                    if(any(strcmp(mcmc.thetaNames,'kd')))
                                        pOK = limits.(mcmc.thetaNames{p})(draws.(mcmc.thetaNames{p}).samples,draws.kd.samples,modelParameters);
                                    else
                                        pOK = limits.(mcmc.thetaNames{p})(draws.(mcmc.thetaNames{p}).samples,modelParameters.kd*ones(length(draws.(mcmc.thetaNames{p}).samples),1),modelParameters);
                                    end
                                    parametersOK = parametersOK & pOK';
                                else
                                    if(any(strcmp(mcmc.thetaNames,'kempt')))
                                        pOK = limits.(mcmc.thetaNames{p})(draws.(mcmc.thetaNames{p}).samples,draws.kempt.samples,modelParameters);
                                    else
                                        pOK = limits.(mcmc.thetaNames{p})(draws.(mcmc.thetaNames{p}).samples,modelParameters.kempt*ones(length(draws.(mcmc.thetaNames{p}).samples),1),modelParameters);
                                    end
                                    parametersOK = parametersOK & pOK';
                                end
                            end
                            %draws.(mcmc.thetaNames{p}).samples(~pOK)
                        end
                        
                end
            
        case 't2d'
            %TODO: implement t2d model
        case 'pbh'
            %TODO: implement pbh model
        case 'healthy'
            %TODO: implement pbh model
    end
    
 end