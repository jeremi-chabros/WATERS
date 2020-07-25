function [spikeFrames, filteredData, threshold] = detectFramesCWT(data, fs, Wid, wname, L, Ns, multiplier, n_spikes, ttx)

refPeriod_ms = 1;
method = 'Manuel';

%%  Filter signal

% %    2-D
lowpass = 600;
highpass = 8000;
wn = [lowpass highpass] / (fs / 2);
filterOrder = 3;
[b, a] = butter(filterOrder, wn);
filteredData = filtfilt(b, a, double(data));

data = filteredData;

threshold = mad(filteredData)/0.6745;
minThreshold = -threshold*2;
peakThreshold = -threshold*15;
posThreshold = threshold*3;

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
    
    sFr = [];
    spikeFrames = detect_spikes_wavelet(filteredData, fs/1000, Wid, Ns, 'l', L, wname, 0, 0);
    
    win = 10;    % Frames; ms = window/25
    
    for i = 1:length(spikeFrames)
        if spikeFrames(i)+win < length(data)
            
            bin = filteredData(spikeFrames(i)-win:spikeFrames(i)+win);
            negativePeak = min(bin);

            posPeaks = findpeaks(bin);
            positivePeak = max(posPeaks);
            crossings = posPeaks > 2*threshold;
            
            pos = find(bin == negativePeak);

                if negativePeak > peakThreshold && negativePeak < minThreshold
                    if max(bin) < posThreshold
                    sFr = [sFr (spikeFrames(i)+pos-win)];
                    end
                end

            
        else
            bin = filteredData(spikeFrames(i)-win:end);
            negPeaks = findpeaks(-bin);
            negativePeak = -max(negPeaks);
            
            thresholdCrossings = find(-negPeaks < minThreshold);
            
            posPeaks = findpeaks(bin);
            positivePeak = max(posPeaks);
            
            pos = find(bin == negativePeak);
            
            if negativePeak > peakThreshold && negativePeak < minThreshold
                sFr = [sFr (spikeFrames(i)+pos-win)];
            end
            
        end
    end
    spikeFrames = sFr;
    
catch
    disp(['Failed to detect spikes']);
end
threshold = multiplier*threshold;
end
