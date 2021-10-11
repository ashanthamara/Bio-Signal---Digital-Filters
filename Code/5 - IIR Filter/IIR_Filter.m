%% 5.IIR Filter
% 5.1.	Realising IIR filters

%%
fs = 500;
f_nq = fs/2;
M = 453;  %previously calculated M for Kaiser window

%% i) Higher order butterworth Low pass filter
[zeroLP_M453, poleLP_M453, gainLP_M453] = butter(M, 125/f_nq, 'low');
[numLP_M453, denLP_M453] = zp2tf(zeroLP_M453, poleLP_M453, gainLP_M453);
% ii)
fvtool(numLP_M453, denLP_M453);

%% iii) IIR Lowpass butterworth filter
W_lp = 125/f_nq;
[zeroLP_M10, poleLP_M10, gainLP_M10] = butter(10, W_lp, 'low');
[numLP_M10, denLP_M10] = zp2tf(zeroLP_M10, poleLP_M10, gainLP_M10);
fvtool(numLP_M10, denLP_M10, 'Analysis','freq')

%% IIR Highpass butterworth filter
W_hp = 5/f_nq;
[zeroHP_M10, poleHP_M10, gainHP_M10] = butter(10, W_hp, 'high');
[numHP_M10, denHP_M10] = zp2tf(zeroHP_M10, poleHP_M10, gainHP_M10);
fvtool(numHP_M10, denHP_M10,'Analysis','freq')

%% Comb filters to remove power line interference
fc = 50; 
q = 35;
BW = (fc/q)/fs; % normalized 3dB width of notch
[b_COMB, a_COMB]=iircomb(fs/fc,BW); 
fvtool(b_COMB, a_COMB)

%% iv) cascading all filters
numLpHpComb_M10 = conv(conv(numLP_M10, numHP_M10), b_COMB);
denLpHpComb_M10 = conv(conv(denLP_M10, denHP_M10), a_COMB);
fvtool(numLpHpComb_M10, denLpHpComb_M10,cascadedh, 1)
legend('IIR BW Cascade Filter | M = 10', 'FIR Kaiser windowed Cascade FIlter | M = 453')

%%
fvtool(conv(b_comb,conv(HP_H, Lp_H)), 1, numLpHpComb_M10, denLpHpComb_M10)

%% 5.2 Forward Filtering\
% Load Mat
load('ECG_with_noise.mat')
len = length(nECG);
% i)
time = linspace(0,len-1,len)/fs;

IIR_LP_Fwd = filter(numLP_M10, denLP_M10, nECG);
IIR_LPHP_Fwd = filter(numHP_M10, denHP_M10, IIR_LP_Fwd);
IIR_LPHPCOMB_Fwd = filter(b_COMB, a_COMB, IIR_LPHP_Fwd);

figure
ax1 = subplot(4,1,1);
plot(time,nECG,'k')
title('Noisy ECG signal'), xlabel('Time(s)'), ylabel('Amplitude (mV)')
ax2 = subplot(4,1,2);
plot(time,IIR_LP_Fwd,'b')
title('IIR Lowpass filtered signal | fc = 125Hz'), xlabel('Time(s)'), ylabel('Amplitude (mV)')
ax3 = subplot(4,1,3);
plot(time,IIR_LPHP_Fwd,'r')
title('IIR Lowpass & Highpass filtered signal  | fc = 5Hz'), xlabel('Time(s)'), ylabel('Amplitude (mV)')
ax4 = subplot(4,1,4);
plot(time,IIR_LPHPCOMB_Fwd,'g')
title('IIR Lowpass, Highpass and Comb filtered signal  = Harmonics of 50Hz '), xlabel('Time(s)'), ylabel('Amplitude (mV)')
linkaxes([ax1,ax2,ax3,ax4],'xy')

%% ii) Forward-Backward filtering

time = linspace(0,len-1,len)/fs;

IIR_LP_FwdBwd = filtfilt(numLP_M10, denLP_M10, nECG);
IIR_LPHP_FwdBwd = filtfilt(numHP_M10, denHP_M10, IIR_LP_FwdBwd);
IIR_LPHPCOMB_FwdBwd = filtfilt(b_COMB, a_COMB, IIR_LPHP_FwdBwd);
 
figure
ax1 = subplot(4,1,1);
plot(time,nECG,'k')
title('Noisy ECG Signal = nECG'), xlabel('Time(s)'), ylabel('Amplitude (mV)')
ax2 = subplot(4,1,2);
plot(time,IIR_LP_FwdBwd,'b')
title('IIR Lowpass Forward-Backward filtered signal| fc = 125Hz'), xlabel('Time(s)'), ylabel('Amplitude (mV)')
ax3 = subplot(4,1,3);
plot(time,IIR_LPHP_FwdBwd,'r')
title('IIR Lowpass & Highpass Forward-Backward filtered signal | fc = 5Hz'), xlabel('Time(s)'), ylabel('Amplitude (mV)')
ax4 = subplot(4,1,4);
plot(time,IIR_LPHPCOMB_FwdBwd,'g')
title('IIR Lowpass, Highpass and Comb Forward-Backward filtered signal '), xlabel('Time(s)'), ylabel('Amplitude (mV)')
linkaxes([ax1,ax2,ax3,ax4],'xy')

%% iii) Comparing Filtering methods

% FIR total filtering
totalFiltered_FIR = filter(conv(b_comb, conv(HP_H, Lp_H)), 1, nECG);

time = linspace(0, len-1, len)/fs;
t_delayed = time - (combdelay + lpdelay+ hpdelay)/fs;

figure
plot(t_delayed, totalFiltered_FIR, 'k', time,IIR_LPHPCOMB_Fwd, 'b',time,IIR_LPHPCOMB_FwdBwd, 'r')
legend('Delay Compensated FIR - Filtered Signal', 'IIR - Forward Filtering','IIR - Forward-Backward Filtering')
title('Comparing Filtering Methods'), xlabel('Time (s)'), ylabel('Amplitude (mV)')

%% iv) PSD 

[pxx_IIR_fwd, w_IIR_fwd] = periodogram(IIR_LPHPCOMB_Fwd, rectwin(length(IIR_LPHPCOMB_Fwd)), [], fs);
[pxx_IIR_fwdbck, w_IIR_fwdbck]= periodogram(IIR_LPHPCOMB_FwdBwd, rectwin(length(IIR_LPHPCOMB_FwdBwd)), [], fs);
[pxx_FIR, w_FIR] = periodogram(totalFiltered_FIR, rectwin(length(totalFiltered_FIR)), [], fs);

figure
semilogy(w_IIR_fwd, pxx_IIR_fwd, w_IIR_fwdbck, pxx_IIR_fwdbck, w_FIR,pxx_FIR)
title('PSD of Filtered ECG signal'), xlabel('Frequency (Hz)'), ylabel('Power/Frequency (dB/Hz)')
legend('IIR - Forward Filtered ECG','IIR - Forward-Backward Filtered ECG','FIR - Filtered ECG')