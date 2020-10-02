function xk = modelStep(xkm1,B,CHO,mP,xk,model)
% model Function that simulates a step of the model.
% xk = model(xkm1, ukm1, modelParameters) returns a vector containg the
% model state at time k given the state and input at time k-1.
% * Inputs:
%   - xkm1: is a vector containing the model state at time k-1.
%   - ukm1: is a vector containing the input value at time k-1.
%   - modelParameters: is a struct containing the model parameters.
% * Output:
%   - xk: is a vector containing the model state at time k.
    
    G = xkm1(1); %mg/dL
    %Gss = Gb (assuming Xss = 0 and Rass = 0)
    X = xkm1(2); %1/min
    %Xss = 0 (over-basal insulin action)
    Isc1 = xkm1(3); %mU/kg
    %Isc1ss = u2ss / ( ka1 + kd )
    Isc2 = xkm1(4); %mU/kg
    %Isc2ss = kd / ka2 * u2ss / ( ka1 + kd )
    Ip = xkm1(5); %mU/kg
    %Ipss = ka1 / ke * u2ss / ( ka1 + kd ) + ka2 / ke * kd / ka2 * u2ss / ( ka1 + kd ) 
    Qsto1 = xkm1(6); %mg/kg
    %Qsto1ss = 0
    Qsto2 = xkm1(7); %mg/kg
    %Qsto2ss = 0
    Qgut = xkm1(8); %mg/kg
    %Qgutss = 0
    IG = xkm1(9); %mg/dL  
    %IGss = Gb
    
    Ipb = (mP.ka1/mP.ke)*(mP.u2ss)/(mP.ka1+mP.kd) + (mP.ka2/mP.ke)*(mP.kd/mP.ka2)*(mP.u2ss)/(mP.ka1+mP.kd); %from eq. 5 steady-state    

    
    Gth = 60;
    risk = abs(exp((G/mP.Gb).^mP.r2)-exp(1))*(G<mP.Gb & G>Gth) + abs(exp((Gth/mP.Gb).^mP.r2)-exp(1))*(G<=Gth);
    if(isnan(risk))
        risk = 0;
    end
    %risk = 0;
    
    %factorHyper = 0.3;
    %if(G>180)
    %    SI = SI*(1-factorHyper*(1-exp(-(G-180)/8)));
    %end
        
    
    xk(6) = (Qsto1 + model.TS*CHO)/(1+model.TS*mP.kgri);
    xk(7) = (Qsto2 + model.TS*mP.kgri*xk(6))/(1+model.TS*mP.kempt);
    xk(8) = (Qgut + model.TS*mP.kempt*xk(7))/(1+model.TS*mP.kabs);
    
    Ra = mP.f*mP.kabs*xk(8);
    
    xk(3) = (Isc1 + model.TS*B)/(1+model.TS*(mP.ka1+mP.kd));
    xk(4) = (Isc2 + model.TS*mP.kd*xk(3))/(1+model.TS*mP.ka2);
    xk(5) = (Ip + model.TS*(mP.ka1*xk(3)+mP.ka2*xk(4)))/(1+model.TS*mP.ke);
    
    xk(2) = (X + model.TS*mP.p2*(mP.SI/mP.VI)*(xk(5)-Ipb))/(1+model.TS*mP.p2);
    
    xk(1) = (G + model.TS*(mP.SG*mP.Gb+Ra/mP.VG))/(1+model.TS*(mP.SG + (1+mP.r1*risk)*xk(2)));
    xk(9) = (IG + (model.TS/mP.alpha)*xk(1))/(1+model.TS/mP.alpha);
    
    
   
end %function model