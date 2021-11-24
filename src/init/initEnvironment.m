function environment = initEnvironment(modality,saveName,saveSuffix,scenario, plotMode,enableLog,verbose)
% function  initEnvironment(modality,saveName,saveSuffix,scenario, plotMode,enableLog,verbose)
% Initializes the 'environment' core variable.
%
% Inputs:
%   - modality: a vector of characters that specifies if the function will 
%   be used to identify the ReplayBG model on the given data or to replay 
%   the scenario specified by the given data;
%   - saveName: a vector of characters used to label, thus identify, each 
%   output file and result;
%   - saveSuffix: a vector of characters to be attached as suffix to the 
%   resulting output files' name;
%   - scenario: a vector of characters that specifies if the scenario is
%   single-meal or multi-meal;
%   - plotMode: a numerical flag that specifies whether to show the plot 
%   of the results or not;
%   - enableLog: (optional, default: 1) a numerical flag that specifies
%   whether to log the output of ReplayBG not;
%   - verbose: a numerical flag that specifies the verbosity of ReplayBG.
% Output:
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    if(verbose)
        fprintf('Setting up the environment...');
        tic;
    end 
    
    %Set the absolute path of the ReplayBG tool
    p = fileparts(which('replayBG'));
    p = regexp(p,filesep,'split');
    if(isunix)
        environment.replayBGPath = fullfile(filesep,p{1:end-2});
    else
        environment.replayBGPath = fullfile(p{1:end-2});
    end
    
    %Create the results subfolders if they do not exist
    if(~exist(fullfile(environment.replayBGPath,'results'),'dir'))
        mkdir(fullfile(environment.replayBGPath,'results'));
    end
    if(~exist(fullfile(environment.replayBGPath,'results','distributions'),'dir'))
        mkdir(fullfile(environment.replayBGPath,'results','distributions'));
    end
    if(~exist(fullfile(environment.replayBGPath,'results','logs'),'dir'))
        mkdir(fullfile(environment.replayBGPath,'results','logs'));
    end
    if(~exist(fullfile(environment.replayBGPath,'results','mcmcChains'),'dir'))
        mkdir(fullfile(environment.replayBGPath,'results','mcmcChains'));
    end
    if(~exist(fullfile(environment.replayBGPath,'results','modelParameters'),'dir'))
        mkdir(fullfile(environment.replayBGPath,'results','modelParameters'));
    end
    if(~exist(fullfile(environment.replayBGPath,'results','workspaces'),'dir'))
        mkdir(fullfile(environment.replayBGPath,'results','workspaces'));
    end
    
    %Store the ReplayBG modality
    environment.modality = modality; 
    
    %Set the save name
    environment.saveName = saveName;
    
    %Set the save suffix
    if(strcmp(saveSuffix,''))
        environment.saveSuffix = saveSuffix;
    else
        environment.saveSuffix = ['_' saveSuffix];
    end
    
    %Create the log file associated to the simulation.
    environment.enableLog = enableLog; % if 0 do not log 
    
    if(environment.enableLog)
        environment.logFile = fullfile(environment.replayBGPath,'results','logs',[datestr(datetime('now'),'yyyy-mm-dd_hh:MM') '_' environment.modality '_' environment.saveName environment.saveSuffix '.txt']);
        if(exist(environment.logFile,'file'))
            delete(environment.logFile);
        end % if log
    else
        environment.logFile = [];
    end
    
    %Single-meal or multi-meal scenario?
    environment.scenario = scenario;
    
    %Set the verbosity
    environment.plotMode = plotMode; % if 0 do not plot 
    environment.verbose = verbose; % if 0 do not display stuff
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
end
