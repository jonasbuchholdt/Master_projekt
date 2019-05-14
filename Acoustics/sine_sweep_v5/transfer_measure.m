%% make calibration file
clear;
calibration = struct;            
calibration.date=date;            
save('calibration.mat','calibration');

data = struct;
save('data.mat','data');

%% Calibrate the microphone
clear;
[fs,~,frequencyRange,gain,inputChannel,sweepTime,~,~,cmd] = initial_data('cali_mic');
%Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);

L = 2048; %1024;
            fileReader = dsp.AudioFileReader('sweep.wav','SamplesPerFrame',L);
            fs = fileReader.SampleRate;
           
            aPR = audioPlayerRecorder('SampleRate',fs,...               % Sampling Freq.
                          'RecorderChannelMapping',inputChannel,...  % Input channel(s)
                          'PlayerChannelMapping',[1 2],... % Output channel(s)
                          'SupportVariableSize',true,...    % Enable variable buffer size 
                          'BufferSize',L);                  % Set buffer size
    
                      
                      out = [];                      
                      while ~isDone(fileReader)
                          audioToPlay = fileReader();
                          [audioRecorded,nUnderruns,nOverruns] = aPR(audioToPlay);
                          out = [out; audioRecorded];
                          if nUnderruns > 0
                              fprintf('Audio player queue was underrun by %d samples.\n',nUnderruns);
                          end
                          if nOverruns > 0
                              fprintf('Audio recorder queue was overrun by %d samples.\n',nOverruns);
                          end
                      end
                      release(fileReader);
                      release(aPR);
                      y = out;
                      

            add = rms(y);          
            load('calibration.mat')
            calibration.mic_sensitivity(3) = add;

        %calibration.mic_sensitivity = 0.0367; 
        save('calibration.mat','calibration','-append');   


%% calibrate One Third octave analysis 
clear;
[fs,calibration,frequencyRange,gain,inputChannel,sweepTime,a,b,cmd] = initial_data('transfer');
[~,ir] = Lacoustics(cmd,gain,inputChannel,frequencyRange,sweepTime,fs);
ir_result=filter(b,a,ir(1:length(ir)/2));
p0 = 20*10^(-6);
BW = '1/3 octave'; 
N = 8;
F0 = 1000;
oneThirdOctaveFilter = octaveFilter('FilterOrder', N, ...
    'CenterFrequency', F0, 'Bandwidth', BW, 'SampleRate', fs);
F0 = getANSICenterFrequencies(oneThirdOctaveFilter);
F0(F0<16) = [];
F0(F0>20e3) = [];
Nfc = length(F0);

for i=1:Nfc
    oneThirdOctaveFilterBank{i} = octaveFilter('FilterOrder', N, ...
        'CenterFrequency', F0(i), 'Bandwidth', BW, 'SampleRate', fs);
end
clear oneThirdOctaveFilter
yp = zeros(length(ir_result),Nfc);

for i=1:Nfc
    oneThirdOctaveFilter = oneThirdOctaveFilterBank{i};
    yp(:,i) = oneThirdOctaveFilter(ir_result*4500);
end
L_Aeqthird = 10*log10(1/(length(yp))*trapz(yp.^2/p0^2));
off = zeros(1,length(L_Aeqthird));

for i = 1:length(L_Aeqthird)-1
    off(i) = L_Aeqthird(30) - L_Aeqthird(i);
 end
off(30) = 0;
mic_cal = L_Aeqthird(30)-94;
off = off-mic_cal;
calibration.octave=off; 
save('calibration.mat','calibration','-append');  

%%
filename='impulses_n.mat';
reset_date = date;
save(filename,'reset_date');
%% Make impulse response
clear;

filename='impulses_2.mat';
number = 10;
angle = 90;
storename=strcat('data',int2str(number),'tile_n5_angle',int2str(angle));


[fs,calibration,frequencyRange,gain,inputChannel,sweepTime,a,b,cmd] = initial_data('transfer');

[ir,ir_axis,res,weather,weathertime]=IRmeas_fft(sweepTime,frequencyRange,gain,inputChannel,fs);
if res == 1
    [ir,ir_axis,res,weather,weathertime]=IRmeas_fft(sweepTime,frequencyRange,gain,inputChannel,fs);
