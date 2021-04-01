clearvars; clc;
dataPath = '/Users/jeremi/mea/data/organoid/';
savePath = '/Users/jeremi/mea/data/organoid/';
option = 'list';
files = {'200617_slice1.mat'};
load params
params.costList = -0.4;
% params.subsample_time = [1, 60];
%%
batchDetectSpikes(dataPath, savePath, option, files, params);

