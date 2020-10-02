function [G, x] = computeGlicemia(mP,data,model)
% computeGlicemia Function that compute the CGM trace (for the MCMC procedure)
% G = computeGlicemia(mP,basal,bolus,meal,simulation) returns the CGM trace (for the MCMC procedure)
% given the current model parameters.
% * Inputs:
%   - mP: is a structure containing the model parameters.
%   - basal: is a vector defining the basal insulin value for each time
%   step.
%   - bolus: is a vector defining the bolus insulin value for each time
%   step.
%   - meal: is a vector defining the meal intake value for each time
%   step.
%   - simulation: is a structure defining the simulation parameters.
% * Output:
%   - G: is a vector containing the glycemic trace.
    
    %Set the simulation length
    TSTEPS = model.TIDSTEPS;
        
    %Initial conditions
    x = zeros(model.nx,TSTEPS);
    x(1:9,1) = [data.Glucose(1);...                                                                            %G(0)
          mP.Xpb; ...                                                                                          %X(0)
          mP.u2ss/(mP.ka1+mP.kd); ...                                                                          %Isc1(0)                              
          (mP.kd/mP.ka2)*mP.u2ss/(mP.ka1+mP.kd); ...                                                           %Isc2(0)
          (mP.ka1/mP.ke)*mP.u2ss/(mP.ka1+mP.kd) + (mP.ka2/mP.ke)*(mP.kd/mP.ka2)*mP.u2ss/(mP.ka1+mP.kd); ...    %Ip(0) 
          0; ...                                                                                               %Qsto1(0)
          0; ...                                                                                               %Qsto2(0)
          mP.Qgutb; ...                                                                                        %Qgut(0)
          data.Glucose(1)];                                                                                    %IG(0)                                                                                    
    
    G = zeros(1,TSTEPS);
    switch(model.glucoseModel)
        case 'IG' 
            G(1) = x(9,1); %y(k) = IG(k)
        case 'BG'
            G(1) = x(1,1); %y(k) = BG(k)
    end
    
    %initialize inputs (basal, bolus, meal) with the initial condition (meal
    %intake + its bolus) and put them 
    [bolus, basal] = insulinSetup(data,model,mP);
    [meal] = mealSetup(data,model,mP);
    bolusDelay = floor(mP.tau/model.TS); 
    mealDelay = floor(mP.beta);
    meal = [zeros(mealDelay,1); meal; zeros(bolusDelay,1)];
    bolus = [zeros(bolusDelay,1); bolus];
    basal = [basal; ones(bolusDelay,1)*basal(1)];
    
    
    for k = 2:TSTEPS
        
        %Integration step
        x(:,k) = modelStep(x(:,k-1),basal(k) + bolus(k), meal(k), mP, x(:,k), model); %metto gli input all'istante k per dato che uso Eulero all'indietro
        
        switch(model.glucoseModel)
            case 'IG' 
                G(k) = x(9,k); %y(k) = IG(k)
            case 'BG'
                G(k) = x(1,k); %y(k) = BG(k)
        end
        
        %TODO: HERE INSERT DSS
        
    end %for k
    
end %function computeGlicemia