end


wind_speed1 = weather(:,1);
wind_direction1 = weather(:,2)/1024*359;
wind_speed2 = weather(:,3);
wind_direction2 = weather(:,4)/1024*359;
temp = weather(:,5);
humidity = weather(:,6);


%load('highPass20.mat');
%        [b,a]=sos2tf(SOS,G);
%        ir=filter(b,a,ir);
        

        
 wind_speed_m1 = movmean(wind_speed1,1);
wind_direction_m1 = movmean(wind_direction1,1);
wind_speed_m2 = movmean(wind_speed2,1);
wind_direction_m2 = movmean(wind_direction2,1);
temp_m = movmean(temp,1);
humidity_m = movmean(humidity,1);



ir_result=ir(:,2);   

[tf,w] = freqz(ir_result,1,frequencyRange(2),fs);
f_axis = w;
result=20*log10(abs(tf/(20*10^-6)));

figure(1)
subplot(5,1,1);
plot(w,result)
title('Audio')
grid on
axis([50 20000 20 100])

subplot(5,1,2);
plot(weathertime,wind_speed_m1)
hold on
plot(weathertime,wind_speed_m2)
title('Wind speed')
grid on
axis([0 5 0 15])

subplot(5,1,3);
plot(weathertime,wind_direction_m1)
hold on
plot(weathertime,wind_direction_m2)
title('Wind direction')
grid on
axis([0 5 0 360])

subplot(5,1,4);
plot(weathertime,temp_m)
title('Temperature')
grid on
axis([0 5 0 30])

subplot(5,1,5);
plot(weathertime,humidity_m)
title('Humidity')
grid on
axis([0 5 0 100])       


data.ir_downwards = ir(:,1);
data.ir_center = ir(:,2);
data.ir_upwards = ir(:,3);
data.irtime = ir_axis;
data.wind_speed1 = wind_speed1;
data.wind_speed2 = wind_speed2;
data.wind_direction1 = wind_direction1;
data.wind_direction2 = wind_direction2;
data.temp = temp;
data.humidity = humidity;
data.weathertime = weathertime;

assignin('base',storename,data);
save(filename,storename,'-append');
 
 ir_result=ir(:,1);   

[tf,w] = freqz(ir_result,1,frequencyRange(2),fs);
f_axis = w;
result=20*log10(abs(tf/(20*10^-6)))+10;
 figure(2)
semilogx(w,result+10)
hold on
title('Audio')
grid on
axis([50 20000 20 110])


 ir_result=ir(:,2);   

[tf,w] = freqz(ir_result,1,frequencyRange(2),fs);
f_axis = w;
result=20*log10(abs(tf/(20*10^-6)))+10;
 figure(2)
semilogx(w,result+10)
hold on
title('Audio')
grid on
axis([50 20000 20 110])


 ir_result=ir(:,3);   

[tf,w] = freqz(ir_result,1,frequencyRange(2),fs);
f_axis = w;
result=20*log10(abs(tf/(20*10^-6)))+10;
 figure(2)
semilogx(w,result+10)
hold on
title('Audio')
grid on
axis([50 20000 20 110])

%%

load('impulses_2.mat')

ir_result=data1calibrate0.ir_center;   

[tf,w] = freqz(ir_result,1,frequencyRange(2),fs);
f_axis = w;
result=20*log10(abs(tf/(20*10^-6)))+10;
 figure(2)
semilogx(w,result+10)

%% single number spl

sweepTime = 5;
%load('intelligibility_filter.mat');
%[b,a]=sos2tf(SOS,G);
 %filter(b,a,ir_a(1:3750+fs/100,k));%length(ir_a(:,k)/2),k));
 
[fs,calibration,frequencyRange,gain,inputChannel,sweepTime,a,b,cmd] = initial_data('transfer');

load('KUDO_direc_25_55.mat');

