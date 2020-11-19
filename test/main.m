close all
clear all
clc

restoredefaultpath;

addpath(genpath(fullfile('..','src')));
addpath(genpath(fullfile('..','utils')));

results = runtests(pwd,'IncludeSubfolders',true);