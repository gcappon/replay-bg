function risk = computeHypoglycemicRisk(G,mP)
% function  computeHypoglycemicRisk(G,mP)
% Computes the hypoglycemic risk as in Visentin et al., JDST, 2018.
%
% Inputs:
%   - G: the glucose concentration;
%   - mP: is a struct containing the model parameters.
% Output:
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
    
    %Compute the risk
    risk = 10*(log(G)^mP.r2 - log(119.13)^mP.r2)^2*(G<119.13 & G>=Gth) + ...
        10*(log(Gth)^mP.r2 - log(119.13)^mP.r2)^2*(G<Gth);
    risk = abs(risk);
    
end