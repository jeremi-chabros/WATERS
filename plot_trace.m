clearvars; clc; close all;
% addpath('C:\Users\Sand Box\Dropbox (Cambridge University)\NOG MEA Data\MEA2100 Organoid\all_mat_organoid');
% files = vertcat(dir('*-0.3*.mat'), dir('*-0.4*.mat'));
% files = dir('C:\Users\Sand Box\jjc\new_organoid_spikes\*.mat');
files = dir('*.mat');
%%
for file = 1:length(files)
    % for file = 1:1
    %
    close all;
    spike_file_name = files(file).name;
    raw_file_name = [spike_file_name(1:strfind(spike_file_name, '_L_')-1) '.mat'];
    culture_name = strrep(raw_file_name(1:end-4),'_',' ');
    
    
    load(spike_file_name);
    if ~exist([culture_name spikeDetectionResult.params.save_suffix '_ALL.pdf'],'file')
        load(raw_file_name);
        
        dat = double(dat);
        filtered_data = zeros(size(dat));
        num_chan = size(dat,2);
        
        
        for ch = 1:num_chan
            lowpass = 600;
            highpass = 8000;
            wn = [lowpass highpass] / (fs / 2);
            filterOrder = 3;
            [b, a] = butter(filterOrder, wn);
            filtered_data(:,ch) = filtfilt(b, a, dat(:,ch));
        end
        
        methods = fieldnames(spikeTimes{1});
        methods = sort(methods);
        
        bin_s = 10;
        fs = spikeDetectionResult.params.fs;
        duration_s = round(spikeDetectionResult.params.duration);
        unit = spikeDetectionResult.params.unit;
        channel = 15;
        while channel == 15
            channel = randi([1,num_chan],1);
        end
        trace = filtered_data(:, channel);
        threshold = mean(trace) - (median(abs(trace - mean(trace)))/0.6745);
        %%
        close all
        dSampF = 250;
        for i = 1:length(methods)
            spk_vec_all = zeros(1, duration_s*fs);
            spk_matrix = zeros(num_chan, duration_s*fs/dSampF);
            method = methods{i};
            for j = 1:num_chan
                switch unit
                    case 's'
                        spk_times = round(spikeTimes{j}.(method)*fs);
                    case 'ms'
                        spk_times = round(spikeTimes{j}.(method)*fs/1000);
                    case 'frames'
                        spk_times = round(spikeTimes{j}.(method));
                end
                spike_times{j}.(method) = spk_times;
                spike_count(j) = length(spk_times);
                spk_vec = zeros(1, duration_s*fs);
%                 spk_vec = zeros(1, duration_s);
                spk_vec(spk_times) = 1;
                spk_vec = spk_vec(1:duration_s*fs);
                spk_vec_all = spk_vec_all+spk_vec;
                spk_matrix(j,:) = nansum(reshape([spk_vec(:); nan(mod(-numel(spk_vec),dSampF),1)],dSampF,[]));
            end
            spike_counts.(method) = spike_count;
            spike_freq.(method) = spike_count/duration_s;
            spk_matrix_all.(method) = spk_matrix;
            plot(movmean(spk_vec_all, bin_s*fs), 'linewidth', 2)
            hold on
        end
        xticks(linspace(1, duration_s*fs,10));
        xticklabels(round(linspace(1, duration_s, 10)));
        pbaspect([2,1,1])
        set(gcf, 'unit','inches');
        pos = get(gcf, 'position');
        set(gcf, 'position', [pos(1) pos(2) 8 4]);
        box off
        legend(strrep(methods, 'p','.'), 'location','northeastoutside');
        xlabel('Time (s)');
        yticklabels(get(gca, 'ytick')*bin_s)
        ylabel('Spiking frequency (Hz)');
        title(culture_name)
        set(gcf,'color','w');
