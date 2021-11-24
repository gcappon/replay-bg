clc
clear all
close all

% Load a simulation result from the 2017 Simulator
%load SIM_20210727_10days_nonadj

% Load error model parameters identified for Dexcom G6 sensor (paper Vettoretti et al. Sensors 2019)
load Dexcom_G6_model_parameters

rng(0)

%% Fit distribution of CGM error model parameters

% Get error model parameters identified on real sensors
n = length(data_error_model);

% Calibration error parameters
a0 = zeros(n,1);
a1 = zeros(n,1);
a2 = zeros(n,1);
b0 = zeros(n,1);
% Noise parameters
alpha1 = zeros(n,1);
alpha2 = zeros(n,1);
input_noise_sd = zeros(n,1);

for j = 1:n
    
    a0(j) = data_error_model(j).error_model_parameters.a0;
    a1(j) = data_error_model(j).error_model_parameters.a1;
    a2(j) = data_error_model(j).error_model_parameters.a2;
    b0(j) = data_error_model(j).error_model_parameters.b0;
    alpha1(j) = data_error_model(j).error_model_parameters.alpha1;
    alpha2(j) = data_error_model(j).error_model_parameters.alpha2;
    input_noise_sd(j) = data_error_model(j).error_model_parameters.input_noise_sd;
end
log_input_noise_sd = log(input_noise_sd);

% Parameters' matrix
P = [a0 a1 a2 b0 alpha1 alpha2 input_noise_sd];

% Store the prior
CGM_pars.calibration_prior.a0 = a0;
CGM_pars.calibration_prior.a1 = a1;
CGM_pars.calibration_prior.a2 = a2;
CGM_pars.calibration_prior.b0 = b0;
CGM_pars.calibration_prior.alpha1 = alpha1;
CGM_pars.calibration_prior.alpha2 = alpha2;
CGM_pars.calibration_prior.log_input_noise_sd = log_input_noise_sd;
CGM_pars.calibration_prior.prior = P;

% Mean vector and covariance matrix of the parameter vector
MU = mean(P);
Sigma = cov(P);

% Go to the space of cumulative density functions
a0_cdf = normcdf(a0,mean(a0),std(a0));
a1_cdf = normcdf(a1,mean(a1),std(a1));
a2_cdf = normcdf(a2,mean(a2),std(a2));
b0_cdf = normcdf(b0,mean(b0),std(b0));
alpha1_cdf = normcdf(alpha1,mean(alpha1),std(alpha1));
alpha2_cdf = normcdf(alpha2,mean(alpha2),std(alpha2));
log_input_noise_sd_cdf = normcdf(log_input_noise_sd,mean(log_input_noise_sd),std(log_input_noise_sd));

% Fit the copula
[Rho,nu] = copulafit('t',[a0_cdf a1_cdf a2_cdf b0_cdf alpha1_cdf alpha2_cdf log_input_noise_sd_cdf],'Method','ApproximateML');

% Store the copula parameters
CGM_pars.copula_parameters.Rho=Rho;
CGM_pars.copula_parameters.nu=nu;

%% Simulate CGM error

% Time vectors
t = Experiment.SimResults.sim_time;
t_cgm = t(1:5:end)/(24*60);

% Number of subjects 
N = length(Experiment.Population.SubjectList);
    
CGM_matrix = zeros(length(t_cgm),100);
IGs_matrix = zeros(length(t_cgm),100);

% Maximum output noise SD allowed
max_output_noise_sd = 10; % mg/dl

% Modulation factor of the covariance of the parameter vector not to generate too extreme realizations of parameter vector
f = 0.70;

% Modulate the covariance matrix
Sigma = Sigma*f;

