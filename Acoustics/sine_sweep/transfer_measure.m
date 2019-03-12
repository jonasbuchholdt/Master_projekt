
%% Calibrate the soundcard
clear all
gain = -18;
cmd = 'cali_soundcard'
Lacoustics(cmd,gain);

%% Show calibration of soundcard
clear all
gain = -18;
cmd = 'test'
[f_axis,f_result,t_axis,t_result] = Lacoustics(cmd,gain);
load('calibration.mat')
transfer_function = f_result./calibration.preamp_transfer_function;
result = 20*log10(abs(transfer_function));
semilogx(f_axis,result)
hold on
grid on
axis([20 20000 -1 1])
xlabel('Frequency [Hz]')
ylabel('[dB]')
%clear calibration

%% Calibrate the microphone
clear all
cmd = 'cali_mic'
gain = 0;
Lacoustics(cmd,gain);

%% Show calibration of microphone
load('calibration.mat')
p0 = 20*10^(-6);
fs = 48000; 
blength = 3;
soundcard = audioDeviceReader('SampleRate',fs,'SamplesPerFrame',2048);          % setting up audio object
buffer = zeros(blength * fs, 1);            % initializing audio buffer
tic;
while toc < 10
    audioin = soundcard()/calibration.mic_sensitivity;                  % fetch samples from soundcard
    buffer = [buffer(2049:end); audioin];   % update buffer
end
out = 20*log10(rms(buffer)*sqrt(2)/p0)
clear calibration



%% sound meter
fs = 48000; 
[L_pF,L_pS] = OneThirdOctaveAnalyser(0.125,1,buffer(1:48000*2),fs);
bar(L_pS)
hold on
bar(L_pF)

%% Make impulse response
clear all
cmd = 'transfer'
gain = -18;
[f_axis,f_result,t_axis,t_result] = Lacoustics(cmd,gain);

result=20*log10(abs(f_result)/(20*10^-6));

figure(1)
semilogx(f_axis,result)
hold on
grid on

axis([20 20000 60 140])
xlabel('Frequency [Hz]')
ylabel('Pressure [Pa]')



%% make reverb calculation
clear all
cmd = 'transfer'
gain = -18;
[f_axis,f_result,t_axis,t_result] = Lacoustics(cmd,gain);

t_reverb = flip(t_result).^2;

Q = trapz(t_reverb)








