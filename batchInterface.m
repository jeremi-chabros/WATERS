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
% dataPath = '/media/timsit/Seagate Expansion Drive/The_Organoid_Project/data/all_mat_files/test-detection/';
% savePath = '/media/timsit/Seagate Expansion Drive/The_Organoid_Project/data/all_mat_files/test-detection/results/';

% dataPath = '/media/timsit/Seagate Expansion Drive/The_Organoid_Project/data/all_mat_files/spring-summer-2021-Rachael-troubleshoot/';
% savePath = '/media/timsit/Seagate Expansion Drive/The_Organoid_Project/data/all_mat_files/spring-summer-2021-Rachael-troubleshoot/results';

dataPath = '/media/timsit/T7/test-detection/';
savePath = '/media/timsit/T7/test-detection/results/';

addpath(dataPath)

option = 'list';
% files = { ... 
  % '181210_orgaonid_slice50001.mat';
%    'Organoid  180518 slice 7 old MEA 3D stim recording 2.mat'};
% , ...     
% 'Organoid 180518 slice 7 old MEA 3D stim recording 3.mat'};

files = { ...
     '2000803_slice3_6.mat', ...
     '2000803_slice3_7_TTX.mat'
    %  '/media/timsit/Seagate Expansion Drive/The_Organoid_Project/data/all_mat_files/test-detection/Organoid 180518 slice 7 old MEA 3D stim recording 2.mat', ...
};

load params
params.wnameList = {'bior1.5', 'db2'}';  % {'mea','bior1.5'}'; (note the transpose) 
params.costList = [-0.3, -0.2, -0.1, 0];
params.thresholds = {'2.5', '3.5', '4.5'}; % the need of horzcat here is not good.
params.threshold_calculation_window = [0, 1.0];  % which part of the recording to do spike detection, 0 = start of recording, 0.5 = midway, 1 = end of recording
% params.absThresholds = {''};  % add absolute thresholds here
params.subsample_time = [1, 60];
params.run_detection_in_chunks = 0; % whether to run wavelet detection in chunks (0: no, 1:yes)
params.chunk_length = 60;  % in seconds, will be ignored if run_detection_in_chunks = 0
params.multiplier = 3; % multiplier to use  extracting spikes for wavelet (not for detection)

% adding HDBSCAN path (please specify your own path to HDBSCAN)
addpath(genpath('/home/timsit/HDBSCAN/'));

% params.custom_threshold_file = load(fullfile(dataPath, 'results', ...
% 'Organoid 180518 slice 7 old MEA 3D stim recording 3_L_-0.3_spikes_threshold_ref.mat'));

params.custom_threshold_method_name = {'thr2p5', 'thr3p5', 'thr4p5'};
params.minPeakThrMultiplier = -5;
params.maxPeakThrMultiplier = -100;
params.posPeakThrMultiplier = 15;

params.nSpikes = 10000;
params.multiple_templates = 1; % whether to get multiple templates to adapt (1: yes, 0: no)
params.multi_template_method = 'amplitudeAndWidthAndSymmetry';  % options are PCA, spikeWidthAndAmplitude, or amplitudeAndWidthAndSymmetry
% Set the number of spikes used to make the template (!)

% params.plot_folder = '/media/timsit/Seagate Expansion Drive/The_Organoid_Project/data/all_mat_files/test-detection/results/plots';
% params.plot_folder = '/media/timsit/Seagate Expansion Drive/The_Organoid_Project/data/all_mat_files/spring-summer-2021-Rachael-troubleshoot/results/plots/';


batchDetectSpikes(dataPath, savePath, option, files, params);


%% Plot summary of detection results 
savePath = '/media/timsit/T7/test-detection/results/';
plotDetectionResults(savePath, savePath);




