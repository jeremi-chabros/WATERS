# CWT
> Spike detection using continuous wavelet transform utilising data-driven custom wavelet templates

This method is an extension of the method presented in:

Nenadic Z, Burdick JW. 
> Spike detection using the continuous wavelet transform. 
> IEEE Trans Biomed Eng. 2005;52(1):74-87. 
> doi:10.1109/TBME.2004.839800

Through adapting custom wavelets adaped from spike waveforms, it creates a family of templates that are then scaled
- horizontally in time domain
- vertically in voltage (amplitude) domain
Allowing for a more robust spike detection that accounts for physiological and morphological neuronal properties
as well as the way data is collected. These parameters include: refractory period, maximal/minimal spike amplitudes,
the neuron's unique waveform (TODO: separating neurons by their unique spiking waveforms),
spatial organization of the neural network in vitro, etc.

Spike detection pipeline:
1. Using a threshold method with threshold set to m = [3,5] (SD from mean) detect n = [50, 1000] spikes.
2. Using the aggregated mean spike waveform adapt a custom wavelet:
   2a. Signal centred around zero
   2b. Gaussian smoothing (8th degree)
   2c. Interpolation
   2d. Adapt type 4 wavelet using 0th orthoconst method
3. Spike detection using the continuous wavelet transform.
4. Using built-in templates, repeat 3.
5. Spike merging by peaks (+/- 5 frames = 0.2 ms) - different wavelets have a different zero-crossing point
   5a. TODO: include a weighting function and an optimal set of templates
6. TODO: spike sorting.

