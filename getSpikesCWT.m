function getSpikesCWT(fileName, wname_list)
%% Load raw data
file = load(fileName);
data = file.dat;
channels = file.channels;
fs = file.fs;
ttx = contains(fileName, 'TTX');
spike_struct = struct;

grd = [15];

%% Detect spikes

% call setParams to set parameters manually
load('params.mat'); 
% L = -0.3;


h = waitbar(0, ['Detecting spikes...']);

for channel = 1:length(channels)
    
    for wname = wname_list
       
        wname = char(wname);
        valid_wname = strrep(wname, '.', 'p');
        spikeWaveforms = [];
        
        trace = data(1:3000000, channel);
        timestamps = zeros(1, length(trace));
        
        if ~(ismember(channel, grd))
            
            [spikeFrames, spikeWaveforms, filtTrace, threshold] = ...
            detectFramesCWT(trace,fs,Wid,wname,L,Ns, ...
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
    
    waitbar(channel/length(channels), h);
end
close(h);
save(['/Users/jeremi/mea/Spikes/', fileName(1:end-4),'L_', num2str(L), '_spike_struct.mat'],...
    'spikes', 'jSpikes', 'L', 'threshold','channels',...
    'grd', 'traces', 'templates', 'spikeCell',...
    '-v7.3');
end
