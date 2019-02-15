clear all
close all
fs = 48000;
load('impulse.mat')
load('impulse_axis.mat')
load('HP_ck.mat')               % 75 Hz Butter IIR HP @48k
[b,a] = sos2tf(SOS,G);
t_filtered = filter(b,a,t_result);

IRdeadzone = 0.1*fs;

IRlength = length(t_filtered);
noise = rms(t_filtered((IRlength/2):end-(round(IRlength/5))));
noisethres = noise*0.002;
noiseindex = (abs(t_filtered)<noisethres);
deadzonekiller = noiseindex>IRdeadzone;
k=find(noiseindex);
k(1)
%noiseindex = find(noiseindex.*deadzonekiller);

%%
i_length = noiseindex(1);
short_I=(t_filtered(1:i_length)).^2;
decay_curve=zeros(length(short_I),1);
for k=1:length(short_I)
    decay_curve(k,1)=sum(short_I(k:end));
end
level=10*log10((decay_curve)./max(decay_curve));

t20start = find(round(level,1)==-5);
t20end = find(round(level,1)==-25);
t20s = t_axis(t20start(1));
t20e = t_axis(t20end(1));

T20 = 3*(t20e-t20s)

t30start = find(round(level,1)==-5);
t30end = find(round(level,1)==-35);
t30s = t_axis(t30start(1));
t30e = t_axis(t30end(1));

T30 = 2*(t30e-t30s)

%figure
%plot(t_axis(1:i_length),level)
