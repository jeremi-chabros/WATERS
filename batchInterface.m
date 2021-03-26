dataPath = '/Users/jeremi/mea/data/organoid/';
savePath = '/Users/jeremi/mea/data/organoid/';
option = 'list';
files = {'200617_slice1.mat'};
load params
params.costList = -0.1;
batchDetectSpikes(dataPath, savePath, option, files, params);

