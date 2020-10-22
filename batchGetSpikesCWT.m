clear all; close all; clc;

% Modified to run pre-/post-TTX pairs
files = dir('/Users/jeremi/mea/Data/20*.mat');
wname_list = {'mea'};

%% Run through all the files
for file = 1:length(files)
    fileName = files(file).name;
    getSpikesCWT(fileName, wname_list);
end