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

load('params.mat');

for channel = 1:length(channels)
    % Parameters
    
    disp(['Electrode ', num2str(channel), ':']);
    spikeWaveforms = [];
    
    trace = data(:, channel);
    timestamps = zeros(1, length(trace));
    if ~(ismember(channel, grd))
        [spikeFrames, spikeWaveforms, filtTrace, threshold] = detectFramesCWT(...
                                              trace,fs,Wid,wname,L,Ns,...
                                              multiplier,n_spikes,ttx);
        
        timestamps(spikeFrames) = 1;
        spikes{channel} = spikeWaveforms;
        traces(channel, :) = filtTrace;
    end
    
    jSpikes(channel, :) = timestamps;
    
end
save([recording(1:end-4) '_jSpikes.mat'], 'spikes', 'jSpikes', 'L', 'threshold',...
                                          'channels', 'grd', 'traces');
end
