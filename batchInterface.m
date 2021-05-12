clearvars; clc;
%{
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
%}

%% Old version code from Tim to test things

clearvars; clc;
dataPath = '/media/timsit/Seagate Expansion Drive/The_Organoid_Project/data/all_mat_files/test-detection/';
savePath = '/media/timsit/Seagate Expansion Drive/The_Organoid_Project/data/all_mat_files/test-detection/results/';

addpath(dataPath)

option = 'list';
files = { ... 
'Organoid 180518 slice 7 old MEA 3D stim recording 2.mat'};
% , ...     
% 'Organoid 180518 slice 7 old MEA 3D stim recording 3.mat'};

% files = {
%     '/media/timsit/Seagate Expansion Drive/The_Organoid_Project/data/all_mat_files/test-detection/Organoid 180518 slice 7 old MEA 3D stim recording 3.mat',
 %    '/media/timsit/Seagate Expansion Drive/The_Organoid_Project/data/all_mat_files/test-detection/Organoid 180518 slice 7 old MEA 3D stim recording 2.mat', ...
% };

load params
params.wnameList = {'mea','bior1.5'}';
params.costList = -0.3;
params.thresholds = {'2.5', '2.5'};
params.subsample_time = [1, 60];
params.run_detection_in_chunks = 0; % whether to run wavelet detection in chunks (0: no, 1:yes)
params.chunk_length = 60;  % in seconds

% adding HDBSCAN path (please specify your own path to HDBSCAN)
addpath(genpath('/home/timsit/HDBSCAN/'));

params.multiple_templates = 1; % whether to get multiple templates to adapt
params.multi_template_method = 'PCA';  % options are PCA or spikeWidthAndAmplitude
% Set the number of spikes used to make the template (!)
params.nSpikes = 10000;
params.plot_folder = '/media/timsit/Seagate Expansion Drive/The_Organoid_Project/data/all_mat_files/test-detection/results/plots';


batchDetectSpikes(dataPath, savePath, option, files, params);



