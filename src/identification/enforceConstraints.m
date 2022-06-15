function modelParameters = enforceConstraints(modelParameters, model, environment)
% function  enforceConstraints(modelParameters, model, environment)
% Function that enforces the model parameter values constraints.
%
% Inputs:
%   - modelParameters: a struct containing the model parameters;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Output:
%   - modelParameters: a struct containing the model parameters (complying
%   to constraints).
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
                        
                        % kabs <= kempt
                        if(modelParameters.kabs > modelParameters.kempt)
                            modelParameters.kabs = modelParameters.kempt;
                        end
                        
                        % ka2 <= kd
                        if(modelParameters.ka2>modelParameters.kd)
                            modelParameters.ka2 = modelParameters.kd;
                        end
                        
                        % kempt = kgri
                        modelParameters.kgri = modelParameters.kempt;

                    case 'multi-meal'
                        
                        % kabsB <= kempt
                        if(modelParameters.kabsB > modelParameters.kempt)
                            modelParameters.kabsB = modelParameters.kempt;
                        end
                        
                        % kabsL <= kempt
                        if(modelParameters.kabsL > modelParameters.kempt)
                            modelParameters.kabsL = modelParameters.kempt;
                        end
                        
                        % kabsD <= kempt
                        if(modelParameters.kabsD > modelParameters.kempt)
                            modelParameters.kabsD = modelParameters.kempt;
                        end
                        
                        % kabsS <= kempt
                        if(modelParameters.kabsS > modelParameters.kempt)
                            modelParameters.kabsS = modelParameters.kempt;
                        end
                        
                        % kabsH <= kempt
                        if(modelParameters.kabsH > modelParameters.kempt)
                            modelParameters.kabsH = modelParameters.kempt;
                        end
                        
                        % ka2 <= kd
                        if(modelParameters.ka2>modelParameters.kd)
                            modelParameters.ka2 = modelParameters.kd;
                        end
                        
                        % kgri = kempt
                        modelParameters.kgri = modelParameters.kempt;
                        

                end
            
        case 't2d'
            %TODO: implement t2d model
        case 'pbh'
            %TODO: implement pbh model
        case 'healthy'
            %TODO: implement healthy model
    end
 end