ang_n_0 = data3600.ir;
ang_p_0 = data3600.ir;
ang_n_5 = data3550.ir;
ang_n_10 = data3500.ir;
ang_n_15 = data3450.ir;
ang_n_20 = data3400.ir;
ang_n_25 = data3350.ir;
ang_n_30 = data3300.ir;
ang_n_35 = data3250.ir;
ang_n_40 = data3200.ir;
ang_n_45 = data3150.ir;
ang_n_50 = data3100.ir;
ang_n_55 = data3050.ir;
ang_n_60 = data3000.ir;

ang_p_5 = data50.ir;
ang_p_10 = data100.ir;
ang_p_15 = data150.ir;
ang_p_20 = data200.ir;
ang_p_25 = data250.ir;
ang_p_30 = data300.ir;
ang_p_35 = data350.ir;
ang_p_40 = data400.ir;
ang_p_45 = data450.ir;
ang_p_50 = data500.ir;
ang_p_55 = data550.ir;
ang_p_60 = data600.ir;

%impulse = abcfilt(impulse,'a'); % a weighting
%impulse(:,k)=filter(b,a,impulse(:,k)); % intilligibility weighting

angle = 0;

[tf,w] = freqz(ang_p_0,1,frequencyRange(2),fs);
f_axis = w;
result_c=20*log10(abs(tf/(20*10^-6)));
l_eq(1) = 10*log10(((1/(sweepTime))*sum((ang_p_0.^2)))/(20*10^-6).^2);

[tf,w] = freqz(eval(strcat('ang_p_',int2str(25-angle))),1,frequencyRange(2),fs);
f_axis = w;
result_u=20*log10(abs(tf/(20*10^-6)));
l_eq(2) = 10*log10(((1/(sweepTime))*sum((ang_p_25.^2)))/(20*10^-6).^2);

[tf,w] = freqz(eval(strcat('ang_n_',int2str(25+angle))),1,frequencyRange(2),fs); %45
f_axis = w;
result_d=20*log10(abs(tf/(20*10^-6)));
l_eq(3) = 10*log10(((1/(sweepTime))*sum((ang_n_25.^2)))/(20*10^-6).^2);

result_d_diff = result_c-result_d;
result_u_diff = result_c-result_u;

figure(3)
%semilogx(f_axis,result_c)

semilogx(f_axis,movmean(result_u_diff,40))
hold on
semilogx(f_axis,movmean(result_d_diff,40))
grid on
grid minor
axis([50 20000 -10 20])
xlabel('Frequency [Hz]')
ylabel('Level [dB]')
legend('upwards','downwards','diff')

%%
clear 
load('impulses_2.mat');
[fs,calibration,frequencyRange,gain,inputChannel,sweepTime,a,b,cmd] = initial_data('transfer');
load('40Hz_2order_filter.mat');
[b,a]=sos2tf(SOS,G);


down1 = 1;
down2 = 1;
down3 = 20;
down4 = 50;

angle = 0;
ir_number = 11;


ir_no = ir_number;
ir_no_st = ir_number;


clear ir_downwards
clear ir_upwards
start=1;
ir_num = 22;

for i=start:1:ir_num
number = i;
ir_downwards_pre(:,i) = eval(strcat('data',int2str(number),'angle',int2str(angle),'.ir_downwards'));
ir_center_pre(:,i) = eval(strcat('data',int2str(number),'angle',int2str(angle),'.ir_center'));
ir_upwards_pre(:,i) = eval(strcat('data',int2str(number),'angle',int2str(angle),'.ir_upwards'));

wind_speed1(:,i) = eval(strcat('data',int2str(number),'angle',int2str(angle),'.wind_speed1'));
wind_speed2(:,i) = eval(strcat('data',int2str(number),'angle',int2str(angle),'.wind_speed2'));
wind_direction1(:,i) = eval(strcat('data',int2str(number),'angle',int2str(angle),'.wind_direction1'));
wind_direction2(:,i) = eval(strcat('data',int2str(number),'angle',int2str(angle),'.wind_direction2'));
temp(:,i) = eval(strcat('data',int2str(number),'angle',int2str(angle),'.temp'));
humidity(:,i) = eval(strcat('data',int2str(number),'angle',int2str(angle),'.humidity'));
end


