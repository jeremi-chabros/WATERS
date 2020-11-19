params = struct();
% Multiplier used in the initial threshold-based spike detection. Specifies multiplier * mad(data, 1)/0.6745
% See: https://en.wikipedia.org/wiki/Median_absolute_deviation
params.multiplier = 3.5; 
% The number of spikes used to adapt the wavelet
params.nSpikes = 200;
% Number of scales across the wavelet is stretched
params.nScales = 5;
% The window over which the wavelet is stretched in [ms]
params.wid = [0.5 1];
% Channels excluded from the analysis as specified in the 'channels' variable, NOT the XY coordinates
params.grd = [];
% List of the cost parameters to be used in spike detection
% params.costList = [-0.2:0.05:0];
params.costList = -0.2;
% List of wavelets to be used in spike detection
params.wnameList = {'mea', 'bior1.5', 'bior1.3', 'db2'};
% Time in [s] to be cropped from the recording for analysis
params.subsample_time = [30 90];
params.minPeakThrMultiplier = 2; % minimum amplitude of the negative peak (as in 'multiplier')
params.maxPeakThrMultiplier = 8; % maximum amplitude of the negative peak (as in 'multiplier')
params.posPeakThrMultiplier = 4; % maximum amplitude of the positive peak (as in 'multiplier')
% Save parameters to the params.mat file
save('params.mat', 'params');
