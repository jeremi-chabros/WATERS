function [spikeTrain, finalData, threshold] = detectSpikesCWT(data, fs, Wid, wname, L, Ns)
%%   Filter
lowpass = 600;
highpass = 8000;
wn = [lowpass highpass] / (fs / 2);
filterOrder = 3;
[b, a] = butter(filterOrder, wn);
filteredData = filtfilt(b, a, double(data));

%%   Detect spikes
jSpikes = zeros(1, length(data));

try
    spikeFrames = detect_spikes_wavelet(filteredData, fs/1000, Wid, Ns, 'c', L, wname, 0, 0);
catch
    disp('Wavelet not supported');
end
spikeTrain = zeros(1, length(data));
spikeTrain(spikeFrames) = 1;
jSpikes = spikeTrain;

threshold = NaN;
finalData = filteredData;
spikeTrain = jSpikes;
end