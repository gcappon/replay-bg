function pdssToReplayBG(Experiment,savePath,offset,cutTh)
% Run it to convert from PDSS's format to ReplayBG's
% * Input:
%   - Experiment: the pdss data;
%   - savePath: the path where to save the data in the replayBG format;
%   - offset: the time offset in hours (e.g., 6)
%   - cutTh: the number of hours of data to use (e.g., 12);
%
%Output:
% - data: a table containing CGM [mg/dL], insulin [U/min] and CHO [g/min], BW [kg].


    idxPats = 1:100; %ids of the virtual patients 
    Ts = 5; %sample time

    for p = idxPats
        disp(['Processing adult#' num2str(p) '...']);

            %set the time 
            time = (0:5:(cutTh*60 - Ts))';
            time = datetime(0,1,1,offset,time,0);

            %set the glucose 
            glucose = Experiment.SimResults.Glucose((offset*60+1):Ts:((offset+cutTh)*60),p);  % mg/dl      

            %set the CHO
            CHO = zeros(length(time),1);
            CHO1Min = Experiment.SimResults.MealIngested((offset*60+1):((offset+cutTh)*60),p) + Experiment.SimResults.HypoTreatment((offset*60+1):((offset+cutTh)*60),p);
            CHOTimes = find(CHO1Min>0);
            for c = 1:length(CHOTimes)
                idx = round(CHOTimes(c)/Ts);
                CHO(idx) = CHO(idx)+CHO1Min(CHOTimes(c))/Ts; % converted: g --> g/min
            end

            %set the bolus insulin
            bolus = zeros(length(time),1);
            bolus1Min = Experiment.SimResults.PumpInsulinBolus((offset*60+1):((offset+cutTh)*60),p);
            bolusTimes = find(bolus1Min>0);
            for b = 1:length(bolusTimes)
                idx = round(bolusTimes(b)/Ts);
                bolus(idx) = bolus(idx)+bolus1Min(bolusTimes(b))/Ts; % converted: U --> U/min
            end

            %set the basal insulin
            basal = Experiment.SimResults.PumpInsulinBasal((offset*60+1):Ts:((offset+cutTh)*60),p);

            %create the data timetable in the replayBG format
            data = array2timetable([glucose CHO basal bolus],'RowTimes',time,'VariableNames',{'glucose','CHO','basal','bolus'});

            %set the patient body weight
            BW = Experiment.SimResults.subj_info(p).subj_pars.BW; % kg

            %save the data
            save(fullfile(savePath,['patientData_pat' num2str(p)]),'data','BW');

    end

end