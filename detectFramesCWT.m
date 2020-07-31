function [spikeFrames, filteredData, threshold] = detectFramesCWT(...
         data, fs, Wid, wname, L, Ns, multiplier, n_spikes, ttx)
% Input:
%   data - 1 x n extracellular potential data to be analyzed
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

refPeriod_ms = 1;

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
        ave_trace = getTemplate(data, multiplier, refPeriod_ms, n_spikes);
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
    spikeFrames = [];
end
threshold = multiplier*threshold;
end
