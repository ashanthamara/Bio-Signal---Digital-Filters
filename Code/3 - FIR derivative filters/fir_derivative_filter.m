%% 3. FIR derivative filters
% 3.1.	FIR derivative filter properties
% first order derivative
b1 = [1 -1];
a1 = 1;
fvtool(b1,a1);

% three-point central difference derivative filters
b3 = [1 0 -1];
a3 = 1;
fvtool(b3,a3);

fvtool(b1,a1,b3,a3);
legend('First Order','Central Difference')

% gain
G = 0.5;
fvtool(G*b1,a1,G*b3,a3);
legend('First Order','Central Difference')

%% 3.2 FIR derivative filter application

% i) Loading ECG recording
load('ECG_rec.mat');
fs = 128;
len  = length(ECG_rec);
%% ii) Add noise to ECG recording

% Add Gaussian Noise of 10 dB
noisy_ECG = awgn(ECG_rec,10,'measured');

time = linspace(0,(len-1)/fs,len);
EMG_sig = 2*sin(2*pi*time/4) + 3*sin((2*pi*time/2)+ pi/4);

% Adding emg noise to the ECG
nECG = noisy_ECG + EMG_sig;

figure('Name','Raw ECG and Noisy ECG')
plot(time, ECG_rec,'b', time,nECG,'r');
title('Raw ECG and Noisy ECG'), xlabel('Time(s)'), ylabel('Amplitude (mV)')
legend('ECG raw signal', 'nECG')

%% iii) Apply the derivative filters derived

% apply first order filter
firstORD_filtered = filter(G*b1, a1, nECG);

% apply Central Difference Derivative Filter
CenDeri_filtered = filter(G*b3, a3, nECG);


figure('Name','Filter Comparison')
plot(time, ECG_rec, 'k', time, firstORD_filtered, 'b', time, CenDeri_filtered, 'r')

title('Filter Comparison'), xlabel('Time(s)'), ylabel('Amplitude')
legend('ECG raw signal', 'First Order Filtered ECG', '3 Point Central Difference Filtered ECG')