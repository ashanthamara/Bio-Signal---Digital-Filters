% 2.1 Signal with multiple measurements
%% Prelimineries
% i)
clear all; 
clc;
% ii)
load ABR_rec.mat;
% iii)
figure('Name','Recorded ABR Data');
plot(ABR_rec);
legend('Stimuli','ABR train');
title('ABR recording and Audio Pulse Stimuli'),xlabel('Samples(n)'),ylabel('mV')

%% iv)
thresh = find(ABR_rec(:,1)>50);
% v) Extract stimulus points
j=1;
for i=1:length(thresh)-1
    if thresh(i+1)-thresh(i)>1; 
        stim_point(j,1)=thresh(i+1); 
        j=j+1;
    end
end

%% Window ABR epochs -80:399 points selected
% vi) Time Window from -2ms to +10ms from stimulus point
j = 0;
for i=1:length(stim_point) 
    j = j + 1;
    epochs(:,j) = ABR_rec((stim_point(i)-80:stim_point(i)+399),2); 
end
% vii) calcualte average of  epochs
ensmbl_avg = mean(epochs(:,(1:length(stim_point))),2);

% viii) Plot the ensemble averaged ABR EEG waveform.
figure,
plot((-80:399)/40,ensmbl_avg)
xlabel('Time (ms)'), ylabel('Voltage(uV)')
title(['Ensemble averaged ABR from ',num2str(length(epochs)),' epochs'])

%% Improvement of SNR
len_epoch = length(epochs);
mse_k = zeros(len_epoch,1);
snr_k = zeros(len_epoch,1);

for m = 1:len_epoch
    yk = mean(epochs(:,(1:m)),2);
    mse_k(m) = immse(ensmbl_avg,yk);
    snr_k(m) = snr(ensmbl_avg,ensmbl_avg-yk);
end

figure('Name','MSE vs Epochs');
plot(mse_k)
xlabel('epochs'), ylabel('MSE')
title('MSE vs Epochs');

k = linspace(1,len_epoch,len_epoch);
ideal_SNR = 10.*log10(k)+snr_k(5);

% logrithmic plot 
figure,
plot(k,10*log10(mse_k))
xlabel('Epochs(k)'), ylabel('MSE (dB)')
title('MSE variation for ensemble averaging')

figure, plot(k,snr_k,k,ideal_SNR)
xlabel('Epochs(k)'), ylabel('SNR (dB)')
title(['SNR variation for ensemble averaging (0 to ',num2str(length(epochs)),' epochs)'])
legend('SNR','Ideal SNR')

%% 2.2 Signals with repetitive patterns
% i)
clear all; 
clc;
load ECG_rec.mat;
[~,time] = size(ECG_rec);

%% ii) Plot the data and observe amplitudes and the waveforms.
% smapling frequency
fs = 128;
T = linspace(0,time/fs,time);

figure('Name', 'ECG recording data set'), 
plot(T,ECG_rec)
title('ECG recording data set')
xlabel('Time (s)'),ylabel('Voltage (mV)')

figure('Name', 'ECG recording data set - scaled'), 
plot(T(35:227),ECG_rec(35:227)) % 1.5 s time window >> 192 data points
title('ECG recording data set - scaled (35:227)')
xlabel('Time (s)'),ylabel('Voltage (mV)')

%% iii) Extract a single PQRST waveform
[QRS_peak_values, points] = findpeaks(ECG_rec,'MinPeakHeight',1);
meanPULSE_period = mean(points(2:end)-points(1:end-1));

pulse_selected = points(20);

ECG_template = ECG_rec(ceil(pulse_selected - 0.35*meanPULSE_period):ceil(pulse_selected + 0.65 * meanPULSE_period)+1);

figure('Name', 'Single ECG waveform'), 
plot(ECG_template)
title('Single ECG Waveform')
%xlabel('Time (s)')
ylabel('Voltage (mV)')

%% iv) add Gaussian white noise of 5dB
nECG = awgn(ECG_rec,5,'measured');