%         culture_name = ['..\pdfs\' culture_name spikeDetectionResult.params.save_suffix '_ALL'];
culture_name = [culture_name spikeDetectionResult.params.save_suffix '_ALL'];
        export_fig(culture_name, '-pdf');
        %%
        for l = 1:15 %times 15
            % for l = 1:1 %times 1
            bin_ms = 30;
            channel = 15;
            while channel == 15
                channel = randi([1,num_chan],1);
            end
            trace = filtered_data(:, channel);
            threshold = median(trace) - 2.5*spikeDetectionResult.params.mad(channel);
            close all;
            tiledlayout(4,1, 'padding','none','tilespacing','none')
            for p = 1:4
                nexttile
                cmap = jet;
                colors = round(linspace(1,256,length(methods)));
                plot(trace, 'k-')
                hold on
                
                for m = 1:length(methods)
                    method = methods{m};
                    spike_train = spikeTimes{channel}.(method);
                    
                    switch spikeDetectionResult.params.unit
                        case 's'
                            spike_train = spike_train * fs;
                        case 'ms'
                            spike_train = spike_train * fs/1000;
                        case 'frames'
                    end
                    color = parula(colors(m));
                    scatter(spike_train, repmat(5*std(trace)-m*(0.5*std(trace)), length(spike_train), 1), 15, 'v', 'filled','markerfacecolor',cmap(colors(m),:), 'markeredgecolor', 'k', 'linewidth',0.1);
                    
                    
                end
                methodsl = strrep(methods, 'p','.');
                
                st = randi([1 length(spike_train)]);
                st = spike_train(st);
                if st+15*25 < length(trace)
                    xlim([st-bin_ms*25 st+bin_ms*25]);
                else
                    xlim([st-bin_ms*25 inf]);
                end
                ylim([-6*std(trace) 5*std(trace)])
                box off
                set(gca,'xcolor','none');
                set(gcf, 'unit','inches');
                pos = get(gcf,'position');
                set(gcf,'position', [pos(1) pos(2) 8 11]);
                ylabel('Amplitude (\muV)');
                axis fill
                %             pbaspect([4,1,1]);
                yl = yline(threshold, 'r--');
                yl.LineWidth = 1.5;
                title({["Electrode "+channel], [(st-bin_ms*25)/25000 + " - " + (st+bin_ms*25)/25000 + " s"]})
                legend('Filtered voltage trace', methodsl{:}, ['Thr = ' num2str(round(threshold,2)) ' \muV'], 'location','bestoutside');
            end
            export_fig([culture_name ' ' num2str(l)], '-pdf');
            %         print([culture_name ' ' num2str(l)],'-dpdf','-fillpage');
            append_pdfs([culture_name, '.pdf'], [culture_name ' ' num2str(l) '.pdf']);
            delete([culture_name ' ' num2str(l) '.pdf']);
        end
        
        
        %%
        for m = 1:length(methods)
            method = methods{m};
            maxF(m) = max(spike_freq.(method));
        end
        maxF = max(maxF);
        %%
        if num_chan == 60
            close all;
            tiledlayout(3,3, 'padding','none','tilespacing','none')
            for m = 1:length(methods)
                method = methods{m};
                nexttile
                [f,cbar] = customHeatmap(spike_freq.(method), 'markersize', 100,...
                    'cbarLimits', [1, maxF]);
                axis square
                title({[''],[strrep(method,'p','.')]});
            end
            set(gcf,'units','inches');
            pos = get(gcf,'position');
            set(gcf, 'position', [pos(1), pos(2), 8, 8]);
            
            export_fig([culture_name ' ' num2str(l+1)], '-pdf');
            append_pdfs([culture_name, '.pdf'], [culture_name ' ' num2str(l+1) '.pdf']);
            delete([culture_name ' ' num2str(l+1) '.pdf']);
        end
        %%
        close all;
        t = tiledlayout(length(methods),1, 'padding','none','tilespacing','none');
        
        t.Title.String = culture_name;
        
        t.Title.Interpreter = 'none';
        
        for m = 1:length(methods)
            method = methods{m};
            nexttile
            imagesc(spk_matrix_all.(method));
            xlim([1 length(spk_matrix_all.(method))/2])
            axis fill
            box off
            ylabel(strrep(method,'p','.'));
            %         set(gca, 'units', 'inches');
            %         set(gca, 'position', []);
        end
        set(gcf, 'units','inches');
        pos = get(gcf,'position');
        set(gcf,'position', [pos(1), pos(2), 8, 11]);
        
        %     print([culture_name ' ' num2str(l+2)],'-dpdf','-fillpage');
        export_fig([culture_name ' ' num2str(l+2)],'-pdf');
        append_pdfs([culture_name, '.pdf'], [culture_name ' ' num2str(l+2) '.pdf']);
        delete([culture_name ' ' num2str(l+2) '.pdf']);
        
        %%
        clc
        [~, unique_idx, intersect_matrix] = mergeSpikes(spike_times{channel},'all');
        methods = fieldnames(spikeTimes{1});
        t = tiledlayout(1, length(methods), 'tilespacing','none','padding','none');
        t.Title.String = "Unique spikes by method from el " + channel;
        
        %%
        close all;
        t = tiledlayout(2, ceil(length(methods)/2), 'tilespacing','none','padding','none');
        t.Title.String = {["Unique spikes by method from electrode " + channel],['']};
        for i = 1:length(methods)
            method = methods{i};
            if ~strcmp(method, 'all')
                spk_method = find(unique_idx == i);
                spk_waves_method = spikeWaveforms{channel}.(method);
                if size(spk_waves_method,2) > 1000
                    spk_waves_method = spk_waves_method(:, round(linspace(1,length(spk_waves_method),1000)));
                end
                nexttile
                plot(spk_waves_method', 'linewidth', 0.1, 'color', [0.7 0.7 0.7])
                hold on
                plot(mean(spk_waves_method), 'linewidth', 1.5, 'color', [0 0 0])
                title({[method]})
                box off;
                axis tight
                pbaspect([1,2,1]);
                ylim([-6*std(trace) 5*std(trace)]);
                ylabel('Voltage [\muV]')
                set(gca, 'xcolor', 'none');
                yl=yline(3*threshold, 'r--');
                yl.LineWidth = 2;
            end
        end
        %     print([culture_name ' ' num2str(l+3)],'-dpdf','-fillpage');
        set(gcf,'units','inches');
        pos = get(gcf,'position');
        set(gcf, 'position',[pos(1) pos(2) 8 11]);
        export_fig([culture_name ' ' num2str(l+3)],'-pdf');
        append_pdfs([culture_name, '.pdf'], [culture_name ' ' num2str(l+3) '.pdf']);
        delete([culture_name ' ' num2str(l+3) '.pdf']);
    end
end