clear all; close all; clc;

% Modified to run pre-/post-TTX pairs
files = dir('/Users/jeremi/mea/data/organoid/*200617*.mat');
wname_list = {'mea'};
L_list = [-0.3:0.05:-0.05];

%% Run through all the files
for file = 1:length(files)
    progressbar('File');
    for L = L_list
    fileName = files(file).name;
    getSpikesCWT(fileName, wname_list, L);
    end
    progressbar(file/length(files));
end