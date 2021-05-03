function [aveWaveform, spikeTimes] = getTemplate(trace, multiplier, refPeriod, fs, nSpikes, multiple_templates)

% Description:
%   Obtain median waveform from spikes detected with threshold method

% INPUT:
%   trace: [n x 1] filtered voltage trace
%   multiplier: [scalar] threshold multiplier used for spike detection
%   refPeriod: [scalar] refractory period [ms] after a spike in which
%                       no spikes will be detected
%   fs: [scalar] sampling freqency in [Hz]
%   nSpikes: [scalar] the number of spikes used to obtain average waveform
%   multiple_templates : [bool] whether to extract multiple templates from
%   the data, if True, then aveWaveform will be a matrix of waveforms
%   instead of a vector 


% OUTPUT:
%   aveWaveform: [51 x 1] average spike waveform
%   spikeTimes: [#spikes x 1] vector containing detected spike times

% Author:
%   Jeremy Chabros, University of Cambridge, 2020
%   email: jjc80@cam.ac.uk
%   github.com/jeremi-chabros
% Mod logs
% 2021-05-02: TS: clarifying some param names

spike_window = 10;  % window around spike in frames, so 10/25000 = 0.4 ms
remove_artifact = 0;

if ~exist('multiple_templates', 'var')
    multiple_templates = 0;
end 
    



[spikeTrain, ~, ~] = detectSpikesThreshold(trace, multiplier, refPeriod, fs, 0);
spikeTimes = find(spikeTrain == 1);
[spikeTimes, spikeWaveforms] = alignPeaks(spikeTimes, trace, spike_window, remove_artifact);

%  If fewer spikes than specified - use the maximum number possible
if  numel(spikeTimes) < nSpikes
    nSpikes = sum(spikeTrain);
    disp(['Not enough spikes detected with specified threshold, using ', num2str(nSpikes),'instead']);
end

% Uniformly sample n_spikes
% TS: this will fail if there are fewer then 3 spikes, but I think that's
% okay
% This also misses the first and last spike, eg. if nSpikes ==
% sum(spikeTrain), then spikes2use will have duplicate values, but that's 
% not critical as well, won't fix for now.
if ~multiple_templates
    spikes2use = round(linspace(2, length(spikeTimes)-2, nSpikes));

    % TS: Take the median to avoid outliers (?)
    aveWaveform = median(spikeWaveforms(spikes2use,:));
else
    % extract mulitple templates by first performing PCA, then 
    % doing clustering and finding the optimal number of clusters
    
    % do PCA all detected spikes 
    [coeff, score, latent, tsquared, explained, mu] = pca(spikeWaveforms');
    num_PC = 2;
    reduced_X = coeff(:, 1:num_PC);
    
    % cluster in PCA space     
    minClustNum = 1;
    clusterer = HDBSCAN(reduced_X); 
    clusterer.minClustNum = minClustNum;
    clusterer.fit_model(); 			% trains a cluster hierarchy
    clusterer.get_best_clusters(); 	% finds the optimal "flat" clustering scheme
    clusterer.get_membership();		% assigns cluster labels to the points in X

    clustering_labels = clusterer.labels;
    unique_clusters = unique(clustering_labels);
    num_cluster = length(unique_clusters);
    
    fprintf('Doing clustering of spikes in PCA space \n')
    fprintf( 'Number of points: %i \n',clusterer.nPoints );
    fprintf( 'Number of dimensions: %i \n',clusterer.nDims );
    
    num_spike_time_frames = size(spikeWaveforms, 2);
    aveWaveform = zeros(num_spike_time_frames, num_cluster);
    
    % Make average waveform for each cluster 
    for cluster_label_idx = 1:num_cluster
        cluster_label = unique_clusters(cluster_label_idx);
        label_idx = find(clustering_labels == cluster_label);
        cluster_ave_waveform = median(spikeWaveforms(label_idx, :));
        aveWaveform(:, cluster_label_idx) = cluster_ave_waveform;
    end 

    % Plot to look at PCA
    debug_plot = 0;
    
    if debug_plot
        figure;
        for cluster_label_idx = 1:num_cluster
            cluster_label = unique_clusters(cluster_label_idx);
            label_idx = find(clustering_labels == cluster_label);
            subplot(1, 2, 1)
            scatter(reduced_X(label_idx, 1), reduced_X(label_idx, 2));
            hold on
            xlabel('PC1')
            ylabel('PC2')
            title_txt = sprintf('Cluster %.f', cluster_label); 
            title(title_txt);
            % ylim([y_min, y_max]);
            xlabel('Time bins')
        end 
        
        subplot(1, 2, 2)
        for cluster_label_idx = 1:num_cluster
            plot(aveWaveform(:, cluster_label_idx))
            hold on
        end 
    end 
    
end 

end