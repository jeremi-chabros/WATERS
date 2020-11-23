function [spikeFrames, spikeWaveforms, filteredData, threshold] = detectSpikesCWT(...
    data, fs, Wid, wname, L, Ns, multiplier, n_spikes, ttx, ...
    minPeakThrMultiplier, maxPeakThrMultiplier, posPeakThrMultiplier)

% Description:
%
%   Spike detection based on continuous wavelet transform with data-driven templates
%
%   Core function: detect_spikes_wavelet.m
%   Adapted from Nenadic & Burdick (2005), doi:10.1109/TBME.2004.839800
%   Modified by JJC
%
%   Custom wavelet specific functions: getTemplate.m, customWavelet.m
%   Written by JJC (2020), https://github.com/jeremi-chabros/CWT


% Input:
%
%   data - [1 x n] (raw) extracellular voltage trace to be analyzed
%
%   fs - sampling frequency [Hz]
%
%   Wid - [1 x 2] vector of expected minimum and maximum width [ms] of
%         transient to be detected Wid=[Wmin Wmax]
%         For most practical purposes Wid=[0.5 1.0]
%
%   wname - (string): the name of wavelet family in use
%       'bior1.5' - biorthogonal
%       'bior1.3' - biorthogonal
%       'db2'     - Daubechies
%       'mea'     - custom data-driven wavelet (https://github.com/jeremi-chabros/CWT)
%
%       Note: sym2 and db2 differ only by sign --> they produce the same
%       result
%
%	L - the factor that multiplies [cost of comission]/[cost of omission].
%       For most practical purposes -0.2 <= L <= 0.2. Larger L --> omissions
%       likely, smaller L --> false positives likely.
%       For unsupervised detection, the suggested value of L is close to 0
%
%   Ns - [scalar] the number of scales to use in spike detection (Ns >= 2)
%
%   multiplier - [scalar] the threshold multiplier used for spike detection
%
%   n_spikes - [scalar] the number of spikes used to adapt a custom wavelet
%
%   ttx - [logical] flag for the recordings with TTX added: 1 = TTX, 0 = control
%
%   minPeakThrMultiplier - [scalar] specifies the minimal spike amplitude
%
%   maxPeakThrMultiplier - [scalar] specifies the maximal spike amplitude
%
%   posPeakThrMultiplier - [scalar] specifies the maximal positive peak of the spike


% Output:
%
%   spikeFrames - [1 x m] vector containing frames where spikes were detected
%                 (divided by fs yields spike times in seconds)
%
%   spikeWaveforms - [51 x m] matrix containing spike waveforms
%                    (51 comes from sampling frequency and corresponds to
%                     spike Frame +/-1 ms)
%
%   filteredData - [1 x n] filtered extracellular voltage trace
%
%   threshold - voltage amplitude used in the initial spike detection step


refPeriod_ms = 2; % Only used by the initial threshold method

%   Filter signal
lowpass = 600;
highpass = 8000;
wn = [lowpass highpass] / (fs / 2);
filterOrder = 3;
[b, a] = butter(filterOrder, wn);
filteredData = filtfilt(b, a, double(data));

%   Set thresholds
threshold = median(abs(filteredData - mean(filteredData))) / 0.6745;
minPeakThr = -threshold * minPeakThrMultiplier;
maxPeakThr = -threshold * maxPeakThrMultiplier;
posPeakThr = threshold * posPeakThrMultiplier;

win = 25;   % [frames]; [ms] = window/25

if strcmp(wname, 'mea') && ~ttx
    
    %   Use threshold-based spike detection to obtain the median waveform
    %   from n_spikes
    try
        [ave_trace, ~] = getTemplate(filteredData, multiplier, refPeriod_ms, n_spikes);
    catch
        disp(['Failed to obtain mean waveform']);
    end
    
    %   Adapt custom wavelet from the waveform obtained above
    try
        adaptWavelet(ave_trace);
    catch
        disp(['Failed to adapt custom wavelet']);
    end
end

%   Detect spikes
try
    
    sFr = [];
    spikeWaveforms = [];
    spikeFrames = [];
    
    spikeFrames = detectSpikesWavelet(filteredData, fs/1000, Wid, Ns, 'c', L, wname, 0, 0);
    
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
                newSpikeFrame = [];
                shape = [];
                newSpikeFrame = spikeFrames(i)+pos-win;
                shape = filteredData(newSpikeFrame-25:newSpikeFrame+25);
                sFr = [sFr newSpikeFrame];
                spikeWaveforms = [spikeWaveforms shape];
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
