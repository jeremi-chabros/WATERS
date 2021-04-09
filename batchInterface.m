clearvars; clc;
dataPath = 'C:\Users\Sand Box\Dropbox (Cambridge University)\NOG MEA Data\MEA2100 Organoid\all_mat_organoid\';
savePath = 'C:\Users\Sand Box\Dropbox (Cambridge University)\NOG MEA Data\MEA2100 Organoid\spikeDetectionOutputJeremy\example\';

option = 'list';

% Comment out to run on all the files in the directory
% option = ''; 
% files = '';

files = {'200617_slice1.mat'};

load params
params.unit = 's';

% Admissible wavelets: bior1.5, bior1.3, mea, db2
params.wnameList = {'mea','bior1.5'}';
params.costList = [-0.3, -0.2];
params.thresholds = {'2.5', '3.5'};
params.subsample_time = [1, 60];
%%
batchDetectSpikes(dataPath, savePath, option, files, params);

