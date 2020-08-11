function getSpikesCWT(path, recording, wname_list)
%% Load raw data
fileName = [path recording];
file = load(fileName);
data = file.dat;
channels = file.channels;
fs = file.fs;
ttx = contains(fileName, 'TTX');
spike_struct = struct;

grd = [15 23 32];

%% Detect spikes

load('params.mat');


for channel = 1:length(channels)
    waitbar(channel/length(channels), ['Electrode: ' num2str(channel) '/' num2str(length(channels))]);
    for wname = wname_list
        wname = char(wname);
        valid_wname = strrep(wname, '.', 'p');
        spikeWaveforms = [];
        
        trace = data(:, channel);
        timestamps = zeros(1, length(trace));
        if ~(ismember(channel, grd))
            [spikeFrames, spikeWaveforms, filtTrace, threshold] = detectFramesCWT(...
                trace,fs,Wid,wname,L,Ns,...
                multiplier,n_spikes,ttx);
            if strcmp(wname, 'mea')
                load('mother.mat','Y');
                templates(channel, :) = Y;
            end
            
            timestamps(spikeFrames) = 1;
            spikes{channel} = spikeWaveforms;
            traces(channel, :) = filtTrace;
            spike_struct.(valid_wname) = spikeFrames;
        end
        
        jSpikes(channel, :) = timestamps;

    end
    spikeCell{channel} = spike_struct;
end
save([recording(1:end-4) '_spike_struct.mat'], 'spikes', 'jSpikes', 'L', 'threshold',...
    'channels', 'grd', 'traces', 'templates', 'spikeCell');
end
