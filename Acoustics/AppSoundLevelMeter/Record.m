function [signal,Fs,Nbits,time,nfft]=Record(refreshRate)

%%This function records audio from the microphone and writes the audio into
%%a wav file in Record Mode.

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

%%Acquisition settings 
sampleRate            = 48000;  % Hz
N=24; %N-bit/ sample

ai                    = analoginput('winsound');
addchannel(ai,1);
sampleRate            = setverify(ai, 'SampleRate', sampleRate);
ai.TimerPeriod        = refreshRate;
spt                   = ceil(sampleRate * refreshRate);
ai.SamplesPerTrigger  = spt;
nfft=spt;
set(ai,'SamplesPerTrigger',nfft);
%%

% Start Acquisition %%
start(ai);
[data time] = getdata(ai);
%

%Record Acquisition
wavwrite(data,sampleRate,N,'Recording.wav');
%
[signal,Fs,Nbits]=wavread('Recording.wav');
delete(ai);
clear ai
