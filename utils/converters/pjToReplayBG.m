function pjToReplayBG(glucose,bolus,basal,meal,weights,savePath,offset,cutTh)
% function  pjToReplayBG(Experiment,savePath,offset,cutTh)
% Run it to convert from PeterJacobs' simulator format to ReplayBG's.
%
% Inputs:
%   - glucose, bolus, basal, meal: the pj data;
%   - savePath: the path where to save the data in the ReplayBG format;
%   - offset: the time offset in hours (e.g., 6)
%   - cutTh: the number of hours of data to use (e.g., 12).
% Output:
%   - data: a table containing CGM [mg/dL], insulin [U/min] and CHO 
%   [g/min], BW [kg].
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    idxPats = 1:99; %ids of the virtual patients 
    Ts = 5; %sample time

    for p = idxPats
        disp(['Processing adult#' num2str(p) '...']);

            %set the time 
            time = (0:5:(cutTh*60 - Ts))';
            time = datetime(0,1,1,offset,time,0);

            %set the glucose 
            BG = glucose(:,p);  % mg/dl      

            %set the CHO
            CHO = meal(:,p);

            %set the bolus insulin
            IB = bolus(:,p);

            %set the basal insulin
            Ib = basal(:,p);

            %create the data timetable in the replayBG format
            data = array2timetable([BG CHO Ib IB],'RowTimes',time,'VariableNames',{'glucose','CHO','basal','bolus'});

            %set the patient body weight
            BW = weights(p); % kg

            %save the data
            save(fullfile(savePath,['patientData_pat' num2str(p)]),'data','BW');

    end

end