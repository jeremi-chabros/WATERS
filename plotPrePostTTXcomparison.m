spikeDetectionResultDirName = '/media/timsit/T7/test-detection/results/';
plotFolder = '/media/timsit/T7/test-detection/results/plots/prePostTTX/';

% pre_post_TTX_pairs = {'2000803_slice3_6', '2000803_slice3_7_TTX'}; % N x 2 cell array, where N is the number of pre-post pairs 
% pre_post_TTX_pairs = {'191210_FTD_slice5_DIV_g07_2019_pre_ttx', '191210_FTD_slice5_DIV_g07_2019_ttx'};
pre_post_TTX_pairs = {'200114_FTDOrg_GrpB_1B_Slice3_pre_TTX', '200114_FTDOrg_GrpB_1B_Slice3_TTX'};
spike_features_to_extract = {'spikeWidth', 'spikeAmplitude'};


%% Compile data from pre/post TTX files

for pair_number = 1:size(pre_post_TTX_pairs, 1)
    
    pre_post_ttx_info = struct();
    
    pre_TTX_name = pre_post_TTX_pairs{pair_number, 1};
    post_TTX_name = pre_post_TTX_pairs{pair_number, 2};
    
    pre_TTX_detection_files = findParamFiles(spikeDetectionResultDirName, pre_TTX_name);
    post_TTX_detection_files = findParamFiles(spikeDetectionResultDirName, post_TTX_name);
    
    example_file = load(fullfile(spikeDetectionResultDirName, pre_TTX_detection_files{1}));
    % get the list of wavelets used to do the spike detection 
    wnameList = example_file.spikeDetectionResult.params.wnameList;
    
    % GO through pre-TTX file and extract data
    for pre_TTX_param_file_idx = 1:length(pre_TTX_detection_files)
        pre_TTX_param_file = pre_TTX_detection_files{pre_TTX_param_file_idx};
        file_components = split(pre_TTX_param_file, '_');
        % TODO: this part is very hacky, perhaps do split of 'L_' ?
        cost_param_cell_array = file_components(end-1);
        pre_TTX_L_param = str2num(cost_param_cell_array{1});
        pre_TTX_param_data = load(fullfile(spikeDetectionResultDirName, pre_TTX_param_file));
        
        recording_dur = pre_TTX_param_data.spikeDetectionResult.params.duration;
        
        for wnameIndex = 1:length(wnameList)
            wname = wnameList{wnameIndex};
            wname_processed = strrep(wname, '.', 'p');
            spike_rate_per_electrode = getSpikeRatePerElec(pre_TTX_param_data, recording_dur, wname_processed);
            pre_TTX_L_param_str = strcat('pre_TTX_L_param_idx_', num2str(pre_TTX_param_file_idx));
            pre_post_ttx_info.(wname_processed).(pre_TTX_L_param_str).L = pre_TTX_L_param;
            % Get spike rate info
            pre_post_ttx_info.(wname_processed).(pre_TTX_L_param_str).preTTXspikeRates = spike_rate_per_electrode;
            
            % Get spike properties
            for spike_prop_idx = 1:length(spike_features_to_extract)
                spike_prop = spike_features_to_extract{spike_prop_idx};
                
                spike_prop_per_electrode = getSpikePropPerElect(pre_TTX_param_data, spike_prop, wname_processed);
                spike_prop_name = strcat('preTTX_',spike_prop);
                pre_post_ttx_info.(wname_processed).(pre_TTX_L_param_str).(spike_prop_name) = spike_prop_per_electrode;
                
            end 
            
        end 
    end 
    
    % Do the exact same thing for post-TTX file (should generalize this so
    % there is no need to repeat this code)
    for post_TTX_param_file_idx = 1:length(post_TTX_detection_files)
        post_TTX_param_file = post_TTX_detection_files{post_TTX_param_file_idx};
        file_components = split(post_TTX_param_file, '_');
        % TODO: this part is very hacky, perhaps do split of 'L_' ?
        cost_param_cell_array = file_components(end-1);
        post_TTX_L_param = str2num(cost_param_cell_array{1});
        post_TTX_param_data = load(fullfile(spikeDetectionResultDirName, post_TTX_param_file));
        
        recording_dur = post_TTX_param_data.spikeDetectionResult.params.duration;
        
        for wnameIndex = 1:length(wnameList)
            wname = wnameList{wnameIndex};
            wname_processed = strrep(wname, '.', 'p');
            spike_rate_per_electrode = getSpikeRatePerElec(post_TTX_param_data, recording_dur, wname_processed);
            post_TTX_L_param_str = strcat('post_TTX_L_param_idx_', num2str(post_TTX_param_file_idx));
            pre_post_ttx_info.(wname_processed).(post_TTX_L_param_str).L = post_TTX_L_param;
            % Get spike rate info
            pre_post_ttx_info.(wname_processed).(post_TTX_L_param_str).postTTXspikeRates = spike_rate_per_electrode;
            
            % Get spike properties
            for spike_prop_idx = 1:length(spike_features_to_extract)
                spike_prop = spike_features_to_extract{spike_prop_idx};
                
                spike_prop_per_electrode = getSpikePropPerElect(post_TTX_param_data, spike_prop, wname_processed);
                spike_prop_name = strcat('postTTX_',spike_prop);
                pre_post_ttx_info.(wname_processed).(post_TTX_L_param_str).(spike_prop_name) = spike_prop_per_electrode;
                
            end 
            
        end 
    end 
    
    % TODO: fill in the plotting functions here to loop through all the pre
    % post TTX pairs
    
