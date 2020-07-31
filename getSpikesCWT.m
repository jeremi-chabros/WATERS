clear all;
clc;
path = '/Users/ssense/Desktop/MEA-analysis/Data/PV-ArchT/rawData/';
thisPath = pwd;
cd (path)
files = dir('*0006.mat');
cd (thisPath)

% recording = 'PAT200219_2C_DIV170002.mat';

%% Run through all the files
for file = 1:length(files)
    recording = files(file).name;
    getSpikesCWT(path,recording);
end

function getSpikesCWT(path, recording)
%% Load raw data
fileName = [path recording];
file = load(fileName);
data = file.dat;
channels = file.channels;
fs = file.fs;
ttx = contains(fileName, 'TTX');

grd = [15 23 32];

%% Detect spikes

for channel = 1:length(channels)
    % Parameters
    load('params.mat');
    
    disp(['Electrode ', num2str(channel), ':']);
    spikeWaveform = [];
    
    trace = data(:, channel);
    timestamps = zeros(1, length(trace));
    if ~(ismember(channel, grd))
        [spikeFrames, filtTrace, threshold] = detectFramesCWT(...
                                              trace,fs,Wid,wname,L,Ns,...
                                              multiplier,n_spikes,ttx);
        
        timestamps(spikeFrames) = 1;
        
        for i = 1:length(spikeFrames)
            if spikeFrames(i)+25 < length(filtTrace)
                spikeWaveform(i,:) = filtTrace(spikeFrames(i)-25:spikeFrames(i)+25);
            end
        end
        
        spikes{channel} = spikeWaveform;
    end
    
    jSpikes(channel, :) = timestamps;
    
end
save([recording(1:end-4) '_jSpikes.mat'], 'spikes', 'jSpikes', 'L', 'channels');
end
