clearvars; clc;

% For MECP2 data:
files_list = readtable('C:\Users\Sand Box\Dropbox (Cambridge University)\NOG MEA Data\MEA Data Mecp2 Project Jan 2019-\MAT files\Mecp2\files_genotypes.csv');
culture_names = files_list.culture;
ages = files_list.Age;
file_names = dir('C:\Users\Sand Box\Dropbox (Cambridge University)\NOG MEA Data\MEA Data Mecp2 Project Jan 2019-\MAT files\Mecp2\Recordings\*.mat');
file_names = {file_names.name}';
actual_files = {file_names{contains(file_names, culture_names)}}';
actual_files = {actual_files{contains(actual_files, ages)}}';
%

dataPath = 'C:\Users\Sand Box\Dropbox (Cambridge University)\NOG MEA Data\MEA Data Mecp2 Project Jan 2019-\MAT files\Mecp2\Recordings\';
savePath = 'C:\Users\Sand Box\jjc\Mecp2_spikes\';

option = 'list';

% Comment out to run on all the files in the directory
% option = ''; 
% files = '';

files = actual_files;

load params
params.unit = 's';

% Admissible wavelets: bior1.5, bior1.3, mea, db2
params.wnameList = {'mea'};
params.costList = [-0.3765];
params.thresholds = {'3.0'};
%%
batchDetectSpikes(dataPath, savePath, option, files, params);

