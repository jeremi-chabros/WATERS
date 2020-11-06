clear all; close all; clc;

% Modified to run pre-/post-TTX pairs
files = dir('/Users/jeremi/mea/data/organoid/*.mat');
wname_list = {'mea'};
L_list = [-0.3:0.05:-0.05];

%% Run through all the files
for file = 1:length(files)
    for L = L_list
    fileName = files(file).name;
    getSpikesCWT(fileName, wname_list, L);
    end
end