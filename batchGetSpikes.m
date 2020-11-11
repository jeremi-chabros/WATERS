clear all; clc;

%   Parameters
multiplier = 3.5;
nSpikes = 200;
nS = 5;
wid = [0.5 1];
costList = [-0.3:0.05:0];
wname = 'mea';
grd = [15];

%
params = struct;
params.multiplier = multiplier;
params.nSpikes = nSpikes;
params.nS = nS;
params.wid = wid;
params.wname = wname;
params.grd = grd;

%   Set paths & file names

% addpath /Users/jeremi/mea/data/PV-ArchT/
dataPath = '/Users/jeremi/mea/data/organoid/';
savePath = '/Users/jeremi/mea/spikes/';
addpath(dataPath)

% fileName = 'PAT200219_2C_DIV170002.mat';
% fileName = '200708_slice1_3_TTX.mat';

files = dir([dataPath '*.mat']);
progressbar('File', 'Cost parameter', 'Electrode');

for recording = 1:numel(files)
    
    clearvars spikeTimes spikes
    
    fileName = files(recording).name;
    
    %   Load data
    disp('Loading...');
    file = load(fileName);
    data = file.dat;
    channels = file.channels;
    fs = file.fs;
    ttx = contains(fileName, 'TTX');
    
    for L = costList
        params.L = L;
        tic
        disp('Detecting spikes...');
        disp(['L = ' num2str(L)]);
        
        %   Run spike detection
        for channel = 1:length(channels)
            
            trace = data(:, channel);
            timestamps = zeros(1, length(trace));
            
            if ~(ismember(channel, grd))
                
                [spikeFrames, spikeWaveforms, ~, ~] = ...
                    detectFramesCWT(trace,fs,wid,wname,L,nS, ...
                    multiplier,nSpikes,ttx);
                
                timestamps(spikeFrames) = 1;
                spikes{channel} = spikeWaveforms;
            end
            
            spikeTimes{channel} = find(timestamps == 1)./25000;
%             jSpikes(channel, :) = timestamps;
            
            progressbar([], [], channel/length(channels));
        end
        toc
        
        %   Save results
        saveName = [savePath fileName(1:end-4) '_L_' num2str(L) '_spikes.mat'];
        save(saveName,'spikes','channels','spikeTimes','params','-v7.3');
        progressbar([], find(costList == L)/length(costList), []);
    end
    
    progressbar(recording/numel(files), [], []);
end
