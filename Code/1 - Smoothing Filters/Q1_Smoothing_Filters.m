%Question 1
%Smoothing Filters
%1.1 Moving Average Filter
%Preliminaries

%% i) LoadECG_template.mat
clear all;
load('ECG_template.mat');
raw_ecg =  ECG_template;

%% ii) Plot the loaded signal with the adjusted time scale
[rows, len] = size(raw_ecg);
%sampling frequency 500Hz
fs = 500;
time = linspace(0,len/fs,len);
figure('Name','ECG_template Data');
plot(time,ECG_template);
title('Typical ECG Characteristics'),xlabel('Time(s)'),ylabel('mV');

%% iii) Add white Gaussian noise of 5 dB
noisy_ECG = awgn(raw_ecg,5, 'measured');
figure('Name','ECG_template Data with 5dB Gaussian Noise');
plot(time,noisy_ECG, 'b',time,ECG_template, 'r');
title('5dB Gaussian noise added ECG Signal'),legend('ECG Signal with Noise','ECG Signal');
xlabel('Time(s)'),ylabel('mV');

%% iv) Plot the power spectral density (PSD)
[pxx_raw,f_raw] = periodogram(raw_ecg,rectwin(len),512,fs);
[pxx,f] = periodogram(noisy_ECG,rectwin(len),512,fs);

figure('Name','ECG_template Data');
semilogy(f,pxx,f_raw, pxx_raw);
title('Power Spectral Density of ECG & nECG signal'),legend('ECG Signal with Noise','ECG Signal');
xlabel('frequency'),ylabel('Amplitude');

% MA(3) filter implementation with a customised script
%% i) 
filt_order = 3;
ma3ECG_1 = mAvgfilter(noisy_ECG, filt_order);

%% ii) Derive the group delay
group_delay = floor((filt_order-1)/2)*(1/fs);

%% iii)Plot the delay compensated ma3ECG_1and nECG on the same plot and compare
delayed_time = time - group_delay;

figure('Name','Comparing nECG and delay compensated maECG_1');
plot(time,noisy_ECG,'b',delayed_time, ma3ECG_1,'r');
title('Comparing nECG and delay compensated Filtered Signal'),xlabel('Time (s)'),ylabel('mV')
legend('ECG Signal with Noise', 'Delay compensated maECG_1');

%% iv) Produce overlapping PSDs of ma3ECG_1and nECG

figure('Name', 'PSD of ma3ECG_1and nECG')
[pxx,f] = periodogram(noisy_ECG,rectwin(len),[],fs);
[pxx2,f2] = periodogram(ma3ECG_1,rectwin(len),[],fs);
semilogy(f,pxx,f2,pxx2)
grid on;
title('Compare Power Spectral Density Estimate of ma3ECG_1and nECG')
legend('ECG signal with noise','Delay compensated maECG_1');
xlabel('Frequency(Hz)')
ylabel('Amplitude')

% MA(3) filter implementation with the MATLAB built-in function
%% i) Using the filter(b,a,X) function
filt_order_2 = 3;
kernel = ones(filt_order_2,1) / filt_order_2;
ma3ECG_2 = filter(kernel, 1, noisy_ECG);

group_delay_2 = floor((filt_order_2-1)/2)*(1/fs);
delayed_time_2 = time - group_delay_2;

%% ii) Plot nECG, ECG_template and ma3ECG_2 on the same plot

figure('Name','Comparing ECG_template, noisy_ECG and ma3ECG_2');
plot(time, raw_ecg, 'black', time,noisy_ECG,'b', delayed_time_2, ma3ECG_2,'r');
title('Comparing ECG_template, noisy_ECG and ma3ECG_2')
legend('ECG template','ECG Signal with Noise', 'Delay compensated maECG_2');
xlabel('Time(s)')
ylabel('mV')

%% iii) Using the fvtool(b,a) to inspect the magnitude response, phase response and the pole-zero plot of the MA(3) filter
fvtool(kernel,1);

%% MA(10) filter implementation with the MATLAB built-in function
filt_order_3 = 10;
kernel_10 = ones(filt_order_3,1) / filt_order_3;

% i) Identify the improvement of the MA(10) filter over the MA(3)
fvtool(kernel_10, 1);

%% ii) Filter the nECG signal using the above MA(10) filter while compensating for the group delay
ma10ECG = filter(kernel_10, 1, noisy_ECG);
group_delay_3 =  floor((filt_order_3-1)/2)*(1/fs);
delayed_time_3 = time - group_delay_3;

