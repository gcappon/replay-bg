
# CHANGELOG

All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).
 
## [2.1.0] - 2022-07-06
 
ReplayBG can now work as a simulator leveraging identified model parameters to represent a virtual subject. 

### Added

- Input source can now be specified by the user using the new optional `bolusSource` (default: `'data'`, can be `'data'` or `'dss'`), `basalSource` (default: `'data'`, can `'data'`, `'u2ss'`, or `'dss'`) and `choSource` (default: `'data'`, can be `'data'` or `'generated'`) input parameters of `replayBG` function.
- User can now specify custom handlers for:
  - a meal generation policy using the `mealGeneratorHandler` optional input parameter of `replayBG` (used if `choSource` is `'generated'`);
  - a basal controller using the `basalHandler` optional input parameter of `replayBG` (used if `basalSource` is `'dss'`);
  - a bolus calculator using the `bolusCalculatorHandler` optional input parameter of `replayBG` (used if `bolusSource` is `'dss'`).
- A new optional input parameter `GT` of `replayBG` that specify the target glucose level in mg/dl used by the integrated dss (default: 120);
- A default `mealGeneratorHandler`, `defaultMealGeneratorHandler`;
- A default `basalHandler`, `defaultBasalHandler`;
- A default `bolusCalculatorHandler`, `standardBolusCalculatorHandler`.

### Changed

- `scenario` input variable of `replayBG` is now required;
- Default value of `CR` is now 10 g/U;
- Default value of `CF` is now 40 mg/dl/U.

### Fixed

- `plotReplayBGResults`: see issue #17.
