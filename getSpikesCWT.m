function getSpikesCWT(fileName, wname_list, L)
%% Load raw data

% parameters
multiplier = 3.5;
n_spikes = 200;
Ns = 5;
Wid = [0.5 1];

savePath = '/Users/jeremi/mea/spikes/';

saveName = [savePath, fileName(1:end-4),'_L_',...
    num2str(L),'_spike_struct.mat'];

if ~exist(saveName, 'file')
    tic
    file = load(fileName);
    disp('File loaded');
    toc
    data = file.dat;
    channels = file.channels;
    fs = file.fs;
    ttx = contains(fileName, 'TTX');
    spike_struct = struct;
    
    grd = [15];
    
    %% Detect spikes
    
    % call setParams to set parameters manually
    % load('params.mat');
    
progressbar('Electrode');
    tic
    for channel = 1:length(channels)
        
        for wname = wname_list
            
            wname = char(wname);
            valid_wname = strrep(wname, '.', 'p');
            spikeWaveforms = [];
            
            trace = data(:, channel);
            timestamps = zeros(1, length(trace));
            
            if ~(ismember(channel, grd))
                
                [spikeFrames, spikeWaveforms, ~, threshold] = ...
                    detectFramesCWT(trace,fs,Wid,wname,L,Ns, ...
                    multiplier,n_spikes,ttx);
                
                if strcmp(wname, 'mea')
                    load('mother.mat','Y');
                    templates(channel, :) = Y;
                end
                
                timestamps(spikeFrames) = 1;
                spikes{channel} = spikeWaveforms;
%                 traces(channel, :) = filtTrace;
                spike_struct.(valid_wname) = spikeFrames;
            end
            
            jSpikes(channel, :) = timestamps;
            
        end
%         spikeCell{channel} = spike_struct;
        
        progressbar(channel/length(channels));
    end
    toc
    
    % save(['/Users/jeremi/mea/spikes/', fileName(1:end-4),'L_', num2str(L), '_spike_struct.mat'],...
    %     'spikes', 'jSpikes', 'L', 'threshold','channels',...
    %     'grd', 'traces', 'templates', 'spikeCell',...
    %     '-v7.3');
    
    save(saveName,...
        'spikes', 'jSpikes', 'L', 'threshold','channels',...
        'grd', ...
        '-v7.3');
end
end