%% iii) Plot nECG, ECG_template, ma3ECG_2 and ma10ECG on the same plot
figure('Name','Comparing ECG_template, noisy_ECG, ma3ECG_2 and ma10ECG');
plot(time, raw_ecg, 'black', time, noisy_ECG,'b',delayed_time_2, ma3ECG_2,'g', delayed_time_3, ma10ECG,'r');
title('Comparing ECG_template, noisy_ECG, ma3ECG_2 and ma10ECG')
legend('ECG template','ECG Signal with Noise', 'Delay compensated ma3ECG_2', 'Delay compensated ma10ECG');
xlabel('Time(s)')
ylabel('mV')

%% Optimum MA(N) filter order
%ii) determine the optimum filter order which gives the minimum MSE

order_thrshld = 80;
MSE_values = zeros(order_thrshld);
order_values = zeros(order_thrshld);
%initial value
optimum_ma_order = 1000;
least_mse = 10000;
for k = 2:order_thrshld
    order_values(k) = k;
    MSE_values(k) = MSError(raw_ecg, noisy_ECG, k);
    if (least_mse > MSE_values(k))
        least_mse = MSE_values(k);
        optimum_ma_order = k;
    end
end
optimum_ma_order;
%% plot MSE vs filter order

figure('Name','Finding Optimum Moving Average filter')
plot(order_values,MSE_values);
title('Comparing MSE vs Filter order');
xlabel('MA_Filter Order');
ylabel('MSE');

%% 1.2. Savitzky-Golay SG(N,L) filter

% i) Apply a SG(3,11) filter on the nECG signal
order = 3;
L = 2*11 + 1;
sg310ECG = sgolayfilt(noisy_ECG, order, L);

%% ii) Plot nECG, ECG_template and sg310ECG on the same plot
figure('Name','Applying Saviztsky Golay Filter (N,L)');
plot(time,noisy_ECG,'b',time, raw_ecg,'k',time, sg310ECG,'r');
legend ('noisy_ECG', 'ECG_template','sg310ECG')
title('Applying Saviztsky Golay Filter SG(3,11)')
xlabel('Time(s)')
ylabel('mV')

%% Optimum SG(N,L) filter parameters

%i) Calculate the MSE values for a range of parameters of the SG(N,L) filter and determine the optimum filter parameters which gives the minimum MSE

L_limit = 30;
N_max = min([(2*L_limit),30]); %since N < L'-1
err = NaN([L_limit,N_max]);

%initial optimum values
L_optimum = 1000;
N_optimum = 1000;
err_min = 1000;

for l = 1:L_limit
    n_max = min([(2*l),N_max]);
    for n = 1:n_max
        filtered_sig = sgolayfilt(noisy_ECG,n,(2*l+1));
        err(l,n) = immse(raw_ecg, filtered_sig);
        if (err_min > err(l,n))
            L_optimum = l;
            N_optimum = n;
            err_min = err(l,n);
        end
    end
end

figure('Name','Error vs Order of Saviztsky Golay Filters');
surf(err);
xlabel('Filter Length'), ylabel('Polynomial Order'), zlabel('MSE');

%% Plot ECG_template, sg310ECG and the signal obtained from optimum SG(N,L) filter
tic
opt_sgECG = sgolayfilt(noisy_ECG, N_optimum, (2*L_optimum)+1); 
toc

figure('Name','Comparing ECG_template, sg310ECG and opt_sgECG');
plot(time, noisy_ECG, 'y', time, raw_ecg, 'k', time, sg310ECG, 'b', time, opt_sgECG, 'r');
title('Comparing ECG_template, sg310ECG and opt_sgECG');
legend ('noisy_ECG', 'ECG_template','sg310ECG','opt_sgECG')
xlabel('Time(s)')
ylabel('mV')
N_optimum;

%% Compare signal features and computational complexity of the optimum filtered signals derived from MA(N) and SG(N,L) filters

kernel_opt = ones(optimum_ma_order,1) / optimum_ma_order;
tic
maoptECG = filter(kernel_opt, 1, noisy_ECG);
toc
group_delay_opt =  floor((optimum_ma_order-1)/2)*(1/fs);
delayed_time_opt = time - group_delay_opt;

figure('Name','Comparing optimum MA and SG fliter');
plot(time, noisy_ECG, 'g', time, raw_ecg, 'k', delayed_time_opt, maoptECG, 'b', time, opt_sgECG, 'r');
title('Comparing optimum MA and SG fliter');
legend ('noisy_ECG', 'ECG_template','opt_maECG','opt_sgECG')
xlabel('Time(s)')
ylabel('mV')


