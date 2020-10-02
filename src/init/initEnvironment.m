function environment = initEnvironment(modality,saveName,plotMode,verbose)
% initEnvironment Function that initialize the environment parameters.
% environment = initEnvironment(saveName,plotWhileIdentifying,verbose) returns a structure containing the
% environment parameters.
% * Inputs:             
%   - saveName: is an array of char defining a label to be attached to each output file of ReplayBG.
%   - plotWhileIdentifying: is a flag defining whether to visualize the
%   identification plots during the identification procedure or not.
%   - verbose: is a flag defining the verbosity of ReplayBG.
% * Output:
%   - environment: is a structure containing the simulation the
%   environment parameters.

    warning off %shuts up the warning messages 
    
    p = fileparts(which('identifyReplayBGModel'));
    p = regexp(p,filesep,'split');
    environment.replayBGPath = fullfile(filesep,p{1:end-2});
    
    environment.modality = modality; 
    environment.saveName = saveName;
    
    %Create the log file associated to the simulation.
    environment.logFile = fullfile(environment.replayBGPath,'results','logs',[datestr(datetime('now'),'yyyy-mm-dd_hh:MM') '_' environment.modality '_' environment.saveName '.txt']);
    if(exist(environment.logFile,'file'))
        delete(environment.logFile);
    end % if log
    
    environment.plotMode = plotMode; % if 0 do not plot 
    environment.verbose = verbose;
    
end
