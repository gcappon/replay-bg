function zones = clarke(y,yp)
% function  zones = clarke(y,yp)
% Performs Clarke Error Grid Analysis
%
% Inputs: 
%   - y: a vector containing the reference glucose values (mg/dl);
%   - yp: a vector containing the glucose values (mg/dl) to compare with y.
% 
% Output: 
%   - zones: a structure containing the results of the CEGA. 
%
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    % Error checking
    if nargin == 0
     error('clarke:Inputs','There are no inputs.')
    end
    if length(yp) ~= length(y)
        error('clarke:Inputs','Vectors y and yp must be the same length.')
    end
    if (max(y) > 400) || (max(yp) > 400) || (min(y) < 0) || (min(yp) < 0)
        warning('clarke:Inputs','Vectors y and yp are not in the physiological range of glucose (<400mg/dl).')
    end

    n = length(y);
    total = zeros(5,1);                        

    for i=1:n
        if (yp(i) <= 70 && y(i) <= 70) || (yp(i) <= 1.2*y(i) && yp(i) >= 0.8*y(i))
            total(1) = total(1) + 1;            % Zone A
        else
            if ( (y(i) >= 180) && (yp(i) <= 70) ) || ( (y(i) <= 70) && yp(i) >= 180 )
                total(5) = total(5) + 1;        % Zone E
            else
                if ((y(i) >= 70 && y(i) <= 290) && (yp(i) >= y(i) + 110) ) || ((y(i) >= 130 && y(i) <= 180)&& (yp(i) <= (7/5)*y(i) - 182))
                    total(3) = total(3) + 1;    % Zone C
                else
                    if ((y(i) >= 240) && ((yp(i) >= 70) && (yp(i) <= 180))) || (y(i) <= 175/3 && (yp(i) <= 180) && (yp(i) >= 70)) || ((y(i) >= 175/3 && y(i) <= 70) && (yp(i) >= (6/5)*y(i)))
                        total(4) = total(4) + 1;% Zone D
                    else
                        total(2) = total(2) + 1;% Zone B
                    end                         % End of 4th if
                end                             % End of 3rd if
            end                                 % End of 2nd if
        end                                     % End of 1st if
    end                                         % End of for loop
    percentage = (total./n)*100;

    zones.A = percentage(1);
    zones.B = percentage(2);
    zones.C = percentage(3);
    zones.D = percentage(4);
    zones.E = percentage(5);

end