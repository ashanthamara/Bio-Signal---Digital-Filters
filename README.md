# Bio-Signal---Digital-Filters
This repository is about the Digital Filters learnt in the Bio Signal Processing Module

# Introduction
This study allows implementing digital filters on MATLAB and applying them to biomedical signals. 

## 1. Smoothing filters
One of the most common signal processing tasks is smoothing of the data to reduce high frequency noise arising from electromagnetic interferences, quantization errors and from peripheral physiological signals. Here, the application of moving average filters of order N (MA(N)) and Savitzky-Golay filters of order N and length L’= 2L + 1 (SG(N,L))

### 1.1. Moving average MA(N) filter
A MA(N) filter can be visualised as a moving window across the signal. A point of the filtered signal 𝑦(𝑛) is derived from the average of the windowed points on the input signal 𝑥(𝑛).

