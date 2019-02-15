clear all
close all
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
port = '/dev/ttyACM0';

s = serial (port)
s.BaudRate = 115200;
fopen (s)
out = fscanf(s)