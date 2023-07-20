# ReplayBG

<img src="https://i.postimg.cc/gJn8Sy0X/replay-bg-logo.png" width="250" height="250">

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://github.com/gcappon/replay-bg/COPYING)
[![GitHub commit](https://img.shields.io/github/last-commit/gcappon/replay-bg)](https://github.com/gcappon/replay-bg/commits/master)

ReplayBG is a digital twin-based methodology to assess new strategies for type 1 diabetes management.

# Reference 

[G. Cappon, M. Vettoretti, G. Sparacino, S. Del Favero, A. Facchinetti, "ReplayBG: a digital twin-based methodology to identify a personalized model from type 1 diabetes data and simulate glucose concentrations to assess alternative therapies", IEEE Transactions on Biomedical Engineering, 2023, DOI: 10.1109/TBME.2023.3286856.](https://ieeexplore.ieee.org/document/10164140)

# Getting started 

## Installation 

Installation of ReplayBG can be easily performed by including the ReplayBG folder in the MATLAB® *PATH*. To do so: 

1. Download the latest ReplayBG release (e.g. `X.Y.Z`) from Github --> [here](https://github.com/gcappon/replay-bg/releases);

2. Unzip the downloaded archive and move the `replay-bg-X.Y.Z` folder to the desired location, for example `~/MATLAB/`;
3. Open MATLAB®;
4. To use the ReplayBG functions in the current MATLAB® session (or within a specific script), add `replay-bg-X.Y.Z` source folder and subfolders to the current MATLAB® *PATH* by executing in the command window (or at the top of the script)
```MATLAB
addpath(genpath('~/MATLAB/replay-bg-X.Y.Z/src'))
```
5. Enjoy!

## Step 1: Identification of ReplayBG model

The first step consists of fitting the ReplayBG model agaist data to capture the underlying physiological dynamics and estimate its parameter distributions via Markov Chain Monte Carlo (MCMC). This is possible by providing to the tool a portion of data recorded from people with type 1 diabetes consisting of glucose recordings, carbohydrate intakes, and bolus + basal insulin infusions. 

### The basics

ReplayBG has different level of flexibility and can perform step 1 differently according to the user preferences. The easiest way to do this is calling the `replayBG` function as: 

```MATLAB
replayBG('identification', data, BW, scenario, saveName);
```
where:

- `'identification'` specifies that the tool will be used to perform step 1, i.e., to identify the ReplayBG model on the given data
- `data` is a timetable which contains the data to be used by the tool. MUST contain a column `glucose` that contains the glucose measurements (in mg/dl), a column `basal` that contains the basal insulin data (in U/min), a column `bolus` that contains the bolus insulin data (in U/min), a column `CHO` that contains the CHO intake data (in g/min). `data` MUST be sampled on a homogeneous time grid and MUST, except for the `glucose` column, not contain Nan values. In case of `scenario = 'multi-meal'` `data` (see "Optional parameters" section below) MUST also contain a column of strings `choLabel` that contains for each non-zero value of the `CHO` column, a character that specifies the type of CHO intake (`'B'` for breakfast, `'L'` for lunch, `'D'` for dinner, `'S'` for snack, `'H'` for hypotreatment);
- `BW` is the patient body weight (kg);
- `scenario`: a vector of characters that specifies whether the given scenario refers to a single-meal scenario or a multi-meal scenario. Can be `'single-meal'` or `'multi-meal'`;
- `saveName` is a vector of characters used to label, thus identify, each output file and result of ReplayBG.

### Optional parameters

ReplayBG accepts optional parameters that can be used to fit user's preferences. These include: 

- `glucoseModel`: (optional, default: `'IG'`) a vector of characters that specifies the glucose model to use. Can be `'IG'` or `'BG'`;
- `cgmModel`: (optional, default: `'IG'`) a vector of characters that specifies the glucose model to use as cgm measurement. Can be `'CGM'`, `'IG'` or `'BG'`;
- `pathology`: (optional, default: `'t1d'`) a vector of characters that specifies the patient pathology. Can be `'t1d'`, `'t2d'`, `'pbh'`, `'healthy'`. Note that `'t2d'`, `'pbh'`, and `'healthy'` functionalities will be matter of future work and do not work at the moment;
- `scenario`: (optional, default: `'single-meal'`) a vector of characters that specifies whether the given scenario refers to a single-meal scenario or a multi-meal scenario. Can be `'single-meal'` or `'multi-meal'`;
- `sampleTime`: (optional, default: `5` (min)) an integer that specifies the `data` sample time;
- `seed`: (optional, default: `randi([1 1048576])`) an integer that specifies the random seed. For reproducibility;
- `maxETAPerMCMCRun`: (optional, default: `inf`) a number that specifies the maximum time in hours allowed for each MCMC run; 
- `maxMCMCIterations`: (optional, default: `inf`) an integer that specifies the maximum number of iterations for each MCMC run; 
- `maxMCMCRuns`: (optional, default: `inf`) an integer that specifies the maximum number of MCMC runs; 
- `maxMCMCRunsWithMaxETA`: (optional, default: `inf`) an integer that specifies the maximum number of MCMC runs having maximum ETA; 
- `adaptiveSCMH`: (optional, default: `1`) a numerical flag that specifies whether to make the Single Components Metropolis Hastings algorithm adaptive or non-adaptive. Can be `0` or `1`.
- `MCMCTheta0Policy`: (optional, default: `'mean'`) a vector of characters defining the policy used by the MCMC procedure to set the initial MCMC chain values. Can be `'mean'` or `'last'` or `'initial'`. Using `'mean'`, the mean value of the MCMC chain obtained from the last MCMC run will be set as initial MCMC chain value to be used in the next MCMC run. Using `'last'`, the last value of the MCMC chain obtained from the last MCMC run will be set as initial MCMC chain value to be used in the next MCMC run. Using `'initial'`, the same initial value will be used for every run of MCMC;
- `bayesianEstimator`: (optional, default: `'mean'`) a vector of characters defining which Bayesian estimator to use to obtain a point estimate of model parameters. Can be `'mean'` or `'map'`. Using `'mean'` the posterior mean estimater will be used. Using `'map'`, the marginalized maximum-a-posteriori estimator will be used. Note that this point estimate is not used during step 2 (it is just an output of the identification procedure);
- `preFilterData`: (optional, default: `0`) a numerical flag that specifies whether to filter the glucose data before performing the model identification or not. Can be `0` or `1`. This might help the identification procedure. Filtering is performed using a non-causal fourth-order Butterworth filter having `0.1*sampleTime` cut-off frequency;
- `saveChains`: (optional, default: `1`) a numerical flag that specifies whether to save the resulting mcmc chains in dedicated files (one for each MCMC run) for future analysis or not. Can be `0` or `1`;
- `saveSuffix`: (optional, default: `''`) a vector of char to be attached as suffix to the resulting output files' name;
- `plotMode`: (optional, default: `1`) a numerical flag that specifies whether to show the plot of the results or not. Can be `0` or `1`;
- `enableLog`: (optional, default: `1`) a numerical flag that specifies whether to log the output of ReplayBG not. Can be `0` or `1`;
- `verbose`: (optional, default: `1`) a numerical flag that specifies the verbosity of ReplayBG. Can be `0` or `1`.

### Suggested settings for step 1

Potentially, given the computational cost and the function of the parameter identification machinery (MCMC), this step can take forever. 

These are some suggested usage of ReaplyBG depending on your needs.

Please remember that the rationale is to identify a dataset "once and for all" (that is the heavy part of ReplayBG) and then play with the simulations (see "Step 2: Use of ReplayBG for simulation"). 

#### Use case 1: single-meal scenario

```MATLAB
replayBG( ...
  'identification', data, BW, 'single-meal', saveName, ...
  'maxETAPerMCMCRun', 6, ...
  'maxMCMCRuns', 4, ...
  'plotMode',1, ...
  'verbose',1, ...
  'seed', 1, ...
);
```

This will ensure a maximum running time of 24 hours (i.e., 4 x 6 hours). Consider increasing `maxETAPerMCMCRun` if warnings on MCMC convergence are raised by ReplayBG.
If you prefer to run ReplayBG "silently" or in a server infrastructure, set `plotMode` and `verbose` to `0`. 

#### Use case 2: multi-meal scenario

```MATLAB
replayBG( ...
  'identification', data, BW, 'multi-meal', saveName, ...
  'maxETAPerMCMCRun', 12, ...
  'maxMCMCRuns', 4, ...
  'plotMode',1, ...
  'verbose',1, ...
  'seed', 1, ...
);
```

This will ensure a maximum running time of 48 hours (i.e., 4 x 12 hours). Consider increasing `maxETAPerMCMCRun` if warnings on MCMC convergence are raised by ReplayBG.
If you prefer to run ReplayBG "silently" or in a server infrastructure, set `plotMode` and `verbose` to `0`. 

#### Use case 3: Playing around with ReplayBG

```MATLAB
replayBG( ...
  'identification', data, BW, scenario, saveName, ...
  'maxETAPerMCMCRun', 5/60, ...
  'maxMCMCRuns', 2, ...
  'plotMode',1, ...
  'verbose',1, ...
  'seed', 1, ...
);
```

This will ensure a maximum running time of 10 minutes (i.e., 2 x 5 minutes). 
This is useful to have a grasp of ReplayBG functioning. Since 5 minutes MCMC runs can lead to very short MCMC chains, it can happen (almost for sure) that some warnings will be raised by ReplayBG alerting that the MCMC did not converge.

## Step 2: Use of ReplayBG for simulation

The second step of ReplayBG consists of using the model parameters identified during step 1 and run simulations on the same time window but with different, altered model inputs (meal and insulin) to predict "what would have happened", in terms of glycemic time course, if such inputs would have been used instead of the orginal recorded ones. This basically allows to test the potential impact on glycemia of new insulin/carbohydrate algorithms for the management of type 1 diabetes. 

### The basics

As in step 1, ReplayBG has different level of flexibility and can perform step 2 differently according to the user preferences. The easiest way to do this is calling the `replayBG` function as: 

```MATLAB
replayBG('replay', data, BW, scenario, saveName);
```
where:

- `'replay'` specifies that the tool will be used to simulate the scenario specified by the given `data`;
- `data` is a timetable which contains the data to be used by the tool. MUST contain a column `glucose` that contains the glucose measurements (in mg/dl), a column `basal` that contains the basal insulin data (in U/min), a column `bolus` that contains the bolus insulin data (in U/min), a column `CHO` that contains the CHO intake data (in g/min). `data` MUST be sampled on a homogeneous time grid and MUST, except for the `glucose` column, not contain Nan values. In case of `scenario = 'multi-meal'` `data` (see "Optional parameters" section below) MUST also contain a column of strings `choLabel` that contains for each non-zero value of the `CHO` column, a character that specifies the type of CHO intake (`'B'` for breakfast, `'L'` for lunch, `'D'` for dinner, `'S'` for snack, `'H'` for hypotreatment);
- `BW` is the patient body weight (kg);
- `scenario`: a vector of characters that specifies whether the given scenario refers to a single-meal scenario or a multi-meal scenario. Can be `'single-meal'` or `'multi-meal'`;
- `saveName` is a vector of characters used to label, thus identify, each output file and result of ReplayBG. **To use specific model parameters identified in step 1, you MUST be the same corresponding `saveName` used during step 1.**

### Optional parameters

ReplayBG accepts optional parameters that can be used to fit user's preferences. These include: 

- `glucoseModel`: (optional, default: `'IG'`) a vector of characters that specifies the glucose model to use. Can be `'IG'` or `'BG'`;
- `cgmModel`: (optional, default: `'IG'`) a vector of characters that specifies the glucose model to use as cgm measurement. Can be `'CGM'`, `'IG'` or `'BG'`;
- `pathology`: (optional, default: `'t1d'`) a vector of characters that specifies the patient pathology. Can be `'t1d'`, `'t2d'`, `'pbh'`, `'healthy'`. Note that `'t2d'`, `'pbh'`, and `'healthy'` functionalities will be matter of future work and do not work at the moment;
- `sampleTime`: (optional, default: `5` (min)) an integer that specifies the `data` sample time;
- `bolusSource`: (optional, default: `'data'`) a vector of character defining whether to use, during replay, the insulin bolus data contained in the `data` timetable (if `data`), or the boluses generated by the bolus calculator implemented via the provided `bolusCalculatorHandler` function. Can be `'data'` or `'dss'`. It cannot be set if `modality` is `'identification'`;
- `basalSource`: (optional, default: `'data'`) a vector of character defining whether to use, during replay, the insulin basal data contained in the `data` timetable (if `data`), or the basal generated by the controller implemented via the provided `basalControllerHandler` function (if `dss`), or fixed to the average basal rate used during identification (if `'u2ss'`). Can be `'data'`, `'u2ss'`, or `'dss'`. It cannot be set if `modality` is `'identification'`;
- `choSource`: (optional, default: `'data'`) a vector of character defining whether to use, during replay, the CHO data contained in the `data` timetable (if `data`), or the CHO generated by the meal generator implemented via the provided `mealGeneratorHandler` function. Can be `'data'` or `'generated'`. It cannot be set if `modality` is `'identification'`;
- `CR`: (optional, default: 10) the carbohydrate-to-insulin ratio of the patient in g/U to be used by the integrated decision support system;
- `CF`: (optional, default: 40) the correction factor of the patient in mg/dl/U to be used by the integrated decision support system;
- `GT`: (optional, default: 120) the target glucose value in mg/dl to be used by the decsion support system modules;
- `bolusCalculatorHandler`: (optional, default: `'standardBolusCalculatorHandler'`) a vector of characters that specifies the name of the function handler that implements a bolus calculator to be used during the replay of a given scenario when `bolusSource` is `'dss'`. The function must have 2 output, i.e., the computed insulin bolus (U/min) and a structure containing the dss hyperparameter. The function must have 7 inputs, i.e., `G` (mg/dl) a vector as long the  simulation length containing all the simulated glucose concentrations up to `timeIndex` (the other values are nan), `mealAnnouncements` (g/min) a vector that contains the announced meal CHO intakes inputs for the whole replay simulation, `bolus` (U/min) a vector that contains the bolus insulin input for the whole replay simulation, `basal` (U/min) a vector that contains the basal insulin input for the whole replay simulation, `time` (datetime) a vector that contains the time istants of current replay simulation, `timeIndex` is a number that defines the current time istant in the replay simulation, `dss` a structure containing the dss hyperparameters and the optionally provided `bolusCalculatorHandlerParams` (`dss` is also echoed in the output to enable memory-like features). Vectors contain one value for each integration step. The default bolus calculator implemented by `standardBolusCalculatorHandler` is the standard formula: B = CHO/CR + (GC-GT)/CF - IOB;
- `bolusCalculatorHandlerParams`: (optional, default: `[]`) a structure that contains the parameters to pass to the bolusCalculatorHandler function. It also serves as memory area for the `bolusCalculatorHandler` function;
- `basalHandler`: (optional, default: `'defaultBasalHandler'`) a vector of characters that specifies the name of the function handler that implements a basal controller to be used during the replay of a given scenario when `basalSource` is `'dss'`. The function must have 2 output, i.e., the computed basal rate (U/min) and a structure containing the dss hyperparameter. The function must have 7 inputs, i.e., `G` (mg/dl) a vector as long the simulation length containing all the simulated glucose concentrations up to `timeIndex` (the other values are nan), `mealAnnouncements` (g/min) a vector that contains the announced meal CHO intakes inputs for the whole replay simulation, `bolus` (U/min) a vector that contains the bolus insulin input for the whole replay simulation, `basal` (U/min) a vector that contains the basal insulin input for the whole replay simulation, `time` (datetime) a vector that contains the time istants of current replay simulation, `timeIndex` is a number that defines the current time istant in the replay simulation, `dss` a structure containing the dss hyperparameters and the optionally provided `basalHandlerParams` (`dss` is also echoed in the output to enable memory-like features). Vectors contain one value for each integration step. The default basal controller implemented by `'defaultBasalHandler'` is: if G < 70, basal = 0, otherwise basal = basal(1). 
- `basalHandlerParams`: (optional, default: `[]`) a structure that contains the parameters to pass to the basalHandler function. It also serves as memory area for the `basalHandler` function;
- `mealGeneratorHandler`: (optional, default: `'defaultMealGeneratorHandler'`) a vector of characters that specifies the name of the function handler that implements a meal generator to be used during the replay of a given scenario when `choSource` is `'generated'`. The function must have 4 outputs, i.e., the generated meal (g/min) actually consumed by the virtual subject, the generated meal announcement (g/min) that is usually used to compute the corresponding insulin bolus, the type of the meal (must be `'B'`,`'L'`,`'D'`, or `'S'`), and a structure containing the dss hyperparameter. The function must have 8 inputs, i.e., `G` (mg/dl) a vector as long the simulation length containing all the simulated glucose concentrations up to `timeIndex` (the other values are nan), `meal` (g/min) a vector that contains the meal CHO intakes inputs for the whole replay simulation, `mealAnnouncements` (g/min) a vector that contains the announced meal CHO intakes inputs for the whole replay simulation, `bolus` (U/min) a vector that contains the bolus insulin input for the whole replay simulation, `basal` (U/min) a vector that contains the basal insulin input for the whole replay simulation, `time` (datetime) a vector that contains the time istants of current replay simulation, `timeIndex` is a number that defines the current time istant in the replay simulation, `dss` a structure containing the dss hyperparameters and the optionally provided `mealGeneratorHandlerParams` (`dss` is also echoed in the output to enable memory-like features). Vectors contain one value for each integration step. The default meal generator implemented by `defaultMealGeneratorHandler` is: put a snack meal of 50g of CHO in the first instant and announce only 40g.
- `mealGeneratorHandlerParams`: (optional, default: `[]`) a structure that contains the parameters to pass to the `mealGeneratorHandler` function. It also serves as memory area for the `mealGeneratorHandler` function;
- `enableHypoTreatments`: (optional, default: `0`) a numerical flag that specifies whether to enable hypotreatments during the replay of a given scenario. Can be `0` or `1`. Can be set only when ReplayBG is used in `'replay'` mode;
- `hypoTreatmentsHandler`: (optional, default: `'adaHypoTreatmentsHandler'`) a vector of characters that specifies the name of the function handler that implements an hypotreatment strategy during the replay of a given scenario. The function must have 2 outputs, i.e., the hypotreatments carbohydrates intake (g/min) and the `dss` structure (see section "Use case 2: Test an hypotreatment strategy with ReplayBG" below). The function must have 8 inputs, i.e., `G` (mg/dl) a glucose vector as long the simulation length containing all the simulated glucose concentrations up to timeIndex (the other values are nan), `CHO` (g/min) a vector that contains the CHO intakes input for the whole replay simulation, `hypotreatments` (g/min) a vector that contains the hypotreatments intakes input for the whole replay simulation (will be also populated by ReplayBG during the simulation if one or more hypotreatment is given by the function itself), `bolus` (U/min) a vector that contains the bolus insulin input for the whole replay simulation, `basal` (U/min) a vector that contains the basal insulin input for the whole replay simulation, `time` (datetime) a vector that contains the time instants of current replay simulation, `timeIndex` is a number that defines the current time instant in the replay simulation and the `dss` structure. Vectors contain one value for each integration step. The default policy implemented by the `adaHypoTreatmentsHandler` function is "take an hypotreatment of 10 g every 15 minutes while in hypoglycemia";
- `enableCorrectionBoluses`: (optional, default: `0`) a numerical flag that specifies whether to enable correction boluses during the replay of a  given scenario. Can be `0` or `1`. Can be set only when ReplayBG is used in `'replay'` mode;
- `correctionBolusesHandler`: (optional, default: `'correctsAbove250Handler'`) a vector of characters that specifies the name of the function handler that implements a corrective bolusing strategy during the replay of a given scenario. The function must have 2 output, i.e., the correction insulin bolus (U/min) and the `dss` structure (see section "Use case 3: Test a corrective bolusing strategy with ReplayBG" below). The function must have 7 inputs, i.e., `G` (mg/dl) a glucose vector as long the simulation length containing all the simulated glucose concentrations up to timeIndex (the other values are nan), `CHO` (g/min) a vector that contains the CHO intakes input for the whole replay simulation, `bolus` (U/min) a vector that contains the bolus insulin input for the whole replay simulation, `basal` (U/min) a vector that contains the basal insulin input for the whole replay simulation, `time` (datetime) a vector that contains the time instants of current replay simulation, `timeIndex` is a number that defines the current time instant in the replay simulation and the `dss` structure. Vectors contain one value for each integration step. The default policy implemented by the `correctsAbove250Handler` function is "take a corrective bolus of 1 U every 1 hour while above 250 mg/dl";
- `hypoTreatmentsHandlerParams`: (optional, default: `[]`) a structure that contains the parameters to pass to the `hypoTreatmentsHandler` function (see section "Use case 2: Test an hypotreatment strategy with ReplayBG" below). It also serves as memory area for the `hypoTreatmentsHandler` function;
- `correctionBolusesHandlerParams`: (optional, default: `[]`) a structure that contains the parameters to pass to the `correctionBolusesHandler` function (see section "Use case 3: Test a corrective bolusing strategy with ReplayBG" below). It also serves as memory area for the `correctionBolusesHandler` function;
- `seed`: (optional, default: `randi([1 1048576])`) an integer that specifies the random seed. For reproducibility;
- `saveSuffix`: (optional, default: `''`) a vector of char to be attached as suffix to the resulting output files' name;
- `plotMode`: (optional, default: `1`) a numerical flag that specifies whether to show the plot of the results or not. Can be `0` or `1`;
- `enableLog`: (optional, default: `1`) a numerical flag that specifies whether to log the output of ReplayBG not. Can be `0` or `1`;
- `verbose`: (optional, default: `1`) a numerical flag that specifies the verbosity of ReplayBG. Can be `0` or `1`.

### Example of ReplayBG use for assessing your algorithm

Potentially, given the computational cost and the function of the parameter identification machinery (MCMC), this step can take forever. 

These are some suggested usage of ReaplyBG depending on your needs.

Please remember that the rationale is to identify a dataset "once and for all" (that is the heavy part of ReplayBG) and then play with the simulations (see "Step 2: Use of ReplayBG for simulation"). 

#### Use case 1: Test different inputs by simply modifying `data`

The most simple use case of ReaplyBG consists of modifying the `data` timetable used during step 1 setting new insulin/meal inputs and replaying the scenario. For example if you want to simulate "what would have happened if I had doubled the CHO intake?":

```MATLAB
%Here, I suppose that data is the timetable used during identification
data.CHO = data.CHO*2;
replayBG( ...
  'replay', data, BW, scenario, saveName, ...
  'plotMode',1, ...
  'verbose',1, ...
  'seed', 1, ...
);
```

The same rationale can be applied to the insulin bolus/basal input. 

Note that if you want to add a meal and `scenario` is `multi-meal` you also have to set the corresponding `choLabel`, e.g.:
```MATLAB
%Here, I suppose that data is the timetable used during identification
data.CHO(12) = 5; %Here I am adding a snack of 5 g/min at 12*`sampleTime` minutes after the starting of the simulation.
data.choLabel(12) = 'S';
replayBG( ...
  'replay', data, BW, scenario, saveName, ...
  'plotMode',1, ...
  'verbose',1, ...
  'seed', 1, ...
);
```

#### Use case 2: Test an hypotreatment strategy with ReplayBG

Let's say that you want to test an algorithm that advice to take an hypotreatment according to some strategy to avoid hypoglycemia. 

You have to follow two steps: 
1. First define a function that implements your strategy, namely the "handler". This function, as stated above, must have 2 outputs, i.e., the hypotreatments carbohydrates intake (g/min) and the `dss` structure. The function must have 8 inputs, i.e., `G` (mg/dl) a glucose vector as long the simulation length containing all the simulated glucose concentrations up to timeIndex (the other values are nan), `CHO` (g/min) a vector that contains the CHO intakes input for the whole replay simulation, `hypotreatments` (g/min) a vector that contains the hypotreatments intakes input for the whole replay simulation (will be also populated by ReplayBG during the simulation if one or more hypotreatment is given by the function itself), `bolus` (U/min) a vector that contains the bolus insulin input for the whole replay simulation, `basal` (U/min) a vector that contains the basal insulin input for the whole replay simulation, `time` (datetime) a vector that contains the time instants of current replay simulation, `timeIndex` is a number that defines the current time instant in the replay simulation and the `dss` structure. For example, here's the default handler implemented in ReplayBG that provides the user with an example to start playing with:

```MATLAB
function [HT, dss] = adaHypoTreatmentsHandler(G,CHO,hypotreatments,bolus,basal,time,timeIndex,dss)
% function  adaHypoTreatmentsHandler(G,CHO,hypotreatments,bolus,basal,time,timeIndex,dss)
% Implements the default hypotreatment strategy: "take an hypotreatment of 
% 10 g every 15 minutes while in hypoglycemia".
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    HT = 0;
    
    %If glucose is lower than 70...
    if(G(timeIndex) < 70)
        
        %...and if there are no CHO intakes in the last 15 minutes, then take an HT
        if(timeIndex > 15 && ~any(hypotreatments((timeIndex - 15):timeIndex)))
            HT = 15; % g/min
        end
        
    end
        
end
```

2. Call ReplayBG by enabling the hypotreatments "module" and by providing the name of the handler just created: 

```MATLAB
%Here, I suppose that data is the timetable used during identification
replayBG( ...
  'replay', data, BW, scenario, saveName, ...
  'enableHypoTreatments', 1, ...
  'hypoTreatmentsHandler', 'adaHypoTreatmentsHandler', ...
  'plotMode',1, ...
  'verbose',1, ...
  'seed', 1, ...
);
```

Three notes: 

- The handler function will be called for each integration time step (each "simulated" minute). This will slow down ReplayBG.
- If `scenario` is `'single meal'`, the `hypotreatments` input will contain only the hypotreatments generated by this function during the simulation. If `scenario` is `'multi-meal'`, the `hypotreatments` input will ALSO contain the hypotreatments already present in the given data that labeled as such.
- `CHO` does not contain hypotreatments.
- `dss` is a structure that serves as memory area and contains decsion support related parameter passed to ReplayBG when you call the `replayBG` function (i.e., the parameters `BW, `GT`, `CR`, `CF`, `bolusCalculatorHandlerParams`, `basalHandlerParams`, `mealGeneratorHandlerParams`, `hypoTreatmentsHandlerParams`, and `correctionBolusesHandlerParams`). As such you can use it to provide to your handler the parameter you need. Also, keep in mind that, serving as a memory area, it is possible to store values inside `dss` and `hypoTreatmentsHandlerParams` and they will be available in the next call of the function (this is useful if you need to compute things like the insulin-on-board, or "when is the last time I gave an hypotreatment?").

#### Use case 3: Test a corrective bolusing strategy with ReplayBG

Let's say that you want to test an algorithm that advice to take a corrective insulin bolus according to some strategy to avoid hyperglycemia. 

You have to follow two steps: 
1. First define a function that implements your strategy, namely the "handler". This function, as stated above, must have 2 outputs, i.e., the hypotreatments carbohydrates intake (g/min) and the `dss` structure. The function must have 7 inputs, i.e., `G` (mg/dl) a glucose vector as long the simulation length containing all the simulated glucose concentrations up to timeIndex (the other values are nan), `CHO` (g/min) a vector that contains the CHO intakes input for the whole replay simulation, `bolus` (U/min) a vector that contains the bolus insulin input for the whole replay simulation, `basal` (U/min) a vector that contains the basal insulin input for the whole replay simulation, `time` (datetime) a vector that contains the time instants of current replay simulation, `timeIndex` is a number that defines the current time instant in the replay simulation and the `dss` structure. For example, here's the default handler implemented in ReplayBG that provides the user with an example to start playing with:

```MATLAB
function [CB, dss] = correctsAbove250Handler(G,CHO,bolus,basal,time,timeIndex,dss)
% function  correctsAbove250Handler(G,CHO,bolus,basal,time,timeIndex,dss)
% Implements the default correction bolus strategy: "take a correction
% bolus of 1 U every 1 hour while above 250 mg/dl".
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2020 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    CB = 0;
    
    %If glucose is greater than 250...
    if(G(timeIndex) > 250)
        
        %...and if there are no boluses in the last 1 hour, then take a CB
        if(timeIndex > 60 && ~any(bolus((timeIndex - 60):timeIndex)))
            CB = 1; % U/min
        end
        
    end
    
end
```

2. Call ReplayBG by enabling the correction insulin "module" and by providing the name of the handler just created: 

```MATLAB
%Here, I suppose that data is the timetable used during identification
replayBG( ...
  'replay', data, BW, scenario, saveName, ...
  'enableCorrectionBoluses', 1, ...
  'correctionBolusesHandler', 'correctsAbove250Handler', ...
  'plotMode',1, ...
  'verbose',1, ...
  'seed', 1, ...
);
```

Three notes: 

- The handler function will be called for each integration time step (each "simulated" minute). This will slow down ReplayBG.
- `dss` is a structure that serves as memory area and contains decsion support related parameter passed to ReplayBG when you call the `replayBG` function (i.e., the parameters `BW, `GT`, `CR`, `CF`, `bolusCalculatorHandlerParams`, `basalHandlerParams`, `mealGeneratorHandlerParams`, `hypoTreatmentsHandlerParams`, and `correctionBolusesHandlerParams`). As such you can use it to provide to your handler the parameter you need. Also, keep in mind that, serving as a memory area, it is possible to store values inside `dss` and `correctionBolusesHandlerParams` and they will be available in the next call of the function (this is useful if you need to compute things like the insulin-on-board, or "when is the last time I gave a correction bolus?").

#### Use case 4: Test a bolus calculator with ReplayBG

Let's say that you want to test an algorithm that computes the meal insulin bolus according to some strategy. 

You have to follow two steps: 
1. First define a function that implements your strategy, namely the "handler". This function, as stated above, the function must have 2 output, i.e., the computed insulin bolus (U/min) and a structure containing the dss hyperparameter. The function must have 7 inputs, i.e., `G` (mg/dl) a vector as long the  simulation length containing all the simulated glucose concentrations up to `timeIndex` (the other values are nan), `mealAnnouncements` (g/min) a vector that contains the announced meal CHO intakes inputs for the whole replay simulation, `bolus` (U/min) a vector that contains the bolus insulin input for the whole replay simulation, `basal` (U/min) a vector that contains the basal insulin input for the whole replay simulation, `time` (datetime) a vector that contains the time istants of current replay simulation, `timeIndex` is a number that defines the current time istant in the replay simulation, `dss` a structure containing the dss hyperparameters. For example, here's the default handler implemented in ReplayBG that provides the user with an example to start playing with:

```MATLAB
function [B, dss] = standardBolusCalculatorHandler(G, mealAnnouncements,bolus,basal,time,timeIndex,dss)
% function  standardBolusCalculatorHandler(G,mealAnnouncements,bolus,basal,time,timeIndex,dss)
% Implements the default insulin bolus calculator formula: B = CHO/CR + (GC -GT)/CF - IOB.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2022 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    B = 0;
    
    %If a meal is announced...
    if(mealAnnouncements(timeIndex) > 0)
        
        %...give a bolus
        B = mealAnnouncements(timeIndex)/dss.CR + (G(timeIndex) - dss.GT) / dss.CF - iobCalculation(bolus(1:timeIndex),5);
        
    end
    
end

function [IOB] = iobCalculation(insulin,Ts)

    % define 6 hour curve
    k1 = 0.0173;
    k2 = 0.0116;
    k3 = 6.75;
    IOB_6h_curve = zeros(360,1);
    for t = 1:360
        IOB_6h_curve(t)= 1 - ...
            0.75*((-k3/(k2*(k1-k2))*(exp(-k2*(t)/0.75)-1) + ...
            k3/(k1*(k1-k2))*(exp(-k1*(t)/0.75)-1))/(2.4947e4));
    end
    IOB_6h_curve = IOB_6h_curve(Ts:Ts:end);

    % IOB is the convolution of insulin data with IOB curve
    IOB = conv(insulin, IOB_6h_curve);
    IOB = IOB(length(insulin));

end
```

2. Call ReplayBG by changing the `bolusSource` from `'data'` to `'dss'` and by providing the name of the handler just created: 

```MATLAB
%Here, I suppose that data is the timetable used during identification
replayBG( ...
  'replay', data, BW, scenario, saveName, ...
  'bolusSource','dss', ...
  'bolusCalculatorHandler', 'standardBolusCalculator', ...
  'plotMode',1, ...
  'verbose',1, ...
  'seed', 1, ...
);
```

Three notes: 

- The handler function will be called for each integration time step (each "simulated" minute). This will slow down ReplayBG.
- `dss` is a structure that serves as memory area and contains decision support related parameter passed to ReplayBG when you call the `replayBG` function (i.e., the parameters `BW, `GT`, `CR`, `CF`, `bolusCalculatorHandlerParams`, `basalHandlerParams`, `mealGeneratorHandlerParams`, `hypoTreatmentsHandlerParams`, and `correctionBolusesHandlerParams`). As such you can use it to provide to your handler the parameter you need. Also, keep in mind that, serving as a memory area, it is possible to store values inside `dss` and `bolusCalculatorHandlerParams` and they will be available in the next call of the function (this is useful if you need to compute things like the insulin-on-board, or "when is the last time I gave an insulin bolus?").

#### Use case 5: Test a basal controller with ReplayBG

Let's say that you want to test an algorithm that basal rate infusion according to some strategy. 

You have to follow two steps: 
1. First define a function that implements your strategy, namely the "handler". This function, as stated above, the function must have 2 output, i.e., the computed basal rate (U/min) and a structure containing the dss hyperparameter. The function must have 7 inputs, i.e., `G` (mg/dl) a vector as long the simulation length containing all the simulated glucose concentrations up to `timeIndex` (the other values are nan), `mealAnnouncements` (g/min) a vector that contains the announced meal CHO intakes inputs for the whole replay simulation, `bolus` (U/min) a vector that contains the bolus insulin input for the whole replay simulation, `basal` (U/min) a vector that contains the basal insulin input for the whole replay simulation, `time` (datetime) a vector that contains the time istants of current replay simulation, `timeIndex` is a number that defines the current time istant in the replay simulation, `dss` a structure containing the dss hyperparameters. For example, here's the default handler implemented in ReplayBG that provides the user with an example to start playing with:

```MATLAB
function [B, dss] = defaultBasalHandler(G, mealAnnouncements,bolus,basal,time,timeIndex,dss)
% function  defaultBasalHandler(G,mealAnnouncements,bolus,basal,time,timeIndex,dss)
% Implements the default basal rate controller: if G < 70, basal = 0,
% otherwise basal = basal(1). 
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2022 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------

    B = basal(1);
    
    %If G < 70...
    if(G(timeIndex) < 70)
        
        %...set basal rate to 0.
        B = 0;
        
    end
    
end
```

2. Call ReplayBG by changing the `basalSource` from `'data'` to `'dss'` and by providing the name of the handler just created: 

```MATLAB
%Here, I suppose that data is the timetable used during identification
replayBG( ...
  'replay', data, BW, scenario, saveName, ...
  'basalSource','dss', ...
  'basalHandler', 'defaultBasalHandler', ...
  'plotMode',1, ...
  'verbose',1, ...
  'seed', 1, ...
);
```

Three notes: 

- The handler function will be called for each integration time step (each "simulated" minute). This will slow down ReplayBG.
- `dss` is a structure that serves as memory area and contains decision support related parameter passed to ReplayBG when you call the `replayBG` function (i.e., the parameters `BW`, `GT`, `CR`, `CF`, `bolusCalculatorHandlerParams`, `basalHandlerParams`, `mealGeneratorHandlerParams`, `hypoTreatmentsHandlerParams`, and `correctionBolusesHandlerParams`). As such you can use it to provide to your handler the parameter you need. Also, keep in mind that, serving as a memory area, it is possible to store values inside `dss` and `bolusCalculatorHandlerParams` and they will be available in the next call of the function (this is useful if you need to compute things like the insulin-on-board, or "for how much did I suspend basal infusion?").

#### Use case 6: Test a meal generator with ReplayBG

Let's say that you want to test an algorithm that generates meals according to some strategy. 

You have to follow two steps: 
1. First define a function that implements your strategy, namely the "handler". This function, as stated above, the function must have 4 outputs, i.e., the generated meal (g/min) actually consumed by the virtual subject, the generated meal announcement (g/min) that is usually used to compute the corresponding insulin bolus, the type of the meal (must be `'B'`,`'L'`,`'D'`, or `'S'`), and a structure containing the dss hyperparameter. The function must have 8 inputs, i.e., `G` (mg/dl) a vector as long the simulation length containing all the simulated glucose concentrations up to `timeIndex` (the other values are nan), `meal` (g/min) a vector that contains the meal CHO intakes inputs for the whole replay simulation, `mealAnnouncements` (g/min) a vector that contains the announced meal CHO intakes inputs for the whole replay simulation, `bolus` (U/min) a vector that contains the bolus insulin input for the whole replay simulation, `basal` (U/min) a vector that contains the basal insulin input for the whole replay simulation, `time` (datetime) a vector that contains the time istants of current replay simulation, `timeIndex` is a number that defines the current time istant in the replay simulation, `dss` a structure containing the dss hyperparameters. For example, here's the default handler implemented in ReplayBG that provides the user with an example to start playing with:

```MATLAB
function [C, MA, type, dss] = defaultMealGeneratorHandler(G, meal, mealAnnouncements,bolus,basal,time,timeIndex,dss)
% function  defaultMealGeneatorHandler(G,meal,mealAnnouncements,bolus,basal,time,timeIndex,dss)
% Implements the default meal generation policy: put a snack meal of 50g of CHO
% in the first instant and announce only 40g.
%
% ---------------------------------------------------------------------
%
% Copyright (C) 2022 Giacomo Cappon
%
% This file is part of ReplayBG.
%
% ---------------------------------------------------------------------
    
    %Default output values
    C = 0;
    MA = 0;
    type = '';
    
    %If this is the first time instant...
    if(timeIndex == 1)
        
        %...generate a snack meal of 50g and announce just 40g.
        C = 50;
        MA = 40;
        type = 'S';
        
    end
    
end
```

2. Call ReplayBG by changing the `mealSource` from `'data'` to `'generated'` and by providing the name of the handler just created: 

```MATLAB
%Here, I suppose that data is the timetable used during identification
replayBG( ...
  'replay', data, BW, scenario, saveName, ...
  'mealSource','generated', ...
  'mealGeneratorHandler', 'defaultMealGeneratorHandler', ...
  'plotMode',1, ...
  'verbose',1, ...
  'seed', 1, ...
);
```

Three notes: 

- The handler function will be called for each integration time step (each "simulated" minute). This will slow down ReplayBG.
- `dss` is a structure that serves as memory area and contains decision support related parameter passed to ReplayBG when you call the `replayBG` function (i.e., the parameters `BW, `GT`, `CR`, `CF`, `bolusCalculatorHandlerParams`, `basalHandlerParams`, `mealGeneratorHandlerParams`, `hypoTreatmentsHandlerParams`, and `correctionBolusesHandlerParams`). As such you can use it to provide to your handler the parameter you need. Also, keep in mind that, serving as a memory area, it is possible to store values inside `dss` and `bolusCalculatorHandlerParams` and they will be available in the next call of the function (this is useful if you need to compute things like the insulin-on-board, or "when did I eat last time?").

## Results

Results are saved in the `results/` folder of the replay-bg folder, specifically:
- `results/distributions/`: contains the identified ReplayBG model parameter distributions obtained via MCMC;
- `results/logs/`: contains .txt files that log the command window output of ReplayBG. NB: .txt files will be empty if verbose = 0;
- `results/mcmcChains/`: contains the MCMC chains, for each unknown parameter, obtained in each MCMC run;
- `results/modelParameters/`: contains the model parameters identified using MCMC. Known model parameters are fixed to population values obtained from the literature. Unknown model parameters estimates are in draws.<modelParameterName>.samples;
- `results/workspaces/`: contains the core ReplayBG variables and data used in a specific ReplayBG call plus a structure called `analysis` that contains useful metrics evaluated on the simulated glucose trace (this uses the [AGATA toolbox](https://github.com/gcappon/agata)). Name of the files start with `'identification'` or `'replay'` depending on how you called the `replayBG` function. 

# Notes

- Only the 'single-meal' mode has been extensively validated and evaluated in the referred paper. The 'multi-meal' model is working correctly but it is currently under development. 
- The code is continuosly evolving and if you want to support its development please feel free to contact me at giacomo.cappon@unipd.it.
