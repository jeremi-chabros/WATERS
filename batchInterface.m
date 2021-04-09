clearvars; clc;
dataPath = '/Users/jeremi/mea/data/organoid/';
savePath = '/Users/jeremi/mea/data/organoid/';
option = 'list';
files = {'200617_slice1.mat'};
load params
params.wnameList = {'mea','bior1.5'}';
params.costList = -0.3;
params.thresholds = {'2.5'};
params.subsample_time = [1, 60];
%%
batchDetectSpikes(dataPath, savePath, option, files, params);