ir_downwards_no = (ir_downwards_pre(1:20000,ir_no_st:ir_no)*10^(10/20))*10^(5/20);
ir_center_no = (ir_center_pre(1:20000,ir_no_st:ir_no)*10^(10/20))*10^(5/20);
ir_upwards_no = (ir_upwards_pre(1:20000,ir_no_st:ir_no)*10^(10/20)*1.03)*10^(5/20); 


% window
L = numel(ir_upwards_no);
mu_low = 5000;
mu_high = 13000;
sigma = 600;
x = [1:1:L];
wdummy = ones(L,1)';
window_low  = cdf('Normal',x,mu_low,sigma);
window_high  = wdummy - cdf('Normal',x,mu_high,sigma);
window = (window_low .* window_high)';

%plot(ir_upwards_no)
%hold on
%plot(ir_downwards_no)
%plot(window./300)

ir_downwards_fi=filter(b,a,ir_downwards_no);
ir_downwards_win = ir_downwards_fi.*window;
ir_center_fi=filter(b,a,ir_center_no);
ir_center_win = ir_center_fi.*window;
ir_upwards_fi=filter(b,a,ir_upwards_no);
ir_upwards_win = ir_upwards_fi.*window;

load('150Hz_2order_filter.mat');
[b,a]=sos2tf(SOS,G);

ir_downwards=filter(b,a,ir_downwards_win);
ir_center=filter(b,a,ir_center_win);
ir_upwards=filter(b,a,ir_upwards_win);


windspeed = mean([wind_speed1(:,ir_no_st:ir_no); wind_speed2(:,ir_no_st:ir_no)])
windsdirection = mean([wind_direction1(:,ir_no_st:ir_no); wind_direction2(:,ir_no_st:ir_no)])-180-20



irtime = eval(strcat('data',int2str(number),'angle',int2str(angle),'.irtime'));
weathertime = eval(strcat('data',int2str(number),'angle',int2str(angle),'.weathertime'));




BW = '1 octave';
N = 6;           % Filter Order
F0 = 1000;       % Center Frequency (Hz)
Fs = 44100;      % Sampling Frequency (Hz)
oneOctaveFilter = octaveFilter('FilterOrder', N, ...
    'CenterFrequency', F0, 'Bandwidth', BW, 'SampleRate', Fs)

F0 = getANSICenterFrequencies(oneOctaveFilter);
F0(F0<150) = [];
F0(F0>20e3) = [];
F0(7)=1.584893192461113e+04;
Nfc = length(F0);
for i=1:Nfc
    fullOctaveFilterBank{i} = octaveFilter('FilterOrder', N, ...
        'CenterFrequency', F0(i), 'Bandwidth', BW, 'SampleRate', Fs); %#ok
end


for i=1:Nfc
        fullOctaveFilter = fullOctaveFilterBank{i};
        l_eq_center(i) = 10*log10(((1/(sweepTime))*sum((fullOctaveFilter(ir_center).^2)))/(20*10^-6).^2);
        l_eq_upwards(i) = 10*log10(((1/(sweepTime))*sum((fullOctaveFilter(ir_upwards).^2)))/(20*10^-6).^2);
        l_eq_downwards(i) = 10*log10(((1/(sweepTime))*sum((fullOctaveFilter(ir_downwards).^2)))/(20*10^-6).^2);
end

