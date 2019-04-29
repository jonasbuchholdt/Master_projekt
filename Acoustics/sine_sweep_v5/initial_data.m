function [fs,calibration,frequencyRange,gain,inputChannel,sweepTime,a,b,cmd] = initial_data(cmd)
%%
gain = -35;
load('calibration.mat');
load('highPass20.mat');
[b,a]=sos2tf(SOS,G);
cmd = cmd %'test'
inputChannel = [9 10 11 12];
frequencyRange = [20 22000];
sweepTime = 5;
fs = 44100;