figure('Name', 'Noisy ECG Data set'),
plot(T,nECG)
title('Noisy ECG Data Set')
ylabel('Voltage (mV)')

%% i) Segmenting ECG into seperate epochs

xcorr_ECG_template = zeros(size(nECG)); %make the smaller signal the same size
xcorr_ECG_template(1:length(ECG_template)) = ECG_template;

% Calculate cross correlation
[cross_corr_values, lags] = xcorr(nECG,xcorr_ECG_template, 'normalized');

% ii) Plot the normalised cross-correlation values against the adjusted lag axis
figure('Name', 'Cross correlation with nECG & ECG template'),
plot(lags/fs,cross_corr_values)
title('Cross correlation with nECG & ECG template')
xlabel('Lag (s)'), ylabel('Normalized Score')

%% iii) Segment ECG pulses by defining a threshold and store in a separate matrix

corr_threshold = 0.08; %by observing cross correlation values

overlaps = lags(cross_corr_values > corr_threshold); % get values with xcorr > threshold
gauge = 10; % remove values that are close together
pulses_loc = [];
pulse_corr_values = []; 
for k = 1:length(overlaps)-1
    if overlaps(k+1)- overlaps(k)> gauge
        pulses_loc = [pulses_loc overlaps(k)+1]; 
        pulse_corr_values = [pulse_corr_values cross_corr_values(floor(length(cross_corr_values)/2) + overlaps(k)+1)];  
    end
end

%% Store pulses
all_pulses = [];
for j = 1:length(pulses_loc)
    all_pulses = [all_pulses; nECG(pulses_loc(j):ceil(pulses_loc(j) + meanPULSE_period))]; %pulse extraction
end

%% iv)Calculate and plot the improvement in SNR
snr_values = zeros(size(pulses_loc));
mse_values = zeros(size(pulses_loc));

snr_values(1) = snr(ECG_template, all_pulses(1,:) - ECG_template);
mse_values(1) = immse(ECG_template, all_pulses(1,:));

for k = 2:length(pulses_loc)
    mse_values(k) = immse(ECG_template, mean(all_pulses(1:k,:)));
    snr_values(k) = snr(ECG_template, mean(all_pulses(1:k,:)) - ECG_template);
end
%% Plot SNR improvement
figure('Name', 'Improvement of SNR'),
plot(snr_values)
title('Improvement of SNR'), xlabel('Number of Pulses'), ylabel('SNR (dB)')

%% V) Plot and compare (in the one graph), a selected noisy ECG pulse and two arbitrary selected ensemble averaged ECG pulses.e
figure('Name', 'ECG Sample and Ensemble Average Comparison'),

plot(ECG_template,'LineWidth',1.5),hold on 
plot(all_pulses(1,:),'k')
plot(mean(all_pulses(1:20,:)),'g')
plot(mean(all_pulses(1:50,:)),'r')
title('ECG Sample and Ensemble Average Comparison'),ylabel('Amplitude(mV)'), xlabel('Number of Samples(n)')
legend('ECG template', 'ECG Pulse Sample', 'Ensemble Avg 20 epochs','Ensemble Avg 50 epochs')
hold off

%% vi) Why xcorr is better
len = fs*4;
x_axis = linspace(1,len,len)/fs;

figure('Name', 'xcorr pulse detection')
subplot(3,1,1);
plot(x_axis, ECG_rec(1:len))
title('ECG raw recording'),xlabel('Time (s)'), ylabel('Amplitude (mV)')

subplot(3,1,2);
plot(x_axis, cross_corr_values(floor(length(cross_corr_values)/2)+1:floor(length(cross_corr_values)/2+len)))
title('Adjusted xcorr values'),xlabel('Lag (s)'), ylabel('Normal Cross Correlation (mV)')

subplot(3,1,3);
plot(x_axis, nECG(1:len)), hold on
plot(pulses_loc(pulses_loc < len)/fs,pulse_corr_values(pulses_loc < len),'*')
hold off
title('Noisy ECG and Pulse starting points'),xlabel('Time (s)'), ylabel('Amplitude (mV)')

