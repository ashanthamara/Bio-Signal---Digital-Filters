%Question 1
%Smoothing Filters
%1.1 Moving Average Filter
%Preliminaries
%i) LoadECG_template.mat
clear all;
load('ECG_template.mat');
raw_ecg =  ECG_template;

%ii) Plot the loaded signal with the adjusted time scale
[rows, len] = size(raw_ecg);
%sampling frequency 500Hz
fs = 500;
time = linspace(0,len/fs,len);
figure('Name','ECG_template Data');
plot(time,ECG_template);
title('Typical ECG Characteristics'),xlabel('Time(s)'),ylabel('mV');

%iii) Add white Gaussian noise of 5 dB
noisy_ECG = awgn(raw_ecg,5, 'measured');
figure('Name','ECG_template Data with 5dB Gaussian Noise');
plot(time,noisy_ECG, 'b',time,ECG_template, 'r');
title('5dB Gaussian noise added ECG Signal'),legend('ECG Signal with Noise','ECG Signal');
xlabel('Time(s)'),ylabel('mV');

%iv) Plot the power spectral density (PSD)
[pxx_raw,f_raw] = periodogram(raw_ecg,rectwin(len),512,fs);
[pxx,f] = periodogram(noisy_ECG,rectwin(len),512,fs);

figure('Name','ECG_template Data');
semilogy(f,pxx,f_raw, pxx_raw);
title('Power Spectral Density of ECG & nECG signal'),legend('ECG Signal with Noise','ECG Signal');
xlabel('frequency'),ylabel('Amplitude');

%MA(3) filter implementation with a customised script
%i) 
filt_order = 3;
ma3ECG_1 = mAvgfilter(noisy_ECG, filt_order);

%ii) Derive the group delay
group_delay = floor((filt_order-1)/(2*fs));

%iii)Plot the delay compensated ma3ECG_1and nECG on the same plot and compare
delayed_time = time - group_delay;

figure('Name','Comparing nECG and delay compensated maECG_1');
plot(time,noisy_ECG,'b',delayed_time,ma3ECG_1,'r');
title('Comparing nECG and delay compensated Filtered Signal')
legend('ECG Signal with Noise', 'Delay compensated maECG_1');

%iv) Produce overlapping PSDs of ma3ECG_1and nECG

figure('Name', 'PSD of ma3ECG_1and nECG')
[pxx,f] = periodogram(noisy_ECG,rectwin(len),[],fs);
[pxx2,f2] = periodogram(ma3ECG_1,rectwin(len),[],fs);
semilogy(f,pxx,f2,pxx2)
grid on;
title('Compare Power Spectral Density Estimate of ma3ECG_1and nECG')
legend('ECG signal with noise','Delay compensated maECG_1');
xlabel('Frequency(Hz)')
ylabel('Amplitude')

%MA(3) filter implementation with the MATLAB built-in function
%i) Using the filter(b,a,X) function
filt_order_2 = 3; % Whatever you want.
kernel = ones(filt_order_2,1) / filt_order_2;
ma3ECG_2 = filter(kernel, 1, noisy_ECG);

group_delay_2 = floor((filt_order_2-1)/(2*fs));
delayed_time_2 = time - group_delay_2;
%ii) Plot nECG, ECG_template and ma3ECG_2 on the same plot

figure('Name','Comparing ECG_template, noisy_ECG and ma3ECG_2');
plot(time, raw_ecg, 'black', time,noisy_ECG,'b', delayed_time_2, ma3ECG_2,'r');
title('Comparing ECG_template, noisy_ECG and ma3ECG_2')
legend('ECG template','ECG Signal with Noise', 'Delay compensated maECG_2');
xlabel('Time(s)')
ylabel('mV')

%iii) Using the fvtool(b,a) to inspect the magnitude response, phase response and the pole-zero plot of the MA(3) filter
fvtool(kernel,1);


