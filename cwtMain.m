% Load file
clear all; close all;
% wavemngr('restore');
% wavemngr('add', 'meaCustom','mea', 4, '', 'mother.mat', [-100 100]);

%Parameters
fs = 25000;
Wid = [0.5 1.0];
wname = 'mea';
L = 0;
Ns = 5;
method = 'Manuel';
multiplier = 4;
refPeriod_ms = 1;
n_spikes_to_plot = 200;

%% PAT
path = '/Users/ssense/Desktop/MEA-analysis/Data/PV-ArchT/rawData/';
recording = 'PAT200219_2C_DIV170002.mat';

%% FTD
% path = '/Users/ssense/Desktop/MEA-analysis/Data/FTD/';
% recording = '200114_FTDOrg_GrpB_2A_Slice8.mat';

fileName = [path recording];
file = load(fileName);

newFileName = [recording(1:end-4),'_jSpikes_', wname, '_', num2str(-L),...
'_ns=', num2str(Ns), '.mat'];
savepath = '/Users/ssense/Desktop/MEA-analysis/troubleshooting/';

data = file.dat;
channels = file.channels;


for i = 1:60
    
    if strcmp(wname, 'mea') && ~contains(fileName, 'TTX');
        
        try
            ave_trace = getTemplate(data(:, i), method, multiplier, L, refPeriod_ms, n_spikes_to_plot);
        catch
            disp(['Failed to obtain mean waveform at electrode ', num2str(i)]);
        end
        
        try
            customWavelet(ave_trace);
        catch
            disp(['Failed to adapt custom wavelet at electrode ', num2str(i)]);
        end
    end
    
    try
        [spikeTrain, finalData, ~] = detectSpikesCWT(data(:, i), fs, Wid, wname, L, Ns);
    catch
        disp(['Failed to detect spikes at electrode ', num2str(i)]);
    end
    jSpikes(i, :) = spikeTrain;
end
jSpikes = jSpikes';

jSpikes = sparse(jSpikes);
save([savepath newFileName], 'jSpikes', 'L', 'channels');
