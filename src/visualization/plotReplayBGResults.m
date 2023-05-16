function plotReplayBGResults(cgm,glucose,insulinBolus, insulinBasal, CHO, hypotreatments, correctionBolus,vo2,data,environment)
% function  plotReplayBGResults(glucose,data,enviroment)
% Plot the obtained glucose results against data.
%
% Inputs:
%   - cgm: a structure which contains the obtained cgm traces 
%   simulated via ReplayBG; 
%   - glucose: a structure which contains the obtained glucose traces 
%   simulated via ReplayBG; 
%   - vo2: is a vector containing the normalized VO2 at each time when there is exercise (-).
%   - data: timetable which contains the data to be used by the tool;
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

    if(environment.verbose && environment.plotMode)
        tic;
        fprintf(['Plotting results...']);
    end
    
    figure;
    
    if(strcmp(environment.modality,'identification'))
        
        %Plot glucose data
        ax(1) = subplot(6,1,1:3);
        hp1(1) = plot(data.Time,data.glucose,'r-*','linewidth',2);
        hold on
        hp1(2) = plot(data.Time,cgm.median,'k-o','linewidth',2);
        hp1(3) = plot(data.Time,glucose.median(1:5:end),'b-o','linewidth',2);
        a = area(data.Time, [cgm.ci5th (cgm.ci95th - cgm.ci5th)]);
        a(1).FaceAlpha = 0;
        a(1).EdgeAlpha = 0;
        a(2).FaceColor = [0 0 0];
        a(2).FaceAlpha = 0.2;
        hp1(4) = a(2);
        a = area(data.Time, [glucose.ci5th(1:5:end) (glucose.ci95th(1:5:end) - glucose.ci5th(1:5:end))]);
        a(1).FaceAlpha = 0;
        a(1).EdgeAlpha = 0;
        a(2).FaceColor = [0 0 1];
        a(2).FaceAlpha = 0.2;
        hp1(5) = a(2);
        plot([data.Time(1) data.Time(end)],[70 70],'k--','linewidth',2);
        plot([data.Time(1) data.Time(end)],[180 180],'k--','linewidth',2);
        grid on
        ylabel('Glucose [mg/dl]','FontWeight','bold','FontSize',18);
        legend(hp1,'Glucose (data)','Replay CGM (Median)','Replay Glucose (Median)', 'Replay CGM (CI 5-95th)', 'Replay Glucose (CI 5-95th)');
        title(['Replay results'],'fontsize',20);
        hold off

        %Plot CHO data
        ax(2) = subplot(614);
        hp2(1) = stem(data.Time, data.CHO,'^','linewidth',2,'color',[70,130,180]/255);
        hold on
        grid on
        ylabel('CHO (data) [g/min]','FontWeight','bold','FontSize',18);
        legend(hp2,'CHO (data) [g/min]');
        hold off

        %Plot insulin data
        ax(3) = subplot(615);
        hp3(1) = stem(data.Time,data.bolus,'^','linewidth',2,'color',[50,205,50]/255);
        hold on;
        hp3(2) = plot(data.Time, data.basal*60,'-','linewidth',2,'color',[0,0,0]/255);
        legend(hp3,'Bolus insulin (data) [U/min]','Basal insulin (data) [U/h]');
        ylabel('Insulin (data)','FontWeight','bold','FontSize',18);
        grid on
        hold off
        
        %Plot exercise data
        ax(4) = subplot(616);
        hp4(1) = stem(data.Time,data.exercise,'^','linewidth',2,'color',[249, 115, 6]/255);
        legend(hp4,'VO2 (data) [-]');
        ylabel('VO2 (data)','FontWeight','bold','FontSize',18);
        grid on
        hold off
    end
    
    if(strcmp(environment.modality,'replay'))
        
        %Plot glucose data
        ax(1) = subplot(6,1,1:3);
        hold on
        hp1(1) = plot(data.Time,cgm.median,'k-o','linewidth',2);
        hp1(2) = plot(data.Time,glucose.median(1:5:end),'b-o','linewidth',2);
        a = area(data.Time, [cgm.ci5th (cgm.ci95th - cgm.ci5th)]);
        a(1).FaceAlpha = 0;
        a(1).EdgeAlpha = 0;
        a(2).FaceColor = [0 0 0];
        a(2).FaceAlpha = 0.2;
        hp1(3) = a(2);
        a = area(data.Time, [glucose.ci5th(1:5:end) (glucose.ci95th(1:5:end) - glucose.ci5th(1:5:end))]);
        a(1).FaceAlpha = 0;
        a(1).EdgeAlpha = 0;
        a(2).FaceColor = [0 0 1];
        a(2).FaceAlpha = 0.2;
        hp1(4) = a(2);
        plot([data.Time(1) data.Time(end)],[70 70],'k--','linewidth',2);
        plot([data.Time(1) data.Time(end)],[180 180],'k--','linewidth',2);
        grid on
        ylabel('Glucose [mg/dl]','FontWeight','bold','FontSize',18);
        legend(hp1,'Replay CGM (Median)','Replay Glucose (Median)', 'Replay CGM (CI 5-95th)', 'Replay Glucose (CI 5-95th)');
        title(['Replay results'],'fontsize',20);
        hold off
        
        %Get events-time
        eventTime = data.Time(1):minutes(1):data.Time(1)+minutes(height(data)*5-1);
        
        CHOEvents = sum(CHO.realizations')/1000;
        HTEvents = sum(hypotreatments.realizations')/1000;
        
        %Plot CHO data
        ax(2) = subplot(614);
        hp2(1) = stem(eventTime, CHOEvents,'^','linewidth',2,'color',[70,130,180]/255);
        hold on
        hp2(2) = stem(eventTime, HTEvents,'^','linewidth',2,'color',[0,204,204]/255);
        grid on
        legend(hp2,'CHO (replay) [g/min]','HT (replay) [g/min]');
        ylabel('CHO (replay) [g/min]','FontWeight','bold','FontSize',18);
        hold off

        %Plot insulin data
        
        BEvents = sum(insulinBolus.realizations')/1000;
        CBEvents = sum(correctionBolus.realizations')/1000;
        BRate = sum(insulinBasal.realizations'*60)/1000;
        
        ax(3) = subplot(615);
        hp3(1) = stem(eventTime, BEvents,'^','linewidth',2,'color',[50,205,50]/255);
        hold on;
        hp3(2) = stem(eventTime, CBEvents,'^','linewidth',2,'color',[51,102,0]/255);
        hp3(3) = plot(eventTime, BRate,'-*','linewidth',2,'color',[0,0,0]/255);
        legend(hp3,'Bolus insulin (replay) [U/min]','Correction bolus insulin (replay) [U/min]','Basal insulin (replay) [U/h]');
        ylabel('Insulin (replay)','FontWeight','bold','FontSize',18);
        grid on
        hold off
        
        %Plot exercise data
        ExEvents = sum(vo2.realizations')/1000;
        ax(4) = subplot(616);
        hp4(1) = stem(eventTime,ExEvents,'^','linewidth',2,'color',[249, 115, 6]/255);
        legend(hp4,'VO2 (replay) [-]');
        ylabel('VO2 (replay)','FontWeight','bold','FontSize',18);
        grid on
        hold off
        
    end
    
    %Link the plots 
    linkaxes(ax,'x');
    set(ax,'FontSize',15)
    
    if(environment.verbose && environment.plotMode)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
end