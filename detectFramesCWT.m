function [spikeFrames, spikeWaveforms, filteredData, threshold] = detectFramesCWT(...
    data, fs, Wid, wname, L, Ns, multiplier, n_spikes, ttx, ...
    minPeakThrMultiplier, maxPeakThrMultiplier, posPeakThrMultiplier)

% Input:
%
%   data - 1 x n extracellular voltage trace to be analyzed
%
%   fs - sampling frequency [Hz]
%
%   Wid - 1 x 2 vector of expected minimum and maximum width [ms] of
%         transient to be detected Wid=[Wmin Wmax]
%         For most practical purposes Wid=[0.5 1.0]
%
%   wname - (string): the name of wavelet family in use
%       'bior1.5' - biorthogonal
%       'bior1.3' - biorthogonal
%       'db2'     - Daubechies
%       'mea'     - custom wavelet (https://github.com/jeremi-chabros/CWT)
%
%       Note: sym2 and db2 differ only by sign --> they produce the same
%       result
%
%	L - the factor that multiplies [cost of comission]/[cost of omission].
%       For most practical purposes -0.2 <= L <= 0.2. Larger L --> omissions
%       likely, smaller L --> false positives likely.
%       For unsupervised detection, the suggested value of L is close to 0
%
%   Ns - (scalar): the number of scales to use in detection (Ns >= 2)
%
%   multiplier - the threshold multiplier used for detection
%
%   n_spikes - the number of spikes used to adapt a custom wavelet
%
%   ttx - flag for the recordings with TTX added: 1 = TTX, 0 = control


% Output:
%
%   spikeFrames - vector containing frames where spikes were detected (divided
%               by fs yields spike times)
%
%   spikeWaveforms - matrix containing spike waveforms
%
%   filteredData - filtered trace
%
%   threshold - median absolute deviation of the voltage amplitudes in
%   trace


refPeriod_ms = 2;

%  Filter signal
lowpass = 600;
highpass = 8000;
wn = [lowpass highpass] / (fs / 2);
filterOrder = 3;
[b, a] = butter(filterOrder, wn);
filteredData = filtfilt(b, a, double(data));

% threshold = mad(filteredData, 1)/0.6745;
threshold = median(abs(filteredData - mean(filteredData))) / 0.6745;
minPeakThr = -threshold * minPeakThrMultiplier;
maxPeakThr = -threshold * maxPeakThrMultiplier;
posPeakThr = threshold * posPeakThrMultiplier;

win = 25;   % [frames]; [ms] = window/25

if strcmp(wname, 'mea') && ~ttx
    
    %   Use threshold-based spike detection to obtain the median waveform
    %   from n_spikes
    try
        [ave_trace, ~] = getTemplate(data, multiplier, refPeriod_ms, n_spikes);
    catch
        disp(['Failed to obtain mean waveform']);
    end
    
    %   Adapt custom wavelet from the waveform obtained above
    try
        customWavelet(ave_trace);
    catch
        disp(['Failed to adapt custom wavelet']);
    end
end

%   Detect spikes
try
    
    sFr = [];
    spikeWaveforms = [];
    
    spikeFrames = detect_spikes_wavelet(filteredData, fs/1000, Wid, Ns, 'c', L, wname, 0, 0);
    %   Align the spikes by negative peaks
    %   Post-hoc artifact removal:
    %       a) max -ve peak voltage
    %       b) min -ve pak voltage
    %       c) +ve peak voltage
    
    for i = 1:length(spikeFrames)
        if spikeFrames(i)+win < length(data) && spikeFrames(i)-win > 1
            
            %   Look into a window around the spike
            bin = filteredData(spikeFrames(i)-win:spikeFrames(i)+win);
            
            %   Obtain peak voltages
            negativePeak = min(bin);
            positivePeak = max(bin);
            pos = find(bin == negativePeak);
            
            %   Remove the artifacts
            if negativePeak < minPeakThr && positivePeak < posPeakThr
                sFr = [sFr spikeFrames(i)+pos-win];
                spikeWaveforms = [spikeWaveforms bin];
            end
        end
    end
    spikeFrames = sFr;
    
catch
    disp(['Failed to detect spikes']);
    spikeFrames = [];
end
threshold = multiplier*threshold;
end