b=1;
for i=3:Nfc
result(b) = l_eq_upwards(i);
result(b+1) = l_eq_center(i);
result(b+2) = l_eq_downwards(i);
b=b+3;
end
result = round(result);
%%
% ir = ir_downwards(1:end/2,:);
% [m,ir_num] = size(ir);
% 
% for i=start:1:ir_num
% %ir(:,i)=filter(b,a,ir(:,i));
% end
% 
% for i=start:1:ir_num
%     r(:,i) = xcorr(ir(:,1),ir(:,i));
%     [M,inde1(i)] = max(r(:,i));
% end
% shif1 = inde1' - inde1(1);
% 
% for i=start:1:ir_num
%     ir_shift(:,i) = circshift(ir(:,i),shif1(i));
% end
% 
% for i=start:1:ir_num
%     r(:,i) = xcorr(ir_shift(:,1),ir_shift(:,i));
%     [M,inde1_ch(i)] = max(r(:,i));
% end
% shif1_ch = inde1_ch - inde1_ch(1);
% 
% ir_downwards = mean(ir_shift,2);
% ir_downwards = ir_downwards(6000:10000);
% 
% 
% 
% 
% clear ir_shift
% clear ir
% clear r
% clear ir_shift
% clear inde1_ch
% clear M
% 
% ir = ir_upwards(1:end/2,:);
% [m,ir_num] = size(ir);
% 
% for i=start:1:ir_num
% %ir(:,i)=filter(b,a,ir(:,i));
% end
% 
% for i=start:1:ir_num
%     r(:,i) = xcorr(ir(:,1),ir(:,i));
%     [M,inde1(i)] = max(r(:,i));
% end
% shif1 = inde1' - inde1(1);
% 
% for i=start:1:ir_num
%     ir_shift(:,i) = circshift(ir(:,i),shif1(i));
% end
% 
% for i=start:1:ir_num
%     r(:,i) = xcorr(ir_shift(:,1),ir_shift(:,i));
%     [M,inde1_ch(i)] = max(r(:,i));
% end
% shif1_ch = inde1_ch - inde1_ch(1);
% 
% ir_upwards = mean(ir_shift,2);
% ir_upwards = ir_upwards(6000:10000);
% 
% 
% % center cal
% clear ir_shift
% clear ir
% clear r
% clear ir_shift
% clear inde1_ch
% clear M
% 
% ir = ir_center(1:end/2,:);
% [m,ir_num] = size(ir);
% 
% for i=start:1:ir_num
% %ir(:,i)=filter(b,a,ir(:,i));
% end
% 
% for i=start:1:ir_num
%     r(:,i) = xcorr(ir(:,1),ir(:,i));
%     [M,inde1(i)] = max(r(:,i));
% end
% shif1 = inde1' - inde1(1);
% 
% for i=start:1:ir_num
%     ir_shift(:,i) = circshift(ir(:,i),shif1(i));
% end
% 
% for i=start:1:ir_num
%     r(:,i) = xcorr(ir_shift(:,1),ir_shift(:,i));
%     [M,inde1_ch(i)] = max(r(:,i));
% end
% shif1_ch = inde1_ch - inde1_ch(1);
% 
% ir_center = mean(ir_shift,2);
% ir_center = ir_center(6000:10000);



%ir_downwards = abcfilt(ir_downwards,'a'); % a weighting
%ir_upwards = abcfilt(ir_upwards,'a'); % a weighting
%ir_center = abcfilt(ir_center,'a'); % a weighting



%ret = mean(mean(wind_direction1(:,ir_no_st:ir_no)));
%spe = mean(mean([wind_speed1(:,ir_no_st:ir_no); wind_speed2(:,ir_no_st:ir_no)]));

% weighting
%ir_downwards = abcfilt(ir_downwards,'a'); % a weighting
%ir_upwards = abcfilt(ir_upwards,'a'); % a weighting
%ir_center = abcfilt(ir_center,'a'); % a weighting

%spl and frequency response
[tf,w] = freqz(ir_center,1,frequencyRange(2),fs);
result_c=20*log10(abs(tf/(20*10^-6)));
l_eq(1) = 10*log10(((1/(sweepTime))*sum((ir_center.^2)))/(20*10^-6).^2);


[tf,w] = freqz(ir_upwards,1,frequencyRange(2),fs);
result_u=20*log10(abs(tf/(20*10^-6)));
l_eq(2) = 10*log10(((1/(sweepTime))*sum((ir_upwards.^2)))/(20*10^-6).^2);


[tf,w] = freqz(ir_downwards,1,frequencyRange(2),fs);
f_axis =w;
result_d=(20*log10(abs(tf/(20*10^-6))));
l_eq(3) = 10*log10(((1/(sweepTime))*sum((ir_downwards.^2)))/(20*10^-6).^2)


% add differences
%result_c = result_c;
%result_d = result_d + result_u_diff;
%result_u = result_u + result_d_diff;


%weather

upwards_refraction = movmean(result_u,1);
downwards_refraction = movmean(result_d,1);
center_refraction = movmean(result_c,1);