for k = 1:100
    
    rng(k)
     
    % Sample a realization of model parameters, checking the stability of the AR(2) model of noise
    % Note: Maximum output SD of noise is set to max_output_noise_sd
    stable = 0; % Flag for stability of the AR(2) model
    output_noise_sd = 100;
    toll = 0.02;
    while ~ stable || output_noise_sd > max_output_noise_sd
        cgm_error_parameters(:,k) = mvnrnd(MU,Sigma,1)';
        stable = ((cgm_error_parameters(6,k)) >= -1) & ((cgm_error_parameters(6,k)) <= (1-abs(cgm_error_parameters(5,k))-toll));
        output_noise_sd = sqrt(cgm_error_parameters(7,k)^2 / (1- cgm_error_parameters(5,k)^2/(1-cgm_error_parameters(6,k)) - cgm_error_parameters(6,k)*(cgm_error_parameters(5,k)^2/(1-cgm_error_parameters(6,k))+cgm_error_parameters(6,k))));
    end
    out_noise_sd(k) = output_noise_sd;
     
    % Apply CGM error model
    IG = Experiment.SimResults.IG(:,k);
    
    % Subsample every 5 min
    IG_cgm = IG(1:5:end);
    
    % Apply calibration error
    IGs = (cgm_error_parameters(1,k) + cgm_error_parameters(2,k)*t_cgm + cgm_error_parameters(3,k)*t_cgm.^2).*IG_cgm + cgm_error_parameters(4,k);
    IGs_matrix(:,k) = IGs;
    
    % Generate noise
    z = randn(length(IGs),1);
    u = cgm_error_parameters(7,k)*z;
    y = filter(1,[1 -cgm_error_parameters(5,k) -cgm_error_parameters(6,k)],u);
    
    % Get final CGM
    CGM = IGs + y;
    CGM_matrix(:,k) = CGM;
    
    % Compute MARD
    ref = Experiment.SimResults.Glucose(1:5:end,k);
    MARD(k) = mean(abs(CGM - ref)./ref*100);
        
    % Plot IG vs CGM
    figure(1)
    plot(t_cgm,IG_cgm,'b-')
    hold on
    plot(t_cgm,IGs,'r-')
    plot(t_cgm,CGM,'g-')
    hold off
    legend('IG','CGM (calibration error only)','CGM (calibration error + noise)')
    xlabel('Time [days]')
    ylabel('Glucose concentration [mg/dl]')
    title(['Subject ' num2str(k) ', MARD = ', num2str(MARD(k)) ', out noise SD = ' num2str(out_noise_sd(k))])
    set(gca,'fontsize',14)
    box on
    grid on
    
    pause
    
end

% Save simulated data
save sim_CGM_data.mat t_cgm IGs_matrix CGM_matrix

% Plot MARD distribution
figure
bp = boxplot(MARD);
hold on
plot(1,mean(MARD),'sk','markerfacecolor','k')
set(bp,'linewidth',2)
title('MARD of simulated CGM traces')

%% Plot prior and simulated parameters

figure

subplot(2,3,1)
scatter(a0,b0)
hold on
scatter(cgm_error_parameters(1,:),cgm_error_parameters(4,:),'ro')
xlabel('a0')
ylabel('b0')
legend('Real parameters','Simulated parameters')
grid on
box on

subplot(2,3,2)
scatter(a0,a1)
hold on
scatter(cgm_error_parameters(1,:),cgm_error_parameters(2,:),'ro')
xlabel('a0')
ylabel('a1')
legend('Real parameters','Simulated parameters')
grid on
box on


subplot(2,3,3)
scatter(a1,a2)
hold on
scatter(cgm_error_parameters(2,:),cgm_error_parameters(3,:),'ro')
xlabel('a1')
ylabel('a2')
legend('Real parameters','Simulated parameters')
grid on
box on

subplot(2,3,4)
scatter(alpha1,alpha2)
hold on
scatter(cgm_error_parameters(5,:),cgm_error_parameters(6,:),'ro')
xlabel('alpha1')
ylabel('alpha2')
legend('Real parameters','Simulated parameters')
grid on
box on

subplot(2,3,5)
scatter(alpha1,input_noise_sd)
hold on
scatter(cgm_error_parameters(5,:),cgm_error_parameters(7,:),'ro')
xlabel('alpha1')
ylabel('input noise SD')
legend('Real parameters','Simulated parameters')
grid on
box on

subplot(2,3,6)
scatter(alpha2,input_noise_sd)
hold on
scatter(cgm_error_parameters(6,:),cgm_error_parameters(7,:),'ro')
xlabel('alpha2')
ylabel('input noise SD')
legend('Real parameters','Simulated parameters')
grid on
box on