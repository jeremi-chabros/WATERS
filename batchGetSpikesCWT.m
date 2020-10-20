clear all; close all; clc;

path = '/Users/jeremi/mea/Data/';
thisPath = pwd;
cd (path)
files = dir('*.mat');
cd (thisPath)
wname_list = {'mea'};

%% Run through all the files
for file = 1:length(files)
    recording = files(file).name;
    getSpikesCWT(path, recording, wname_list);
end