f_axis = [downsample(f_axis(1:100),down1); downsample(f_axis(100+1:1000),down2); downsample(f_axis(1000+1:9978),down3); downsample(f_axis(9978+1:end),down4)];
upwards_refraction = [downsample(upwards_refraction(1:100),down1); downsample(upwards_refraction(100+1:1000),down2); downsample(upwards_refraction(1000+1:9978),down3); downsample(upwards_refraction(9978+1:end),down4)];
downwards_refraction = [downsample(downwards_refraction(1:100),down1); downsample(downwards_refraction(100+1:1000),down2); downsample(downwards_refraction(1000+1:9978),down3); downsample(downwards_refraction(9978+1:end),down4)];
center_refraction = [downsample(center_refraction(1:100),down1); downsample(center_refraction(100+1:1000),down2); downsample(center_refraction(1000+1:9978),down3); downsample(center_refraction(9978+1:end),down4)];

upwards_refraction = movmean(upwards_refraction,10);
downwards_refraction = movmean(downwards_refraction,10);
center_refraction = movmean(center_refraction,10);



wx = [1:20500/55:20500];
wx = 10.^((wx/234.2)/20);

figure(10)
subplot(5,1,1);
semilogx(f_axis,center_refraction)
hold on
semilogx(f_axis,upwards_refraction)
semilogx(f_axis,downwards_refraction)
grid on
grid minor
axis([20 20000 20 100])
ylabel('Level [dB]')
%legend({'upwards'},'Location','southwest')



subplot(5,1,2);
semilogx(wx,wind_speed1(:,ir_no_st:ir_no))
hold on
semilogx(wx,wind_speed2(:,ir_no_st:ir_no))
ylabel('Wind speed []')
grid on
grid minor
axis([20 20000 0 12])
 
subplot(5,1,3);
semilogx(wx,wind_direction1(:,ir_no_st:ir_no)-180)
hold on
semilogx(wx,wind_direction2(:,ir_no_st:ir_no)-180)
ylabel('Wind direction []')
grid on
grid minor
axis([20 20000 0 360])

subplot(5,1,4);
semilogx(wx,temp(:,ir_no_st:ir_no))
ylabel('Temperature []')
grid on
grid minor
axis([20 20000 10 25])
 
subplot(5,1,5);
semilogx(wx,humidity(:,ir_no_st:ir_no))
ylabel('Humidity [%]')
grid on
grid minor
xlabel('Frequency [Hz]')
axis([20 20000 0 100])  

figure(1)
%semilogx(f_axis,center_refraction)

semilogx(f_axis,upwards_refraction)
hold on
semilogx(f_axis,downwards_refraction)
grid on
grid minor
axis([100 20000 20 100])
ylabel('Level [dB]')
xlabel('Frequency [Hz]')
legend({'upwards','downwards'},'Location','northeast')

%%

tim = [downsample(irtime(1:6000),150); downsample(irtime(6000+1:15000),2); downsample(irtime(15000+1:end),4000)];
sig = [downsample(ir_upwards(1:6000),150); downsample(ir_upwards(6000+1:15000),2); downsample(ir_upwards(15000+1:end),4000)];
sig_fi = [downsample(ir_upwards_fi(1:6000),150); downsample(ir_upwards_fi(6000+1:15000),2); downsample(ir_upwards_fi(15000+1:end),4000)];
win = [downsample(window(1:6000),150); downsample(window(6000+1:15000),2); downsample(window(15000+1:end),4000)];


plot(tim,win/300)
hold on

plot(tim,sig)

ylabel('Amplitude [Pa]')
xlabel('Time [s]')
legend({'Window','Impulse response'},'Location','northeast')
axis([0 0.6 -0.004 0.004])

%%

txt = ['windspeed: ' num2str(spe) ', winddirection: ' num2str(ret)];
text(100,40,txt)

figure(10)
semilogx(f_axis,downwards_refraction)
hold on
%semilogx(f_axis,movmean(result_u,50)-adju,'b')
%semilogx(f_axis,movmean(result_d,50),'r')
%semilogx(f_axis,movmean(result_c,50))
grid on
grid minor
axis([50 20000 20 90])
xlabel('Frequency [Hz]')
ylabel('Level [dB]')
%legend('downwards')
legend({'upwards','downwards'},'Location','southwest')

