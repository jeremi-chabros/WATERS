function [newWaveletIntegral, newWaveletSqN] = customWavelet(ave_trace)

template = ave_trace;

% Pre-allocate
signal = zeros(1, 100);

% Rescale horizontally by a factor of 2
rsF = 2;
for i = 1:length(signal)+1
    if rem(i, rsF) == 0
        signal(1, i) = template(1, i/2);
        signal(1, i-1) = signal(1, i);
        signal(1, i) = 0;
    end
end

signalCentered = signal;

%   Gaussian smoothing
w = gausswin(8);
y = filter(w,1,signalCentered);
y = rescale(y);
y = y - mean(y);

%   Linear interp for expanding the number of samples and smoothing
xq = linspace(1, length(signalCentered), 1000);
x = 1:length(signalCentered);
vq1 = interp1(x,y,xq);

[Y,X,nc] = pat2cwav(vq1, 'orthconst', 0, 'none') ;

%   Test if a legitmate wavelet
dxval = max(diff(X));
newWaveletIntegral = dxval*sum(Y); %    Should be 1.0
newWaveletSqN = dxval*sum(Y.^2);
newWaveletSqN = round(newWaveletSqN,10); % Should be zero

%   Save the wavelet
if newWaveletSqN == 1.0000
    
    % Using built-in cwt method requires saving the custom wavelet each
    % time - currently overwriting as there is no reason to retrieve the
    % wavelet
    
    save('mother.mat', 'X', 'Y');
    wavemngr('del', 'meaCustom');
    %   All wavelets cunstructed with wavemngr are type 4 wavelets
    wavemngr('add', 'meaCustom','mea', 4, '', 'mother.mat', [-100 100]);
    wname = 'mea';
else
    disp('ERROR: Not a proper wavelet');
    disp(['Wavelet integral = ', num2str(newWaveletIntegral)]);
    disp(['L^2 norm = ', num2str(newWaveletSqN)]);
end
end
