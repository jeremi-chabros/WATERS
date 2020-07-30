clear all;
path = '/Users/ssense/Desktop/MEA-analysis/Data/PV-ArchT/rawData/';
recording = 'PAT200219_2C_DIV170002.mat';

function getSpikesCWT(path, recording)
%% Load raw data
fileName = [path recording];
file = load(fileName);
data = file.dat;
channels = file.channels;
fs = file.fs;

%% Parameters
Wid = [0.5 1.0];
wname = 'mea';
L = 0;
Ns = 5;
multiplier = 4;
n_spikes = 200;
ttx = contains(fileName, 'TTX');

disp(['Electrode ', num2str(channel), ':']);
%% Detect spikes

for channel = 1:length(channels)
    
    spikeWaveform = [];
    
    trace = data(:, channel);
    
    [spikeFrames, filtTrace, threshold] = detectFramesCWT(trace, fs, Wid, wname, L, Ns, multiplier, ...
        n_spikes, ttx);
    
    timestamps = zeros(1, length(trace));
    timestamps(spikeFrames) = 1;
    jSpikes(channel, :) = timestamps;
    
    for i = 1:length(spikeFrames)
        if spikeFrames(i)+25 < length(filtTrace)
            spikeWaveform(i,:) = filtTrace(spikeFrames(i)-25:spikeFrames(i)+25);
        end
    end
    spikes{channel} = spikeWaveform;
end
end
