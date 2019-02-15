function [signal_ref,Fs_ref,Nbits_ref,p_pascal]= mic_calibration()

%% Calibration %%

%%This function records a sound into a wav file and it assigns his level in
%%order to calibrate the system.

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

    %% Set Acquisition %%     
duration=input('\nInsert duration (s) and press enter to start recording :\n');
refreshRate=duration;

sampleRate            = 48000;  % Hz
ai                    = analoginput('winsound');
addchannel(ai,1);
sampleRate            = setverify(ai, 'SampleRate', sampleRate);
ai.TimerPeriod        = refreshRate;
spt                   = ceil(sampleRate * refreshRate);
ai.SamplesPerTrigger  = spt;
nfft=spt;
set(ai,'SamplesPerTrigger',nfft);

%% Start Acquisition %%
start(ai);
[data,time] = getdata(ai);

wavwrite(data,sampleRate,'calibration_signal_user.wav');

[signal_ref,Fs_ref,Nbits_ref]=wavread('calibration_signal_user.wav');

figure;plot(time,signal_ref);
ylim([-1 1])
set(gcf,'Name','User Calibration Signal');
set(gcf,'NumberTitle','off','MenuBar','none');

level=input('\nInsert dB SPL :\n');
p_pascal=(10^(level/20))*2*10^(-5);

