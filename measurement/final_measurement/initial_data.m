function [fs,frequencyRange,gain,inputChannel,sweepTime,cmd] = initial_data(cmd)
%%
gain = -35;
cmd = cmd %'test'
inputChannel = [9 10 11 12];
frequencyRange = [20 22000];
sweepTime = 5;
fs = 44100;