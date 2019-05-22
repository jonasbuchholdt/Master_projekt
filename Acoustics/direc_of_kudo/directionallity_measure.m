

%% microphone calibration
clear all
cmd = 'cali_mic'
gain = -18;
[x_axis,result] = Lacoustics(cmd,gain);
load('calibration.mat')



%%
clear all
cmd = 'transfer'
gain = -18;
[x_axis,result] = Lacoustics(cmd,gain);

result = abs(result);
result=20*log10(result/(20*10^-6));

figure(1)
semilogx(result)
hold on
grid on

axis([20 20000 20 100])
xlabel('Frequency [Hz]')
ylabel('Pressure [Pa]')

%%

% Automated Loudspeaker Directivity Measurement
% Using log. sine sweeps and a UDP-controled turntable
% based on MATLAB-Example ImpulseResponseMeasurer
%
% 2018-02-21
%
% -------------------------------------------------------------------------

clear variables

[fs,calibration,frequencyRange,gain,inputChannel,sweepTime,a,b,cmd] = initial_data('transfer');

circres= 5;                             % angle resolution on circumference [degree]


filename='KUDO_direc_without.mat';                  % file name for storage                                   

ET250_3D('udp_start')

for k = 1:(360/circres)
    clear out
    out=struct;
    currentangle=k*circres;
    storename=strcat('data',int2str(currentangle*10));
    if currentangle == 360
        currentangle = 0;
    end    
     ET250_3D('set',currentangle);
     pause(1)
     actualangle=ET250_3D('get');
     
     while currentangle~=actualangle
         pause(1)
         actualangle=ET250_3D('get')
     end
    pause(1);
        [out.ir,irtime,res]=IRmeas_fft(sweepTime,frequencyRange,gain,inputChannel,fs);
        if res == 1
            [out.ir,irtime,res]=IRmeas_fft(sweepTime,frequencyRange,gain,inputChannel,fs);
        end
        assignin('base',storename,out);
        if k==1
            save(filename,'irtime');
        end
        save(filename,storename,'-append');
        clear (storename)
end

ET250_3D('udp_stop')
%%


%%
clear
down1 = 1;
down2 = 1;
down3 = 20;
down4 = 50;
load('KUDO_direc_25_25.mat')
[fs,calibration,frequencyRange,gain,inputChannel,sweepTime,a,b,cmd] = initial_data('transfer');

ir_result=data3600.ir(1:end/2);     

[tf,w] = freqz(ir_result,1,frequencyRange(2),fs);
f_axis = w;
result=20*log10(abs(tf/(20*10^-6)));

f_axis = [downsample(f_axis(1:100),down1); downsample(f_axis(100+1:1000),down2); downsample(f_axis(1000+1:9978),down3); downsample(f_axis(9978+1:end),down4)];
result_d = [downsample(result(1:100),down1); downsample(result(100+1:1000),down2); movmean(downsample(result(1000+1:9978),down3),3); movmean(downsample(result(9978+1:end),down4),7)];

result_d = movmean(result_d,2);
figure(2)
semilogx(f_axis,result_d)
hold on
grid on
grid minor
axis([20 20000 40 120])
xlabel('Frequency [Hz]')
ylabel('Level [dB]')



%%
figure(1)
volt = (4.7*(10^(-18/20))*(10^((44-16)/20)))/sqrt(2);
result = (abs(data3600.tf));
result=20*log10(result/(20*10^-6));

semilogx(faxis,result)

grid on
axis([20 20000 50 100])
xlabel('Frequency [Hz]')
ylabel('Sensitivity @ (2.74 m,10.5 V) [dB SPL]')