end 

%% Compare spikes pre-post TTX per electrode, and spike characteristics

wnames_to_plot = {'db2'};  % bior1p5 or db2

% currently only does spike width vs. amplitude, will generalized to more
% things...


for wname_index = 1:length(wnames_to_plot)
    
    wname = wnames_to_plot{wname_index};
    
    wname_pre_post_ttx_info = pre_post_ttx_info.(wname);
    for param_idx = 1:(length(fieldnames(wname_pre_post_ttx_info))/2)
        
        pre_TTX_info = wname_pre_post_ttx_info.(strcat('pre_TTX_L_param_idx_', num2str(param_idx)));
        post_TTX_info = wname_pre_post_ttx_info.(strcat('post_TTX_L_param_idx_', num2str(param_idx)));
        
        L = pre_TTX_info.L;  % TODO: double check this is same as post_TTX_info.L
        L_str = strrep(num2str(L), '.', 'p');
        
        % SPIKE RATES
        figure;
        
        max_pre_ttx_spike_rate = max(pre_TTX_info.preTTXspikeRates);
        min_pre_ttx_spike_rate = min(pre_TTX_info.preTTXspikeRates);
        max_post_ttx_spike_rate = max(post_TTX_info.postTTXspikeRates);
        min_post_ttx_spike_rate = max(post_TTX_info.postTTXspikeRates);
        
        min_spike_rate = min([min_pre_ttx_spike_rate, min_post_ttx_spike_rate]);
        max_spike_rate = max([max_pre_ttx_spike_rate, max_post_ttx_spike_rate]);
        unity_vals = linspace(min_spike_rate, max_spike_rate, 100);
        hold on;
        plot(unity_vals, unity_vals);
        
        scatter(pre_TTX_info.preTTXspikeRates, post_TTX_info.postTTXspikeRates)
        xlabel('Pre-TTX spike rates (spikes/s)');
        ylabel('Post-TTX spike rates (spikes/s)');
        
        xlim([min_spike_rate, max_spike_rate]); 
        ylim([min_spike_rate,  max_spike_rate]);
        
        set(gcf, 'PaperPosition', [0.25, 0.25, 10, 10])
        set(gcf, 'color', 'white')
        print(gcf, fullfile(plotFolder, strcat(wname, '_L_', L_str, 'pre_post_TTX_spikes', '.png')), '-dpng','-r300')
        close(gcf)
        
        % SPIKE PROPERTIES 
        % TODO: plot histogram for each of the stats
        figure;
        
        pre_TTX_all_electrode_spike_amplitude = vertcat(pre_TTX_info.preTTX_spikeAmplitude{:});
        pre_TTX_all_electrode_spike_width = vertcat(pre_TTX_info.preTTX_spikeWidth{:});
        post_TTX_all_electrode_spike_amplitude = vertcat(post_TTX_info.postTTX_spikeAmplitude{:});
        post_TTX_all_electrode_spike_width = vertcat(post_TTX_info.postTTX_spikeWidth{:});
        scatter(pre_TTX_all_electrode_spike_amplitude, pre_TTX_all_electrode_spike_width, 'r');
        hold on 
        scatter(post_TTX_all_electrode_spike_amplitude, post_TTX_all_electrode_spike_width, 'k');
        legend('Pre-TTX', 'Post-TTX')
        xlabel('Spike amplitude');
        ylabel('Spike width');
        set(gcf, 'color', 'white')
        set(gcf, 'PaperPosition', [0.25, 0.25, 10, 10])
        print(gcf, fullfile(plotFolder, strcat(wname, '_L_', L_str, 'pre_post_TTX_spikeProperties', '.png')), '-dpng','-r300')
        close(gcf)
        
        figure;
        subplot(3, 3, [4, 5, 7, 8])
        pre_TTX_all_electrode_spike_amplitude = vertcat(pre_TTX_info.preTTX_spikeAmplitude{:});
        pre_TTX_all_electrode_spike_width = vertcat(pre_TTX_info.preTTX_spikeWidth{:});
        post_TTX_all_electrode_spike_amplitude = vertcat(post_TTX_info.postTTX_spikeAmplitude{:});
        post_TTX_all_electrode_spike_width = vertcat(post_TTX_info.postTTX_spikeWidth{:});
        scatter(pre_TTX_all_electrode_spike_amplitude, pre_TTX_all_electrode_spike_width, 'r');
        hold on 
        scatter(post_TTX_all_electrode_spike_amplitude, post_TTX_all_electrode_spike_width, 'k');
        legend('Pre-TTX', 'Post-TTX')
        xlabel('Spike amplitude');
        ylabel('Spike width');
        set(gcf, 'color', 'white')
        set(gcf, 'PaperPosition', [0.25, 0.25, 13, 13])
        hold on 
        % include histogram 
        subplot(3, 3, [1, 2])
        min_spike_amp = min([min(pre_TTX_all_electrode_spike_amplitude), ...
                             min(post_TTX_all_electrode_spike_amplitude), ...
                            ]);
        max_spike_amp = max([max(pre_TTX_all_electrode_spike_amplitude), ...
                             max(post_TTX_all_electrode_spike_amplitude), ...
                            ]);
                        
            
        amp_edges = linspace(min_spike_amp, max_spike_amp, 50);
        [pre_ttx_spike_amp_counts, edges] = histcounts(pre_TTX_all_electrode_spike_amplitude, amp_edges, 'Normalization', 'pdf');
        [post_ttx_spike_amp_counts, edges] = histcounts(post_TTX_all_electrode_spike_amplitude, amp_edges, 'Normalization', 'pdf');
        plot(amp_edges(2:end), pre_ttx_spike_amp_counts, 'color', 'r', 'linewidth', 2);
        hold on
        plot(amp_edges(2:end), post_ttx_spike_amp_counts, 'color', 'k', 'linewidth', 2);
        ylabel('Probability density')
        
        
        subplot(3, 3, [6, 9])
        
        min_spike_width = min([min(pre_TTX_all_electrode_spike_width), ...
                             min(post_TTX_all_electrode_spike_width), ...
                            ]);
        max_spike_width = max([max(pre_TTX_all_electrode_spike_width), ...
                             max(post_TTX_all_electrode_spike_width), ...
                            ]);
                        
            
        width_edges = linspace(min_spike_width, max_spike_width, 50);
        [pre_ttx_spike_width_counts, edges] = histcounts(pre_TTX_all_electrode_spike_width, width_edges, 'Normalization', 'pdf');
        [post_ttx_spike_width_counts, edges] = histcounts(post_TTX_all_electrode_spike_width, width_edges, 'Normalization', 'pdf');
        plot(pre_ttx_spike_width_counts, width_edges(2:end), 'color', 'r', 'linewidth', 2);
        hold on
        plot(post_ttx_spike_width_counts, width_edges(2:end), 'color', 'k', 'linewidth', 2);
        xlabel('Probability density')
        
        print(gcf, fullfile(plotFolder, strcat(wname, '_L_', L_str, 'pre_post_TTX_spikeProperties_w_histogram', '.png')), '-dpng','-r300')
        close(gcf)
        
        %% Subset electrodes where pre-TTX > post-TTX
        active_electrode_idx = find(pre_TTX_info.preTTXspikeRates > post_TTX_info.postTTXspikeRates);
        
        figure;
        subplot(3, 3, [4, 5, 7, 8])
        pre_TTX_all_electrode_spike_amplitude = vertcat(pre_TTX_info.preTTX_spikeAmplitude{active_electrode_idx});
        pre_TTX_all_electrode_spike_width = vertcat(pre_TTX_info.preTTX_spikeWidth{active_electrode_idx});
        post_TTX_all_electrode_spike_amplitude = vertcat(post_TTX_info.postTTX_spikeAmplitude{active_electrode_idx});
        post_TTX_all_electrode_spike_width = vertcat(post_TTX_info.postTTX_spikeWidth{active_electrode_idx});
        scatter(pre_TTX_all_electrode_spike_amplitude, pre_TTX_all_electrode_spike_width, 'r');
        hold on 
        scatter(post_TTX_all_electrode_spike_amplitude, post_TTX_all_electrode_spike_width, 'k');
        legend('Pre-TTX', 'Post-TTX')
        xlabel('Spike amplitude');
        ylabel('Spike width');
        title('Electrodes where pre-TTX > post-TTX spike rate')
        set(gcf, 'color', 'white')
        set(gcf, 'PaperPosition', [0.25, 0.25, 13, 13])
        hold on 
        % include histogram 
        subplot(3, 3, [1, 2])
        min_spike_amp = min([min(pre_TTX_all_electrode_spike_amplitude), ...
                             min(post_TTX_all_electrode_spike_amplitude), ...
                            ]);
        max_spike_amp = max([max(pre_TTX_all_electrode_spike_amplitude), ...
                             max(post_TTX_all_electrode_spike_amplitude), ...
                            ]);
                        
            
        amp_edges = linspace(min_spike_amp, max_spike_amp, 50);
        [pre_ttx_spike_amp_counts, edges] = histcounts(pre_TTX_all_electrode_spike_amplitude, amp_edges, 'Normalization', 'pdf');
        [post_ttx_spike_amp_counts, edges] = histcounts(post_TTX_all_electrode_spike_amplitude, amp_edges, 'Normalization', 'pdf');
        plot(amp_edges(2:end), pre_ttx_spike_amp_counts, 'color', 'r', 'linewidth', 2);
        hold on
        plot(amp_edges(2:end), post_ttx_spike_amp_counts, 'color', 'k', 'linewidth', 2);
        ylabel('Probability density')
        
        
        subplot(3, 3, [6, 9])
        
        min_spike_width = min([min(pre_TTX_all_electrode_spike_width), ...
                             min(post_TTX_all_electrode_spike_width), ...
                            ]);
        max_spike_width = max([max(pre_TTX_all_electrode_spike_width), ...
                             max(post_TTX_all_electrode_spike_width), ...
                            ]);
                        
            
        width_edges = linspace(min_spike_width, max_spike_width, 50);
        [pre_ttx_spike_width_counts, edges] = histcounts(pre_TTX_all_electrode_spike_width, width_edges, 'Normalization', 'pdf');
        [post_ttx_spike_width_counts, edges] = histcounts(post_TTX_all_electrode_spike_width, width_edges, 'Normalization', 'pdf');
        plot(pre_ttx_spike_width_counts, width_edges(2:end), 'color', 'r', 'linewidth', 2);
        hold on
        plot(post_ttx_spike_width_counts, width_edges(2:end), 'color', 'k', 'linewidth', 2);
        xlabel('Probability density')
        
        print(gcf, fullfile(plotFolder, strcat(wname, '_L_', L_str, 'pre_post_TTX_spikeProperties_w_histogram_subset_active', '.png')), '-dpng','-r300')
        close(gcf)
        
        
    end 
    

    
