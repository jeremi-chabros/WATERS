# CWT
**Spike detection based on continuous wavelet transform with data-driven templates**

This method is an extension of the method presented in:

> Nenadic Z, Burdick JW. 

> Spike detection using the continuous wavelet transform. 

> IEEE Trans Biomed Eng. 2005;52(1):74-87. 

> doi:10.1109/TBME.2004.839800

Through adapting custom wavelets based on spike waveforms, it creates a family of templates that are then scaled
- horizontally in time domain
- vertically in voltage (amplitude) domain
Allowing for a more robust spike detection that accounts for physiological and morphological neuronal properties
as well as the way data is collected. These parameters include: refractory period, maximal/minimal spike amplitudes,
the neuron's unique waveform (TODO: separating neurons by their unique spiking waveforms),
spatial organization of the neural network in vitro, etc.

Spike detection pipeline:
1. Using a threshold method with threshold set to m = [3,5] (median absolute deviation/0.6745, see: https://en.wikipedia.org/wiki/Median_absolute_deviation) detect n = [50, 1000] spikes.
2. Using the aggregated median spike waveform adapt a custom wavelet:

   2a. Spline interpolation from 2 x sampling frequency in kHz data points to 100
   
   2b. Gaussian smoothing (8th degree)
   
   2c. Signal centred around zero
   
   2d. Adapt type 4 wavelet using 0th degree orthogonally constant method
   
3. Spike detection using the continuous wavelet transform.
4. Using built-in templates, repeat 3.
5. Spike merging by peaks (+/- 10 frames = 0.4 ms) - different wavelets have a different zero-crossing point
   5a. TODO: include a weighting function and an optimal set of templates
6. TODO: spike sorting.

