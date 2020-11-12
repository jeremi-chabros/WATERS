function getSpikesTS(dataPath, savePath, varargin)

% Load parameters
if ~exist(varargin, 'var')
    load('params.mat');
else
    params = varargin{1};
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

%% Truncate recording
if isfield(params, 'subsample_time')
    if ~isempty(params.subsample_time)
        start_frame = params.subsample_time(1) * 25000;
        end_frame = params.subsample_time(2) * 25000;
    end
end
%%

% Get files
files = dir([dataPath '*PAT*.mat']);

for recording = 1:1
    
    progressbar(['File: ' num2str(recording) '/' num2str(numel(files))]);
    fileName = files(recording).name;
    
    % Load data
    disp(['Loading ' fileName ' ...']);
    file = load(fileName);
    disp(['File loaded']);
    data = file.dat;
    
    if isfield(params, 'subsample_time')
        data = data(start_frame:end_frame, :);
    end
    
    channels = file.channels;
    fs = file.fs;
    ttx = contains(fileName, 'TTX');
    
    for L = costList
        params.L = L;
        tic
        disp('Detecting spikes...');
        disp(['L = ' num2str(L)]);
        
        
        % Run spike detection
        for channel = 1:length(channels)
            
            spikeStruct = struct();
            waveStruct = struct();
            trace = data(:, channel);
            
            for wname = wnameList
                
                wname = char(wname);
                valid_wname = strrep(wname, '.', 'p');
                spikeWaves = [];
                % timestamps = zeros(1, length(trace));
                
                if ~(ismember(channel, grd))
                    
                    [spikeFrames, spikeWaves, ~, ~] = ...
                        detectFramesCWT(trace,fs,wid,wname,L,nScales, ...
                        multiplier,nSpikes,ttx, minPeakThrMultiplier, ...
                        maxPeakThrMultiplier, posPeakThrMultiplier);
                    
                    waveStruct.(valid_wname) = spikeWaves;
                    spikeStruct.(valid_wname) = spikeFrames / fs;
                    
                    % timestamps(spikeFrames) = 1;
                end
                
                
                % jSpikes(channel, :) = timestamps;
                
            end
            % traces(channel, :) = filtTrace;
            spikeTimes{channel} = spikeStruct;
            spikeWaveforms{channel} = waveStruct;

        end
        
        toc
        
        % Save results
        spikeDetectionResult = struct();
        spikeDetectionResult.fs = fs;
        spikeDetectionResult.method = 'CWT';
        spikeDetectionResult.params = params;
        
        save_suffix = ['_' strrep(num2str(L), '.', 'p')];
        params.save_suffix = save_suffix;
        
        saveName = [savePath fileName(1:end-4) '_L_' num2str(L) '_spikes.mat'];
        disp(['Saving results to: ' saveName]);
        
        varsList = {'spikeTimes', 'channels', 'spikeDetectionResult', ...
            'spikeWaveforms'};
        save(saveName, varsList{:}, '-v7.3');
    end
end