end






%% small function to find all parameter files

function fileList = findParamFiles(spikeDetectionResultDirName, recording_name)
    
    fileList = {};
    all_files = {dir(fullfile(spikeDetectionResultDirName)).name};
    
    for file_idx = 1:length(all_files)
        
        if contains(all_files{file_idx}, recording_name)
            fileList = vertcat(fileList, all_files{file_idx});
        end 
        
    end 


end 

%% small function to get spike per electrode from the spikeDetectionResult file 

function spike_rate_per_electrode = getSpikeRatePerElec(spikeDetectionData, duration, detection_method)
    
    num_electrode = length(spikeDetectionData.spikeTimes);
    spike_rate_per_electrode = zeros(num_electrode, 1);
    
    for electrode_index = 1:num_electrode
        spike_rate_per_electrode(electrode_index) = length(...
            spikeDetectionData.spikeTimes{electrode_index}.(detection_method) ...
        );
    end 
    
    % Convert from spike count to spikes/s
    spike_rate_per_electrode = spike_rate_per_electrode / duration; 
    
end

%% Small function to get spike property per electrode from spikeDetectionResult file 
function spike_prop_per_electrode = getSpikePropPerElect(spikeDetectionData, spikeProp, detection_method)
    peak_x = 25;  % HARD-CODED: assumes that spike is aligned to peak with 25 time bins left and 25 time bins right
    fs = 25000;
    num_electrode = length(spikeDetectionData.spikeTimes);
    spike_prop_per_electrode = cell(num_electrode, 1);
    for electrode_index = 1:num_electrode
        
        if strcmp(spikeProp, 'spikeWidth')
           spikeWaveforms = spikeDetectionData.spikeWaveforms{electrode_index}.(detection_method);
           num_spikes = size(spikeWaveforms, 1);
           spike_widths = zeros(num_spikes, 1);
           spike_amplitude = spikeWaveforms(:, peak_x);
           for spike_idx = 1:size(spikeWaveforms)
                spike_wave = spikeWaveforms(spike_idx, :);

                half_peak_y = spike_amplitude(spike_idx) / 2;
                cross_half_peak_x = find(spike_wave > half_peak_y);

                % Find latest time of crossing half_peak_y before peak 
                % And find earliest time of crossing half_peak_y after peak
                half_peak_x1 = max(cross_half_peak_x(cross_half_peak_x < peak_x));
                half_peak_x2 = min(cross_half_peak_x(cross_half_peak_x > peak_x));
                spike_widths(spike_idx) = (half_peak_x2 - half_peak_x1) / fs;
           end
           
           spike_prop_per_electrode{electrode_index} = spike_widths;
           
        elseif strcmp(spikeProp, 'spikeAmplitude')
            spikeWaveforms = spikeDetectionData.spikeWaveforms{electrode_index}.(detection_method);
            spike_amplitude = spikeWaveforms(:, peak_x);
            spike_prop_per_electrode{electrode_index} = spike_amplitude;
            
        end
        
        
    end 

end 

