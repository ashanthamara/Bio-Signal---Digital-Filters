%% 4.Designing FIR filters using windows
% 4.1.Designing FIR filters using windows
% using fdatool for 4.1
filterDesigner;

%% 4.2 FIR Filter design and application using the Kaiser window

% load the data set
load('ECG_with_noise.mat');
fs = 500;

%% i) Plot the time domain signal 

time = linspace(0,length(nECG)-1,length(nECG))/fs;
figure('Name','CG with noise')
plot(time, nECG)
title('ECG with noise'), xlabel('Time (s)'), ylabel('Amplitude (mV)')

%% power spectral density (PSD)
[pxx,f] = periodogram(nECG, rectwin(length(nECG)),[],fs);

semilogy(f,pxx)
grid on
title('Power Spectral Density Estimate of the Noisy ECG')
xlabel('Frequency (Hz)')
ylabel('Power')
%% Filters

%% Low Pass filter

% low pass filter pararmeters
Lp_Fpass = 123;
Lp_fstop = 127;
Lp_Wpass = (Lp_Fpass/fs)*2*pi;
Lp_Wstop = (Lp_fstop/fs)*2*pi;
Lp_Delta = 0.001;

% Values for the lowpass

Lp_Wdelta = abs(Lp_Wstop-Lp_Wpass);
Lp_A = -20*log10(Lp_Delta);

% calcluate beta
if Lp_A>50
    Lp_BETA = 0.1102*(Lp_A-8.7);
elseif ((Lp_A >= 21) && (Lp_A <= 50))
    Lp_BETA = (0.5842*(Lp_A-21).^0.4)+(0.07886*(Lp_A-21));
else
    Lp_BETA = 0;
end

% order
Lp_M = ceil((Lp_A-8)/(2.285*Lp_Wdelta));
% Creating a LP filter

Lp_Wc = (Lp_Wpass+Lp_Wstop)/2;
Ib = besseli(0,Lp_BETA); % zeroth order modified Bessel function of the first kind

for n = 1:Lp_M+1
% Calculating coefficients Kaiser window w(n)
x = Lp_BETA*sqrt(1-(((n-1)-Lp_M/2)/(Lp_M/2))^2);
I0 = besseli(0,x);
Lp_W(n) = I0/Ib;

% Calculating coefficients of desired impulse response hd(n)
if (n==floor(Lp_M/2))
    Lp_hd(n) = Lp_Wc/pi;
else
    Lp_hd(n) = sin(Lp_Wc*((n)-floor(Lp_M/2)))/(pi*((n)-floor(Lp_M/2)));
end
end

% Calculating coefficients actual impulse response h(n)
Lp_H = Lp_hd.*Lp_W;

figure('Name', 'Lowpass filter')
stem(0:Lp_M,Lp_H);
ylabel('Coefficients');
xlabel('n')
title('Lowpass filter');

% Getting the group delay of the LP filter
lpdelay = floor(Lp_M/2);


%% High Pass filter

HP_Fpass = 7;
HP_Fstop = 3;
HP_Wpass = (HP_Fpass/fs)*2*pi;
HP_Wstop = (HP_Fstop/fs)*2*pi;
HP_Delta = 0.001;

% Values for the higHP_Ass

HP_A = -20*log10(HP_Delta);

%Claculate Beta
if HP_A>50
    HP_BETA = 0.1102*(HP_A-8.7);
elseif ((HP_A >= 21) && (HP_A <= 50))
    HP_BETA = (0.5842*(HP_A-21).^0.4)+(0.07886*(HP_A-21));
else
    HP_BETA = 0;
end

HP_Wdelta = abs(HP_Wstop-HP_Wpass);
HP_M = ceil((HP_A-8)/(2.285*HP_Wdelta));


% Creating the higHP_Ass filter
HP_Wc = (HP_Wpass+HP_Wstop)/2;
Ib = besseli(0,HP_BETA); % zeroth order modified Bessel function of the first kind

for n = 1:HP_M+1
% Calculating coefficients Kaiser window w(n)
x = HP_BETA*sqrt(1-(((n-1)-HP_M/2)/(HP_M/2))^2);
I0 = besseli(0,x);
HP_W(n) = I0/Ib;

