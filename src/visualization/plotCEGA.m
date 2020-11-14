function plotCEGA(y,yp,printFigure)
% function  plotCEGA(y,yp,printFigure)
% Plots the Clake error grid.
%
% Inputs:
%   - y: a vector containing the true glucose data; 
%   - yp: a vector containing the simulated glucose data (mg/dl);
%   - printFigure: a numerical flag specifying whether to print the
%   plot on a file or not.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    h = figure;
    plot(y,yp,'ko','MarkerSize',4,'MarkerFaceColor','k','MarkerEdgeColor','k');
    xlabel('Reference Concentration [mg/dl]');
    ylabel ('Predicted Concentration [mg/dl]');
    title('Clarke''s Error Grid Analysis');
    set(gca,'XLim',[0 400]);
    set(gca,'YLim',[0 400]);
    axis square
    hold on
    plot([0 400],[0 400],'k:')                  % Theoretical 45 degrees regression line
    plot([0 175/3],[70 70],'k-')
    % plot([175/3 320],[70 400],'k-')
    plot([175/3 400/1.2],[70 400],'k-')         % replace 320 with 400/1.2 because 100*(400 - 400/1.2)/(400/1.2) =  20% error
    plot([70 70],[84 400],'k-')
    plot([0 70],[180 180],'k-')
    plot([70 290],[180 400],'k-')               % Corrected upper B-C boundary
    % plot([70 70],[0 175/3],'k-')
    plot([70 70],[0 56],'k-')                   % replace 175.3 with 56 because 100*abs(56-70)/70) = 20% error
    % plot([70 400],[175/3 320],'k-')
    plot([70 400],[56 320],'k-')
    plot([180 180],[0 70],'k-')
    plot([180 400],[70 70],'k-')
    plot([240 240],[70 180],'k-')
    plot([240 400],[180 180],'k-')
    plot([130 180],[0 70],'k-')                 % Lower B-C boundary slope OK
    text(30,20,'A','FontSize',12);
    text(30,150,'D','FontSize',12);
    text(30,380,'E','FontSize',12);
    text(150,380,'C','FontSize',12);
    text(160,20,'C','FontSize',12);
    text(380,20,'E','FontSize',12);
    text(380,120,'D','FontSize',12);
    text(380,260,'B','FontSize',12);
    text(280,380,'B','FontSize',12);
    set(h, 'color', 'white');                   % sets the color to white 
    % Specify window units
    set(h, 'units', 'inches')
    % Change figure and paper size (Fixed to 3x3 in)
    set(h, 'Position', [0.1 0.1 3 3])
    set(h, 'PaperPosition', [0.1 0.1 3 3])
    if printFigure
        % Saves plot as a Enhanced MetaFile
        print(h,'-dmeta','Clarke_EGA');           
        % Saves plot as PNG at 300 dpi
        print(h, '-dpng', 'Clarke_EGA', '-r300'); 
    end
    
end