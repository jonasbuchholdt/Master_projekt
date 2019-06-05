%% 

% the loaded filt is the data as: dataXY_withZ_foam_U
% X is the measurement number
% Y is either up or down, which mean that the windscreen is up in the ear
% hight or on the ground
% Z shows if the measurement is with or without the foam wedge
% U display the rotation where positive angle is p which rotate the
% windscreen opening more agenst the wind. some is not given with p, thoes
% is positive.
clear 

down1 = 1;
down2 = 7;
down3 = 50;
down4 = 700;

load('wind_noise.mat')


Fs = 44100;
L = length(data0down_with_foam_n30.wind_noise);


ws = mean([data0down_with_foam_n30.wind_speed1])



X = data0down_with_foam_n30.wind_noise;

            L = numel(X);
            W = hann(L); 


Y = fft(X.*W);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);




w = (Fs*(0:(L/2))/L)';
f_axis = [downsample(w(1:716),down1); downsample(w(716+1:7152),down2); downsample(w(7152+1:71518),down3); downsample(w(71518+1:end),down4)];


tf_mes = P1;
db_mes = 20*log10(abs(tf_mes/(20*10^-6)))+10;
db_mes = [downsample(db_mes(1:716),down1); downsample(db_mes(716+1:7152),down2); downsample(db_mes(7152+1:71518),down3); downsample(db_mes(71518+1:end),down4)];
db_mes = [db_mes(1:37); movmean(db_mes(37+1:end),3)];




figure(2)
semilogx(f_axis,db_mes);
hold on
grid on
grid minor
axis([2 20000 -40 90])
xlabel('Frequency [Hz]')
ylabel('SPL [dB]')