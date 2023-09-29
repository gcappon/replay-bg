function sensors = initSensors(cgmModel, model, environment)
% function  initSensors(cgmModel, model, environment)
% Initializes the 'sensors' core variable.
%
% Inputs:
%   - cgmModel: a vector of characters that specifies the glucose;
%   - model: a structure that contains general parameters of the
%   physiological model;
%   - environment: a structure that contains general parameters to be used
%   by ReplayBG.
% Outputs:
%   - sensors: a structure that contains general parameters of the
%   sensors models.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    if(environment.verbose)
            fprintf('Setting up the sensors hyperparameters...');
            tic;
    end
    
    
    sensors.cgm.TS = model.YTS; %sample time of the cgm sensor. It is set equal to the sample time of the measurements.
    
    sensors.cgm.model = cgmModel; %cgm model selection {'CGM','BG','IG'}. If BG or IG are selected, CGM measure will be the noise-free
                                  %BG or IG state at the current time.
    
    %If the CGM model is selected, then set its parameters
    if(strcmp(sensors.cgm.model,'CGM'))
     
        %Load  Mean vector and covariance matrix of the parameter vector as
        %defined in Vettoretti et al., Sensors, 2019
        sensors.cgm.mu = [0.94228767821000314341972625697963, 0.0049398821141803427384187052950892, -0.0005848748565491275084801681138913, 6.382602204050874306062723917421, 1.2604070417357611244568715846981, -0.4022228938823663169088717950217, 3.2516360856114072674927228945307];
        sensors.cgm.sigma = [0.013245827952891258902368143424155,  -0.0039513025350735725416129184850433,  0.00031276743283791636970891936186945,   0.15717912467153988265167186000326,  0.0026876560011614997885986966252858,  -0.0028904633825263671524641306831427, -0.0031801707001874032418320403792222
                             -0.0039513025350735725416129184850433,   0.0018527975980744701509778105119608, -0.00015580332205794781403294935184789,  -0.10288007693621757654423021222101, -0.0013902327543057948350258001823931,   0.0011591852212130876378232136048041, -0.0027284927011686846420879248853453
                             0.00031276743283791636970891936186945, -0.00015580332205794781403294935184789, 0.000013745962164724157000697882247131, 0.0080685863688738888865881193623864, 0.00012074974710011031125631020266553, -0.00010042135441622312822841645019167, 0.00011130290033867137325027107941366
                                0.15717912467153988265167186000326,    -0.10288007693621757654423021222101,   0.0080685863688738888865881193623864,    29.005838188852990811028575990349,    0.12408344051778112671069465022811,    -0.10193644943826736526393261783596,    0.60075381294204155402383094042307
                              0.0026876560011614997885986966252858,  -0.0013902327543057948350258001823931,  0.00012074974710011031125631020266553,   0.12408344051778112671069465022811,    0.02079352674233487727195601735275,   -0.018431109170459980539646949182497,  -0.015721846813032722134373386779771
                             -0.0028904633825263671524641306831427,   0.0011591852212130876378232136048041, -0.00010042135441622312822841645019167,  -0.10193644943826736526393261783596,  -0.018431109170459980539646949182497,    0.018700867933453400870913441167431,    0.01552333576829629385729347745837
                             -0.0031801707001874032418320403792222,  -0.0027284927011686846420879248853453,  0.00011130290033867137325027107941366,   0.60075381294204155402383094042307,  -0.015721846813032722134373386779771,     0.01552333576829629385729347745837,    0.72356838038463477946748980684788];
        
        sensors.cgm.f = 0.90; % Modulation factor of the covariance of the parameter vector not to generate too extreme realizations of parameter vector
        sensors.cgm.sigma = sensors.cgm.sigma*sensors.cgm.f; % Modulate the covariance matrix
        
        sensors.cgm.maxOutputNoiseSD = 10; %Maximum allowed output noise SD (mg/dl)
        sensors.cgm.toll = 0.02; %Tollerance for model stability check

    end
    
    if(environment.verbose)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end

    sensors.ekm1 = 0;
    sensors.ekm2 = 0;

end