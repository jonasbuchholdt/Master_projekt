function [fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data(cmd)
%%
gain = -27;
load('offset.mat');
load('calibration.mat');
load('highPass20.mat');
[b,a]=sos2tf(SOS,G);
cmd = cmd %'test'
inputChannel = [1 2];
frequencyRange = [20 22000];
sweepTime = 5;
fs = 44100;