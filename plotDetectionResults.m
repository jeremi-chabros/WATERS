function plotDetectionResults(spikeDetectionResultDirName, plotFolder)


spikeDetectionFiles = dir(fullfile(spikeDetectionResultDirName, '*.mat'));


for nFile = 1:length(spikeDetectionFiles)
    
    spikeDetectionResultName =  spikeDetectionFiles(nFile).name;
    load(fullfile(spikeDetectionFiles(nFile).folder, spikeDetectionResultName))
    numChannel = length(spikeWaveforms);
    spikeDetectionMethods = fieldnames(spikeWaveforms{1});
    nSpikeDetectionMethods = length(spikeDetectionMethods);
    
    % Spike amplitude summary plot
    num_y_pixels = 300;
    num_x_pixels = num_y_pixels * nSpikeDetectionMethods;
    spkAmpitudePlot = figure('Position', [500, 500, num_x_pixels, num_y_pixels]); 
    all_ax = [];
    hold all 
    for nMethod = 1:nSpikeDetectionMethods
        all_channel_spike_amplitudes = [];
        method_name = spikeDetectionMethods{nMethod};
        
        if strcmp(method_name, 'mea')
            for channel = 1:numChannel
                channel_methods = fieldnames(spikeWaveforms{channel});
                channel_mea_index = find(contains(channel_methods, 'mea'));
                channel_mea_methods = channel_methods(channel_mea_index);
                tot_mea_methods = length(channel_mea_methods);
                for n_mea_method = 1:tot_mea_methods
                    channel_wave_forms = spikeWaveforms{channel}.(channel_mea_methods{n_mea_method});
                    channel_spike_amp = min(channel_wave_forms, [], 2);
                    all_channel_spike_amplitudes = [all_channel_spike_amplitudes; channel_spike_amp];
                end 
            end 
        else
            for channel = 1:numChannel
                channel_wave_forms = spikeWaveforms{channel}.(method_name);
                channel_spike_amp = min(channel_wave_forms, [], 2);
                all_channel_spike_amplitudes = [all_channel_spike_amplitudes; channel_spike_amp];
            end 
        end 
        
        
        all_ax(nMethod) = subplot(1, nSpikeDetectionMethods, nMethod);
        histogram(all_channel_spike_amplitudes)
        title(method_name)
        
        if nMethod == 1
            ylabel('Number of spikes')
            xlabel('Spike amplitude')
        end 
        
    end 
    linkaxes(all_ax, 'xy')
    set(gcf, 'color', 'white')
    print(gcf, fullfile(plotFolder, strcat(spikeDetectionResultName, '_spikeAmplitude.png')), '-dpng','-r300')
    close(gcf)
    
end 





end 