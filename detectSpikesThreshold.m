function [spikeTrain, filtTrace, threshold] = ...
    detectSpikesThreshold(trace, multiplier, refPeriod, fs, filterFlag)

% Description:
%   Threshold-based spike detection

% INPUT:
%   trace: [n x 1] raw or filtered voltage trace
%   multiplier: [scalar] threshold multiplier used for spike detection
%   refPeriod: [scalar] refractory period [ms] after a spike in which
%                       no spikes will be detected
%   fs: [scalar] sampling frequency in [Hz]
%   filterFlag: specifies whether to filter the trace (1); (0) otherwise

% OUTPUT:
%   spikeTrain - [n x 1] binary vector, where 1 represents a spike
%   filtTrace - [n x 1] filtered voltage trace
%   threshold - [scalar] threshold used in spike detection in [mV]

% Author: 
%   Jeremy Chabros, University of Cambridge, 2020
%   email: jjc80@cam.ac.uk
%   github.com/jeremi-chabros

%   Filtering
if filterFlag
    lowpass = 600;
    highpass = 8000;
    wn = [lowpass highpass] / (fs / 2);
    filterOrder = 3;
    [b, a] = butter(filterOrder, wn);
    trace = filtfilt(b, a, double(trace));
end

% Calculate the threshold (median absolute deviation)
% See: https://en.wikipedia.org/wiki/Median_absolute_deviation
s = (mad(trace, 1)/0.6745);     % Faster than mad(X,1);
m = mean(trace);                % Note: filtered trace is already zero-mean
threshold = m - multiplier*s;

% Detect spikes (defined as threshold crossings)
spikeTrain = zeros(size(trace));
spikeTrain = trace < threshold;
spikeTrain = double(spikeTrain);

% Impose the refractory period [ms]
refPeriod = refPeriod * 10^-3 * fs;
for i = 1:length(spikeTrain)
    if spikeTrain(i) == 1
        refStart = i + 1;
        refEnd = round(i + refPeriod);
        if refEnd > length(spikeTrain)
            spikeTrain(refStart:length(spikeTrain)) = 0;
        else
            spikeTrain(refStart:refEnd) = 0;
        end
    end
end
filtTrace = trace;
end
