function batchDetectSpikes(dataPath, savePath, option, files, params)

% Description:
%	Master script for spike detection using CWT method. Runs spike
%	detection through recordings, cost parameters, electrodes, and
%	wavelets.

% INPUT:
%
%   dataPath: path (ending with '/') to the folder containing data to be
%             analyzed
%
%   savePath: path (ending with '/') to the folder where spike detection
%             output will be saved
%
%   option: pass either path to files ('path') or list of files ('list');
%
%   params: [optional] argument to pass structure containing parameters;
%           otherwise, run setParams() first to set parameters
      % nSpikes : number of spikes use to make the custom threshold
      % template

% Author:
%   Jeremy Chabros, University of Cambridge, 2020
%   email: jjc80@cam.ac.uk
%   github.com/jeremi-chabros/CWT

arguments
    dataPath;
    savePath;
    option;
    files;
    params;
end

if ~endsWith(dataPath, filesep)
    dataPath = [dataPath filesep];
end
addpath(dataPath);

%   Load parameters
if ~exist('params', 'var')
    load('params.mat');
end

multiplier = params.multiplier;
nSpikes = params.nSpikes;
nScales = params.nScales;
wid = params.wid;
grd = params.grd;
costList = params.costList;
wnameList = params.wnameList;
minPeakThrMultiplier = params.minPeakThrMultiplier;
maxPeakThrMultiplier = params.maxPeakThrMultiplier;
posPeakThrMultiplier = params.posPeakThrMultiplier;
unit = params.unit;

if ~isfield(params, 'multiple_templates')
    params.multiple_templates = 0;
end 


%%
% Get files
% Modify the '*string*.mat' wildcard to include a subset of recordings

if exist('option', 'var') && strcmp(option, 'list')
    files = files;
else
    files = dir([dataPath '*.mat']);
end
thresholds = params.thresholds;
thrList = strcat( 'thr', thresholds);
thrList = strrep(thrList, '.', 'p')';
wnameList = horzcat(wnameList, thrList);

progressbar('File', 'Electrode');

for recording = 1:numel(files)
    
    progressbar((recording-1)/numel(files), []);
    
    if exist('option', 'var') && strcmp(option, 'list')
        fileName = files{recording};
    else
        fileName = files(recording).name;
    end
    
    % Load data
    disp(['Loading ' fileName ' ...']);
    file = load(fileName);
    disp(['File loaded']);
    
    data = file.dat;
    channels = file.channels;
    fs = file.fs;
    ttx = contains(fileName, 'TTX');
    params.duration = length(data)/fs;
    
    % Truncate the data if specified
    if isfield(params, 'subsample_time')
        if ~isempty(params.subsample_time)
            if params.subsample_time(1) <= 1
                start_frame = 1;
            else
                start_frame = params.subsample_time(1) * fs;
            end
            end_frame = params.subsample_time(2) * fs;
        end
        data = data(start_frame:end_frame, :);
        params.duration = length(data)/fs;
    end
    
    for L = costList
        saveName = [savePath fileName(1:end-4) '_L_' num2str(L) '_spikes.mat'];
        if ~exist(saveName, 'file')
            params.L = L;
            tic
            disp('Detecting spikes...');
            disp(['L = ' num2str(L)]);
            
            % Pre-allocate for your own good
            spikeTimes = cell(1,60);
            spikeWaveforms = cell(1,60);
            mad = zeros(1,60);
            variance = zeros(1,60);
            
            % Run spike detection
            for channel = 1:length(channels)
                
                progressbar([], [(channel-1)/length(channels)]);
                
                spikeStruct = struct();
                waveStruct = struct();
                trace = data(:, channel);
                
                for wname = 1:numel(wnameList)
                    
                    wname = char(wnameList{wname});
                    valid_wname = strrep(wname, '.', 'p');
                    actual_wname = strrep(wname, 'p', '.');
                    
                    spikeWaves = [];
                    spikeFrames = [];
                    if ~(ismember(channel, grd))
                        
                        [spikeFrames, spikeWaves, ~] = ...
                            detectSpikesCWT(trace,fs,wid,actual_wname,L,nScales, ...
                            multiplier,nSpikes,ttx, minPeakThrMultiplier, ...
                            maxPeakThrMultiplier, posPeakThrMultiplier, ...
                            params.multiple_templates);
                        
                        if iscell(spikeFrames)
                            
                            for cell_idx = 1:length(spikeFrames)
                                custom_spike_frames = spikeFrames{cell_idx};
                                custom_spike_wave = spikeWaves{cell_idx};
                                valid_wname_w_idx = strcat(valid_wname, num2str(cell_idx));
                                switch unit
                                    case 'ms'
                                        spikeStruct.(valid_wname_w_idx) = custom_spike_frames/(fs/1000);
                                    case 's'
                                        spikeStruct.(valid_wname_w_idx) = custom_spike_frames/fs;
                                    case 'frames'
                                        spikeStruct.(valid_wname_w_idx) = custom_spike_frames;
                                end
                                waveStruct.(valid_wname_w_idx) = custom_spike_wave;
                            end 
                            
                        else
                            switch unit
                                case 'ms'
                                    spikeStruct.(valid_wname) = spikeFrames/(fs/1000);
                                case 's'
                                    spikeStruct.(valid_wname) = spikeFrames/fs;
                                case 'frames'
                                    spikeStruct.(valid_wname) = spikeFrames;
                            end
                            waveStruct.(valid_wname) = spikeWaves;
                        end 
                    else
                        waveStruct.(valid_wname) = [];
                        spikeStruct.(valid_wname) = [];
                    end
                end
                
                spikeTimes{channel} = spikeStruct;
                spikeWaveforms{channel} = waveStruct;
                mad(channel) = median(trace)-median(abs(trace - mean(trace))) / 0.6745;
                variance(channel) = var(trace);
                
            end
            
            toc
            
            % Save results
            
            % Save results
            save_suffix = ['_' strrep(num2str(L), '.', 'p')];
            params.save_suffix = save_suffix;
            params.fs = fs;
            params.variance = variance;
            params.mad = mad;
            
            spikeDetectionResult = struct();
            spikeDetectionResult.method = 'CWT';
            spikeDetectionResult.params = params;
            
            saveName = [savePath fileName(1:end-4) '_L_' num2str(L) '_spikes.mat'];
            disp(['Saving results to: ' saveName]);
            
            varsList = {'spikeTimes', 'channels', 'spikeDetectionResult', ...
                'spikeWaveforms'};
            save(saveName, varsList{:}, '-v7.3');
        end
    end
end
progressbar(1);
end