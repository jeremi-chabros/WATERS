clearvars; clc;

% Specify the path to your data
dataPath = '/Users/jeremi/mea/data/PV-ArchT/';

% If run on single files (as opposed to all files in the dataPath
% directory), specify the list of the file names
files = {'PAT200219_2C_DIV170002.mat'};

% Desired output directory
savepath = [pwd filesep];

% This is the output of the 'setParams.m' function, type 'setParams' to
% initialize
load('params.mat');

params.subsample_time = [30 60];
params.costList = 0.1;
params.ns = 2;

% Create object 's' from class 'detectSpikes'
s = detectSpikes; 
% Pass arguments
s.params = params;
s.dataPath = dataPath;
s.savePath = savepath;

% These two need to be specified if running on a list of fils
s.option = 'list';
s.files = files;

% Call method 'getSpikes'
s.getSpikes;