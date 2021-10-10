# Bio-Signal---Digital-Filters
This repository is about the Digital Filters learnt in the Bio Signal Processing Module

# Introduction
This study allows implementing digital filters on MATLAB and applying them to biomedical signals. 

## 1. Smoothing filters
One of the most common signal processing tasks is smoothing of the data to reduce high frequency noise arising from electromagnetic interferences, quantization errors and from peripheral physiological signals. Here, the application of moving average filters of order N (MA(N)) and Savitzky-Golay filters of order N and length L’= 2L + 1 (SG(N,L))

### 1.1. Moving average MA(N) filter
A MA(N) filter can be visualised as a moving window across the signal. A point of the filtered signal 𝑦(𝑛) is derived from the average of the windowed points on the input signal 𝑥(𝑛).

#### Data set characteristics
Name                    : ECG_template.mat
Sampling frequency (fs) : 500 Hz
Amplitude range         : mV

Here we are using a ECG_template.mat and then add 5 dB Gaussian Noise to that data set to obtain a noisy ECG signal. After that we apply the designed Moving Average Filter and observe the characteristics of the signal.

![HD_V1](https://github.com/ashanthamara/Bio-Signal---Digital-Filters/blob/question1/Figures/1%20-%20Smoothing%20Filters/ECG_template%20Data.svg)

After adjusting the time scale with the sampling frequency of 500 Hz, we can observe an ECG pulse as shown in above figure. In there we can clearly observe the P wave, QRS complex and the T wave of a typical ECG signal.

![HD_V1](https://github.com/ashanthamara/Bio-Signal---Digital-Filters/blob/question1/Figures/1%20-%20Smoothing%20Filters/Guassian%20%2B%20raw%20signal.svg)

5 dB Gaussian Noise is added to the ECG_template data set using “awgn(x, snr, ‘measured’)” function and both noisy signal and the reference signal is plotted in a single figure.

![HD_V1](https://github.com/ashanthamara/Bio-Signal---Digital-Filters/blob/question1/Figures/1%20-%20Smoothing%20Filters/Power%20Spectral%20Density%20of%20ECG%20%26%20nECG%20signal.svg)

Power Spectral Density gives the signal power in different frequency components of a signal. When looking into the above figure, we can clearly see that, the ECG signal power is prominent in the lower frequencies (< 50 Hz) and the noisy ECG signal has more power in high frequencies due to the added noise.  

![HD_V1](https://github.com/ashanthamara/Bio-Signal---Digital-Filters/blob/question1/Figures/1%20-%20Smoothing%20Filters/Comparing%20nECG%20and%20delay%20compensated%20maECG_1.svg)

After compensating the group delay, we can see that both signals get aligned in the time domain and after applying the Moving Average filter, signal has smoothened by reducing the high frequency variation.

![HD_V1](https://github.com/ashanthamara/Bio-Signal---Digital-Filters/blob/question1/Figures/1%20-%20Smoothing%20Filters/Compare%20Power%20Spectral%20Density%20Estimate%20of%20ma3ECG_1and%20nECG.svg)

Above figure drastically shows that the removal of high frequency components of the signal after applying the Moving Average filter. The signal power in high frequencies is reduced but the low frequencies (<50 Hz) are not affected by the filter.

![HD_V1](https://github.com/ashanthamara/Bio-Signal---Digital-Filters/blob/question1/Figures/1%20-%20Smoothing%20Filters/Comparing%20ECG_template%2C%20noisy_ECG%20and%20ma3ECG_2.png)

The filtered signal has smoothened the noisy signal by reducing high frequency variations like in the signal filtered using the derived Moving Average Filter 

![HD_V1](https://github.com/ashanthamara/Bio-Signal---Digital-Filters/blob/question1/Figures/1%20-%20Smoothing%20Filters/Magnitude%20Response.svg)

![HD_V1](https://github.com/ashanthamara/Bio-Signal---Digital-Filters/blob/question1/Figures/1%20-%20Smoothing%20Filters/Phase%20Response.svg)

![HD_V1](https://github.com/ashanthamara/Bio-Signal---Digital-Filters/blob/question1/Figures/1%20-%20Smoothing%20Filters/Pole-Zero%20Plot.svg)

Magnitude Response, Phase Response & Pole - Zero Plot of MA(3) filter using fvtool

