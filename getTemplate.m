function [ave_trace, spikeTrain] = getTemplate(data, multiplier, refPeriod_ms, n_spikes_to_plot)

[spikeTrain, ~, ~] = detectSpikes(data, multiplier, refPeriod_ms);


sp_times = find(spikeTrain == 1);

if  sum(spikeTrain) < n_spikes_to_plot
    % If fewer spikes than specified - use the maximum possible number
    n_spikes_to_plot = sum(spikeTrain);
    disp('Not enough spikes detected with specified threshold, using ',num2str(n_spikes_to_plot),'instead');
end

% Pick n_spikes at random (previously the initial 200 spikes were used)
% spikes2use = randi([5, length(sp_times)-5], 1, n_spikes_to_plot);

% Pick n_spikes uniformly
spikes2use = round(linspace(2, length(sp_times)-2, n_spikes_to_plot));



for i = 1:n_spikes_to_plot
    n = sp_times(spikes2use(i));
    bin = data(n-10:n+10);
    sp_peak_time = find(bin == min(bin))-11; % 11 = middle sample in bin 
    all_trace(:,i) = data(n+sp_peak_time-25:n+sp_peak_time+25);
end

try
    for i = 1:size(all_trace, 1)
        ave_trace(i) = median(all_trace(i,:));
    end
catch
    disp('Problem with ave trace');
end
end