# CuTe 

Spike detection based on continuous wavelet transform with data-driven templates.

<p align="center">
  <img width="750" height="500" src="https://github.com/jeremi-chabros/CWT/blob/master/githubGraphics/testAnimated.gif?raw=true">
</p>

## Description

This method is an extension of the method presented in:

> Nenadic Z, Burdick JW.\
Spike detection using the continuous wavelet transform.\
IEEE Trans Biomed Eng. 2005;52(1):74-87.\
doi:10.1109/TBME.2004.839800

Through adapting custom wavelets based on spike waveforms, it creates a family of templates that are then scaled:

1. Horizontally in time domain,
2. Vertically in voltage (amplitude) domain.

This allows for a more robust spike detection that accounts for the physiological spike waveforms (as opposed to abstract wavelets).

## Spike detection pipeline

1. Filter the raw voltage trace (3rd order Butterworth, 600 Hz - 8 kHz).
![Filtered trace](https://github.com/jeremi-chabros/CWT/blob/master/githubGraphics/filteredTrace.png?raw=true)

2. Using threshold-based method detect `n ∈ [50, 1000]` spikes.
![Threshold-based detection results](https://github.com/jeremi-chabros/CWT/blob/master/githubGraphics/thresholdSpikes.png?raw=true)

3. Using the aggregated median spike waveform adapt a custom wavelet.

Spike Overlay              | Average waveform          | Adapted wavelet
:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/jeremi-chabros/CWT/blob/master/githubGraphics/thresholdOverlay.png?raw=true)  |  ![](https://github.com/jeremi-chabros/CWT/blob/master/githubGraphics/aveSpike.png?raw=true) | ![](https://github.com/jeremi-chabros/CWT/blob/master/githubGraphics/adaptedWavelet.png?raw=true)

4. Run spike detection scaling the custom wavelet across scales.

![](https://github.com/jeremi-chabros/CWT/blob/master/githubGraphics/cwtInner1.png?raw=true)
![](https://github.com/jeremi-chabros/CWT/blob/master/githubGraphics/cwtInner2.png?raw=true)
![](https://github.com/jeremi-chabros/CWT/blob/master/githubGraphics/meaSpikes.png?raw=true)

5. Compare with threshold-based method and built-in wavelets from MATLAB Wavelet Toolbox.

![](https://github.com/jeremi-chabros/CWT/blob/master/githubGraphics/movingAve.png?raw=true)

<p align="center">
  <img width="665" height="500" src="https://github.com/jeremi-chabros/CWT/blob/master/githubGraphics/spikesHeatmap.png?raw=true">
</p>

![](https://github.com/jeremi-chabros/CWT/blob/master/githubGraphics/uniqueSpikes.png?raw=true)


## Installation

Clone git repository:

``
git clone https://github.com/jeremi-chabros/CWT.git
``

Requires MATLAB with Wavelet Toolbox and Signal Processing Toolbox.


## Usage

Organization of different functions is as follows:\
```bash
.
├── getSpikesTS.m
│   └── detectFramesCWT.m
│       ├── getTemplate.m
│       |   └── detectSpikes.m
│       ├── customWavelet.m
│       └── detect_spikes_wavelet.m
```


Within MATLAB Command Window
1. `setParams();` – set spike detection parameters (overwrites the params.mat file that contains structure `params` with the spike detection parameters\
or\
Manually set the parameters using the `setParameters.m` script
* See the `setParameters.m` or load `params.mat` for more information on the data structure.
2. `dataPath = [/path/to/dataFolder '/'];` – set path to folder with data
3. `savePath = [/path/to/saveFolder '/'];` – set path to output folder
4. `getSpikesTS(dataPath, savePath);` – this is the main analysis function

Note: sometimes `addpath(dataPath)` might be required

> This method is still under development and troubleshooting and hence frequent `git pull` is recommended:\
> 1. `git stash -A`
> 2. `git pull`

## License
[MIT](https://choosealicense.com/licenses/mit/)
