function [spikeFrames, filteredData, threshold] = detectFramesCWT(data, fs, Wid, wname, L, Ns, multiplier, n_spikes, ttx)

refPeriod_ms = 1;
method = 'Manuel';

% Filter signal
lowpass = 600;
highpass = 8000;
wn = [lowpass highpass] / (fs / 2);
filterOrder = 3;
[b, a] = butter(filterOrder, wn);
filteredData = filtfilt(b, a, double(data));

data = filteredData;

if strcmp(wname, 'mea') && ~ttx
    
    try
        ave_trace = getTemplate(data, method, multiplier, L, refPeriod_ms, n_spikes);
    catch
        disp(['Failed to obtain mean waveform']);
    end
    
    try
        customWavelet(ave_trace);
    catch
        disp(['Failed to adapt custom wavelet']);
    end
end

try
    spikeFrames = detect_spikes_wavelet(filteredData, fs/1000, Wid, Ns, 'c', L, wname, 0, 0);
    
    window = 10;
    for  i = 1:length(spikeFrames)
        if spikeFrames(i)+window < length(data)
            sFr(i) = find(data == min(data(spikeFrames(i)-window:spikeFrames(i)+window)));
        else
            sFr(i) = find(data == min(data(spikeFrames(i)-window:end)));
        end
    end
    
    spikeFrames = sFr;
    
catch
    disp(['Failed to detect spikes']);
end

threshold = multiplier*std(data);

end
