clear all; close all; clc;

path = '/Users/ssense/Desktop/MEA-analysis/Data/PV-ArchT/rawData/';
thisPath = pwd;
cd (path)
files = dir('*0002.mat');
cd (thisPath)

%% Run through all the files
for file = 1:length(files)
    recording = files(file).name;
    getSpikesCWT(path, recording);
end