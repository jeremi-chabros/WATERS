clearvars; clc;

% Specify the path to your data
dataPath = 'C:\Users\Sand Box\Dropbox (Cambridge University)\NOG MEA Data\MEA2100 Organoid\all_mat_organoid\';

% If run on single files (as opposed to all files in the dataPath
% directory), specify the list of the file names
all_files = dir([dataPath '*.mat']);
all_files = {all_files.name};
file_id = randi(length(all_files), [15,1]);

% files = {'PAT200219_2C_DIV170001.mat'};
files = {all_files{file_id}};

% Desired output directory
savepath = 'C:\Users\Sand Box\Dropbox (Cambridge University)\NOG MEA Data\MEA2100 Organoid\spikeDetectionOutputJeremy\new_spikes\';

% This is the output of the 'setParams.m' function, type 'setParams' to
% initialize
load('params.mat');

% params.subsample_time = [30 60];
params.costList = [0.000001, 0.0000001];
params.ns = 2;
params.wnameList = {'mea', 'swtteo', 'bior1.5', 'bior1.3', 'db2'}';
params.multiplier = 3.0;

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
% s.adapt_wavelet(waveform);
%%
s.getSpikes;