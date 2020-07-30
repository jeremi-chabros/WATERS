function [spikeFrames, filteredData, threshold] = detectFramesCWT(data, fs, Wid, wname, L, Ns, multiplier, n_spikes, ttx)

refPeriod_ms = 1;
method = 'Manuel';

%  Filter signal
lowpass = 600;
highpass = 8000;
wn = [lowpass highpass] / (fs / 2);
filterOrder = 3;
[b, a] = butter(filterOrder, wn);
filteredData = filtfilt(b, a, double(data));

data = filteredData;

%   Set thresholds
threshold = mad(filteredData, 1)/0.6745;
minThreshold = -threshold*2;    % min spike peak voltage
peakThreshold = -threshold*15;  % max spike peak voltage
posThreshold = threshold*3;     % positive peak voltage 

%   If using custom template:
if strcmp(wname, 'mea') && ~ttx
    
    %   Use threshold-based spike detection to obtain the median waveform
    %   from n_spikes
    try
        ave_trace = getTemplate(data, method, multiplier, L, refPeriod_ms, n_spikes);
    catch
        disp(['Failed to obtain mean waveform']);
    end
    
    %   Adapt a custom template from the spike waveform obtained above
    try
        customWavelet(ave_trace);
    catch
        disp(['Failed to adapt custom wavelet']);
    end
end

%   Detect spikes
try
    
    sFr = [];
    spikeFrames = detect_spikes_wavelet(filteredData, fs/1000, Wid, Ns, 'l', L, wname, 0, 0);
    
    win = 10;    % [frames]; [ms] = window/25
    
    %   Align the spikes by the negative peak
    %   Post-hoc artifact removal:
    %       a) max -ve peak voltage
    %       b) min -ve pak voltage
    %       c) +ve peak voltage
    for i = 1:length(spikeFrames)
        if spikeFrames(i)+win < length(data)
            
            %   Look into a 10-frame (0.4 ms) window around the spike
            bin = filteredData(spikeFrames(i)-win:spikeFrames(i)+win);
            
            %   Obtain peak voltages
            negativePeak = min(bin);
            posPeaks = findpeaks(bin);
            positivePeak = max(posPeaks);
            
            pos = find(bin == negativePeak);
            
            %   Remove the artifacts
                if negativePeak > peakThreshold && negativePeak < minThreshold
                    if max(bin) < posThreshold
                    sFr = [sFr (spikeFrames(i)+pos-win)];
                    end
                end
                
            % TODO: look into constraining the half-width of a spike  
        end
    end
    spikeFrames = sFr;
    
catch
    disp(['Failed to detect spikes']);
end
threshold = multiplier*threshold;
end
