
function [ai,nfft,sampleRate] = initSC

%%This function initializes the analog input object to acquire audio data in Real Time Mode.

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

%%Acquisition settings

sampleRate            = 48000;  % Hz

nfft=3000;
refreshRate=nfft/sampleRate;

ai                    = analoginput('winsound');
addchannel(ai,1);
sampleRate            = setverify(ai, 'SampleRate', sampleRate);


set(ai,'SamplesPerTrigger',nfft);
nfft = get(ai,'SamplesPerTrigger');

% Set acquisition options.
set(ai,'TriggerType','Manual');
set(ai,'TriggerRepeat',Inf);
set(ai,'TimerPeriod',refreshRate);

% Begin acquisition.
start(ai); trigger(ai);
ai.InitialTriggerTime;
