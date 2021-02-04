function [spikeTimes, spikeWaveforms, trace] = detectSpikesCWT(...
    data, fs, Wid, wname, L, Ns, multiplier, nSpikes, ttx, ...
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

% INPUT:
%
%   data: [1 x n] (raw) extracellular voltage trace to be analyzed
%
%   fs: sampling frequency [Hz]
%
%   Wid:  [1 x 2] vector of expected minimum and maximum width [ms] of
%         transient to be detected Wid=[Wmin Wmax]
%         For most practical purposes Wid=[0.5 1.0]
%
%   wname: (string): the name of wavelet family in use
%       'bior1.5' - biorthogonal
%       'bior1.3' - biorthogonal
%       'db2'     - Daubechies
%       'mea'     - custom data-driven wavelet (https://github.com/jeremi-chabros/CWT)
%
%       Note: sym2 and db2 differ only by sign --> they produce the same
%       result
%
%	L: the factor that multiplies [cost of comission]/[cost of omission].
%       For most practical purposes -0.2 <= L <= 0.2. Larger L --> omissions
%       likely, smaller L --> false positives likely.
%       For unsupervised detection, the suggested value of L is close to 0
%
%   Ns: [scalar] the number of scales to use in spike detection (Ns >= 2)
%
%   multiplier: [scalar] the threshold multiplier used for spike detection
%
%   nSpikes: [scalar] the number of spikes used to adapt a custom wavelet
%
%   ttx: [logical] flag for the recordings with TTX added: 1 = TTX, 0 = control
%
%   minPeakThrMultiplier: [scalar] specifies the minimal spike amplitude
%
%   maxPeakThrMultiplier: [scalar] specifies the maximal spike amplitude
%
%   posPeakThrMultiplier: [scalar] specifies the maximal positive peak of the spike


% OUTPUT:
%
%   spikeTimes: [1 x #spikes] vector containing frames where spikes were detected
%                 (divided by fs yields spike times in seconds)
%
%   spikeWaveforms: [51 x #spikes] matrix containing spike waveforms
%                    (51 comes from sampling frequency and corresponds to
%                     spike Frame +/-1 ms)
%
%   trace: [1 x n] filtered extracellular voltage trace

% Author:
%   Jeremy Chabros, University of Cambridge, 2020
%   email: jjc80@cam.ac.uk
%   github.com/jeremi-chabros


refPeriod = 2; % Only used by the threshold method

% Filter signal
try
    lowpass = 600;
    highpass = 8000;
    wn = [lowpass highpass] / (fs / 2);
    filterOrder = 3;
    [b, a] = butter(filterOrder, wn);
    trace = filtfilt(b, a, double(data));
catch
    error('Signal Processing Toolbox not found');
end

win = 25;   % [frames]

if strcmp(wname, 'mea') && ~ttx
    
    %   Use threshold-based spike detection to obtain the median waveform
    %   from nSpikes
    try
        [aveWaveform, ~] = getTemplate(trace, multiplier, refPeriod, fs, nSpikes);
    catch
        warning('Failed to obtain mean waveform');
    end
    
    %   Adapt custom wavelet from the waveform obtained above
    try
        adaptWavelet(aveWaveform);
    catch
        warning('Failed to adapt custom wavelet');
    end
end

try
    spikeWaveforms = [];
    spikeTimes = [];
    
    % Detect spikes with threshold method
    if startsWith(wname, 'thr')
        multiplier = strrep(wname, 'p', '.');
        multiplier = strrep(multiplier, 'thr', '');
        multiplier = str2num(multiplier);
        [spikeTrain, ~, ~] = detectSpikesThreshold(trace, multiplier, 0.2, fs, 0);
        spikeTimes = find(spikeTrain == 1);
        spikeTimes = unique(spikeTimes);
    else
        
        % Detect spikes with wavelet method
        spikeTimes = detectSpikesWavelet(trace, fs/1000, Wid, Ns, 'c', L, wname, 0, 0);
    end
    
    % Align spikes by negative peak & remove artifacts by amplitude
    [spikeTimes, spikeWaveforms] = alignPeaks(spikeTimes, trace, win, 1,...
        minPeakThrMultiplier,...
        maxPeakThrMultiplier,...
        posPeakThrMultiplier);
catch
    spikeTimes = [];
end
end