txt = ['windspeed: ' num2str(spe) ', winddirection: ' num2str(ret)];
text(100,40,txt)

figure(12)
semilogx(f_axis,center_refraction)
hold on
grid on
grid minor
axis([50 20000 20 90])
xlabel('Frequency [Hz]')
ylabel('Level [dB]')
legend({'center'},'Location','southwest')

txt = ['windspeed: ' num2str(spe) ', winddirection: ' num2str(ret)];
text(100,40,txt)



%%
clear 
[fs,calibration,frequencyRange,gain,inputChannel,sweepTime,a,b,cmd] = initial_data('transfer');

down1 = 1;
down2 = 2;
down3 = 20;
down4 = 50;

load('impulse_of_windscreen');

ref = data1calibrate0.ir_center;

mes = data1windscreen_without_foam_angle30.ir_center;


L = length(ref);

Y = fft(ref);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
tf_ref = P1;

Y = fft(mes);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
tf_mes = P1;

[tf_ref,w] = freqz(ref,1,frequencyRange(2),fs);
[tf_mes,w] = freqz(mes,1,frequencyRange(2),fs);


%f_axis = w;%(fs*(0:(L/2))/L)';

f_axis = [downsample(w(1:100),down1); downsample(w(100+1:1000),down2); downsample(w(1000+1:10000),down3); downsample(w(10000+1:end),down4)];

db_ref=20*log10(abs(tf_ref/(20*10^-6)))+10;
db_mes=20*log10(abs(tf_mes/(20*10^-6)))+10;

db_ref = [downsample(db_ref(1:100),down1); downsample(db_ref(100+1:1000),down2); downsample(db_ref(1000+1:10000),down3); downsample(db_ref(10000+1:end),down4)];
db_mes = [downsample(db_mes(1:100),down1); downsample(db_mes(100+1:1000),down2); downsample(db_mes(1000+1:10000),down3); downsample(db_mes(10000+1:end),down4)];

db_ref = movmean(db_ref,10);
db_mes = movmean(db_mes,10);

%result = db_mes;%-db_ref;

figure(2)
semilogx(f_axis,db_ref)
hold on
semilogx(f_axis,db_mes)
grid on
grid minor
axis([40 20000 50 90])
xlabel('Frequency [Hz]')
ylabel('SPL [dB]')
legend('With only original modified windscreen',' Designed windscreen')

%% Add test points 
clear
number = 0;
%%

 number = number+1; % run number
  
[fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data('transfer');
[ir_axis,ir(:,:,number),res] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
if res == 1
    [ir_axis,ir(:,:,number),res] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
end



%% Mean the test and show result

for i=1:number+1
r(:,i) = xcorr(ir(:,1),ir(:,i));
[M,inde1(i)] = max(r(:,i));
end

shif = inde1' - inde1(1)+1;

for i=1:number+1
ir_shift(:,i) = circshift(ir(:,i),shif(i));
end


%%



mean_of_all_run = mean(ir_shift,2);

figure(1)
plot(ir_shift)

[tf_mes,w] = freqz(mean_of_all_run,1,frequencyRange(2),fs);
db_mes=20*log10(abs(tf_mes/(20*10^-6)));



figure(2)
semilogx(w,db_mes)
hold on
grid on
grid minor
axis([20 20000 50 120])
xlabel('Frequency [Hz]')
ylabel('Level [dB]')


%% One Third octave analysis
ir_mean = ir_a;
p0 = 20*10^(-6);
BW = '1/3 octave'; 
N = 8;
F0 = 1000;
load('calibration.mat')
oneThirdOctaveFilter = octaveFilter('FilterOrder', N, ...
    'CenterFrequency', F0, 'Bandwidth', BW, 'SampleRate', fs);
F0 = getANSICenterFrequencies(oneThirdOctaveFilter);
F0(F0<16) = [];
F0(F0>20e3) = [];
Nfc = length(F0);

for i=1:Nfc
    oneThirdOctaveFilterBank{i} = octaveFilter('FilterOrder', N, ...
        'CenterFrequency', F0(i), 'Bandwidth', BW, 'SampleRate', fs);
end
clear oneThirdOctaveFilter

for i=1:Nfc
    oneThirdOctaveFilter = oneThirdOctaveFilterBank{i};
    yp(:,i) = oneThirdOctaveFilter(ir_mean*4500);
end
L_Aeqthird = 10*log10(1/(length(yp))*trapz(yp.^2/p0^2));
L_Aeq = L_Aeqthird+calibration.octave;
figure(4)
b = bar(L_Aeq);
bl = b.BaseLine;
c = bl.Color;
bl.BaseValue = 0;
axis([0 31 20 140])
grid on
grid minor
xlabel('Octave [no]')
ylabel('Level [dB]')


%% make reverb calculation
clear;
[fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data('transfer');
[ir_axis,ir] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
impulse=filter(b,a,ir(1:length(ir)/2));
BW = '1/3 octave'; 
N = 8;
F0 = 1000;
oneThirdOctaveFilter = octaveFilter('FilterOrder', N, ...
    'CenterFrequency', F0, 'Bandwidth', BW, 'SampleRate', fs);
F0 = getANSICenterFrequencies(oneThirdOctaveFilter);
F0(F0<16) = [];
F0(F0>20e3) = [];
Nfc = length(F0);

for i=1:Nfc
    oneThirdOctaveFilterBank{i} = octaveFilter('FilterOrder', N, ...
        'CenterFrequency', F0(i), 'Bandwidth', BW, 'SampleRate', fs);
end
figure(1)
plot(ir_axis(1:length(impulse)),impulse);
interval = 3000;
T_30 = zeros(length(inputChannel),Nfc);

for no = 1:length(inputChannel)
    sqrt_impulse = (impulse(:,no)).^2;
    mid = sqrt_impulse(end/2-interval:end/2+interval);
    noise_floor = rms(mid)*1.01;
    b = 1;

    for i=interval+1:interval:length(sqrt_impulse)
        part = sqrt_impulse(i-interval:i+interval);
        impulse_level = rms(part);
        b = b+1;
        if impulse_level <= noise_floor
            break
       end
    end
    N = fs;%(i-1);

    for i=1:Nfc
        output = oneThirdOctaveFilterBank{i}(impulse(:,no)); 
        t_reverb = (output(1:N)).^2;
        Q = flip(cumtrapz(flip(t_reverb)))';
        res = 10*log10(Q/max(Q));
        figure(3)
        plot(ir_axis(1:length(res)),res)
        hold on
        % T_20_sample = res(length(find(res >= -5)):length(res)-length(find(res <= -25)));
        % T_20_time   = t_axis(length(find(res >= -5)):length(res)-length(find(res <= -25)));
        % p           = polyfit(T_20_time,T_20_sample,1);
        % result      = polyval(p,t_axis(1:length(res)-length(find(res <= -25))));
        % T_20_ls     = length(t_axis(length(find(result >= -10)):length(result)-length(find(result <= -20))))*6;
        % T_20(no,i)  = round(T_20_ls/fs,2);
        T_30_sample = res(length(find(res >= -5)):length(res)-length(find(res <= -35)));
        T_30_time   = ir_axis(length(find(res >= -5)):length(res)-length(find(res <= -35)));
        p           = polyfit(T_30_time,T_30_sample,1);
        result      = polyval(p,ir_axis(1:length(res)-length(find(res <= -35))));
        T_30_ls     = length(ir_axis(length(find(result >= -10)):length(result)-length(find(result <= -20))))*6;
        T_30(no,i)  = round(T_30_ls/fs,2);
    end
    xlabel('Time [s]')
    ylabel('Relative Level [dB]')
    set(gca,'Ytick',-150:10:0)
    %lgd = legend('100 Hz','125 Hz','160 Hz','200 Hz','250 Hz', ...
    %'315 Hz','400 Hz','500 Hz','630 Hz','800 Hz','1000 Hz','1250 Hz', ...
    %'1600 Hz','2000 Hz','2500 Hz','3150 Hz','4000 Hz','5000 Hz');
    %title(lgd,'A3-006');
    set(gca,'fontsize',14)
    grid on
    grid minor
end