function risk = computeHypoglycemicRisk(G,mP)
% function  computeHypoglycemicRisk(G,mP)
% Computes the hypoglycemic risk as in Visentin et al., JDST, 2018.
%
% Inputs:
%   - G: the glucose concentration;
%   - mP: is a struct containing the model parameters.
% Outputs:
%   - risk: the hypoglycemic risk.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    %Setting the risk model threshold
    Gth = 60;
    
    %UVa/Padova model v2017
    %risk = 10*(log(G)^mP.r2 - log(mP.Gb)^mP.r2)^2*(G<mP.Gb & G>=Gth) + ...
    %    10*(log(Gth)^mP.r2 - log(mP.Gb)^mP.r2)^2*(G<Gth);
    
    %(Modified) UVa/Padova model v2017
    risk = 10*(log(G)^mP.r2 - log(119.13)^mP.r2)^2*(G<119.13 & G>=Gth) + ...
        10*(log(Gth)^mP.r2 - log(119.13)^mP.r2)^2*(G<Gth);
end