% Calculating coefficients of desired impulse response hd(n)
if (n==floor(HP_M/2))
    HP_hd(n) = 1 - (HP_Wc/pi);
else
    HP_hd(n) = -1.*sin(HP_Wc*((n)-floor(HP_M/2)))/(pi*((n)-floor(HP_M/2)));
end
end

% Calculating coefficients actual impulse response h(n)
HP_H = HP_hd.*HP_W;
figure
stem(0:HP_M,HP_H);
ylabel('Coefficients');
xlabel('n')
title('HigHP_Ass filter');


% Getting the group delay of the HP filter
hpdelay = floor(mean(grpdelay(HP_H)));

% Visualize both LP and HP filters

fvtool(Lp_H,1,HP_H,1);
legend('Low pass filter','High pass filter'); 

%% Comb filter

f1 = 50;
f2 = 100;
f3 = 150;

% Creating the comb filter

f0 = 50*ones(1,3);
w0 = (f0./fs)*2*pi;

n = 1:1:length(f0);

z = exp(1j*n.*w0);
z1 = conj(z);
combcoefficient = conv(conv(conv([1,-1.*z(1)],[1,-1.*z1(1)]),conv([1,-1.*z(2)],[1,-1.*z1(2)])),conv([1,-1.*z(3)],[1,-1.*z1(3)]));
G = 1/abs(sum(combcoefficient));
b_comb = combcoefficient.*G;


% Getting the group delay of the low pass filter
combdelay = floor(mean(grpdelay(b_comb)));

fvtool(b_comb,1);


%% Applying filters in following order
% Low pass
% Highpass
% Comb

%Adding the low pass filter to the nECG

LP_filtered = filter(Lp_H,1,nECG);
% Compensating the  low pass filter

LP_compensated = [LP_filtered zeros(1,lpdelay)];
LP_compensated = LP_compensated(1+lpdelay:length(nECG)+lpdelay);

% Adding the high pass filter to the LP filtered signal 

LPHP_filtered = filter(HP_H,1, LP_compensated);

% Compensating the  high pass filter
LPHP_compensated = [LPHP_filtered zeros(1,hpdelay)];
LPHP_compensated = LPHP_compensated(1+hpdelay:length(nECG)+hpdelay);


% plotting the low pass filter application

figure;
plot(time,nECG,time,LP_compensated);
xlabel('Time(ms)');
ylabel('Amplitude(mV)');
legend('Noisy ECG','Compensated LP filtered');
title('Application of the LP filter');
%axis([500 1000 -0.8 1.1]);

% plotting the high pass filter application

figure;
plot(time,nECG,time,LPHP_compensated);
xlabel('Time(ms)');
ylabel('Amplitude(mV)');
legend('Noisy ECG','Compensated LP HP filtered');
title('Application of the LP and HP filter');
%axis([500 1000 -0.8 1.1]);

% Adding the comb filter to the LP and HP filtered signal 

LPHPComb_filtered = filter(b_comb,1,LPHP_compensated);
LPHPComb_compensated = [LPHPComb_filtered zeros(1,combdelay)];
LPHPComb_compensated = LPHPComb_compensated(1+combdelay:length(nECG)+combdelay);

% plotting the cascaded filter application

figure;
plot(time,nECG,time,LPHPComb_compensated);
xlabel('Time(ms)');
ylabel('Amplitude(mV)');
legend('Noisy ECG','3 filter output');
title('Application of the LP HP and comb filter in time domain');

%% Cascading the filters
cascadedh = conv(conv(Lp_H,HP_H),b_comb);
fvtool(cascadedh,1);


%% plotting the psd of the input and the output of the cascade

[Pxx_cas,Fxx_cas] = periodogram(LPHPComb_compensated,[],length(LPHPComb_compensated),fs);
[Pxx_raw,Fxx_raw] = periodogram(nECG,[],length(nECG),fs);
figure,
semilogy(Fxx_cas,Pxx_cas, Fxx_raw,Pxx_raw);
grid on
title('Power Spectral Density Estimate of the Filtered ECG')
legend('Filtered ECG','Noisy ECG');
xlabel('Frequency (Hz)')
ylabel('Power')


