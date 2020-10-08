function plotReplayBGResults(glucose,data,environment)
% function  plotReplayBGResults(glucose,data,enviroment)
% Plot the obtained glucose results against data.
%
% Inputs:
%   - glucose: a structure which contains the obtained glucose traces 
%   simulated via ReplayBG; 
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
    
    %Plot glucose data
    ax(1) = subplot(5,1,1:3);
    hp1(1) = plot(data.Time,data.glucose,'r-*','linewidth',2);
    hold on
    hp1(2) = plot(data.Time,glucose.median,'k-o','linewidth',2);
    a = area(data.Time, [glucose.ci5th (glucose.ci95th - glucose.ci5th)]);
    a(1).FaceAlpha = 0;
    a(1).EdgeAlpha = 0;
    a(2).FaceColor = [0 0 0];
    a(2).FaceAlpha = 0.2;
    hp1(3) = a(2);
    plot([data.Time(1) data.Time(end)],[70 70],'m--','linewidth',2);
    plot([data.Time(1) data.Time(end)],[180 180],'m--','linewidth',2);
    grid on
    ylabel('Glucose [mg/dl]','FontWeight','bold','FontSize',18);
    legend(hp1,'Glucose (data)','Replay Glucose (Median)', 'Replay Glucose (CI 5-95th)');
    title(['Replay results'],'fontsize',20);
    hold off
    
    %Plot CHO data
    ax(2) = subplot(514);
    hp2(1) = stem(data.Time, data.CHO,'^','linewidth',2,'color',[70,130,180]/255);
    hold on
    grid on
    ylabel('CHO (data) [g/min]','FontWeight','bold','FontSize',18);
    legend(hp2,'CHO');
    hold off
    
    %Plot insulin data
    ax(3) = subplot(515);
    hp3(1) = stem(data.Time,data.bolus,'^','linewidth',2,'color',[50,205,50]/255);
    hold on;
    hp3(2) = plot(data.Time, data.basal*60,'-','linewidth',2,'color',[0,0,0]/255);
    legend(hp3,'Bolus insulin (data) [U/min]','Basal insulin (data) [U/h]');
    ylabel('Insulin','FontWeight','bold','FontSize',18);
    grid on
    hold off
    
    %Link the plots 
    linkaxes(ax,'x');
    set(ax,'FontSize',15)
    
    if(environment.verbose && environment.plotMode)
        time = toc;
        fprintf(['DONE. (Elapsed time ' num2str(time/60) ' min)\n']);
    end
    
end