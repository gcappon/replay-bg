function [modelParameters, mcmc, draws] = setModelParameters(data,BW,environment,mcmc,model)

    if(strcmp(environment.modality,'identification'))
        
        if(environment.verbose)
            st = [mcmc.thetaNames{1}];
            for s = 2:mcmc.nPar
                st = [st ' ' mcmc.thetaNames{s}];
            end %for s
            tic;
            fprintf(['Identifying ReplayBG model using MCMC on ' st '...\n']);
        end

        %Identify model parameters (if modality: 'identification')
        [modelParameters, draws] = identifyModelParameters(data, BW, mcmc, model, environment);
        
    else
        
        if(environment.verbose)
            tic;
            fprintf(['Loading model parameters...']);
        end
        
        %Load the model parameters (if modality: 'replay')
        load(fullfile(environment.replayBGPath,'results','modelParameters',['modelParameters_' environment.saveName]));
        load(fullfile(environment.replayBGPath,'results','distributions',['distributions_' environment.saveName]));

    end
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
end