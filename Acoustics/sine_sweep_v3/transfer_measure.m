%% make calibration file
clear all
calibration = struct;            
calibration.date=date;            
save('calibration.mat','calibration');

%% Check impulse response offset
% rme= 3159 edirol=3295
clear all
offset = -3159;
save('offset.mat','offset');
[fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data('test');
[t_axis,t_result] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
plot(t_result)


%% Calibrate the soundcard
clear all
[fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data('cali_soundcard');
Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);

%% Show calibration of soundcard
clear all
[fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data('test');
[ir_axis,ir] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
ir_result=filter(b,a,ir(1:length(ir)/2));
[tf,w] = freqz(ir_result,1,frequencyRange(2),fs);
f_result = tf./calibration.preamp_transfer_function;
result = 20*log10(abs(f_result));
semilogx(w,result)
hold on
grid on
axis([20 20000 -1 1])
xlabel('Frequency [Hz]')
ylabel('[dB]')
clear calibration

%% Calibrate the microphone
clear all
[fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data('cali_mic');
Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);

%% Show calibration of microphone
clear all
[fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data('cali_mic');
p0 = 20*10^(-6);
blength = 3;
soundcard = audioDeviceReader('SampleRate',fs,'SamplesPerFrame',2048);          % setting up audio object
buffer = zeros(blength * fs, 1);            % initializing audio buffer
tic;
while toc < 10
    audioin = soundcard()/calibration.mic_sensitivity;                  % fetch samples from soundcard
    buffer = [buffer(2049:end); audioin];   % update buffer
end
out = 20*log10(rms(buffer)*sqrt(2)/p0)


%% Make impulse response in first point 
clear all
[fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data('transfer');
[ir_axis,ir_result] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
irEstimate_distortion_free = ir_result(1:length(ir_result)/2);
ir=filter(b,a,irEstimate_distortion_free);
[tf,w] = freqz(ir,1,frequencyRange(2),fs);
f_result = tf./calibration.preamp_transfer_function;
f_axis = w;
result=20*log10(abs(f_result/(20*10^-6)));
number = 1;
result_mean(:,number) = movmean(result(21:end),100);
impulse(:,number) = filter(b,a,ir_result);

figure(1)
%semilogx(f_axis(21:end),result(21:end))
semilogx(f_axis(21:end),result_mean(:,number))
hold on
grid on
grid minor
axis([20 20000 20 140])
xlabel('Frequency [Hz]')
ylabel('Level [dB]')

figure(2)
plot(ir_axis,ir_result)


%% Add more test points 
number = number+1; % run number
[ir_axis,ir_result] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);

irEstimate_distortion_free = ir_result(1:length(ir_result)/2);
ir=filter(b,a,irEstimate_distortion_free);
[tf,w] = freqz(ir,1,frequencyRange(2),fs);
f_result = tf./calibration.preamp_transfer_function;
f_axis = w;
result=20*log10(abs(f_result)/(20*10^-6));
result_mean(:,number) = movmean(result(21:end),100);
figure(1)
semilogx(f_axis(21:end),result_mean(:,number))

impulse(:,number) = filter(b,a,ir_result);



%% One Third octave analysis

ir_mean = mean(impulse,2);

p0 = 20*10^(-6);
BW = '1/3 octave'; 
N = 8;
F0 = 1000;
load('octave_offset.mat')

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


% for i = 1:length(L_Aeqthird)-1
%      off(i) = L_Aeqthird(30) - L_Aeqthird(i);
% end
% off(30) = 0;

L_Aeq = L_Aeqthird+off;
figure(3)
b = bar(L_Aeq);
bl = b.BaseLine;
c = bl.Color;
bl.BaseValue = 0;
axis([0 31 20 140])
grid on
grid minor
xlabel('Octave [no]')
ylabel('Level [dB]')

%% save impulses

save('reverb_impulses_absorption_without_sp3.mat','impulse');

%% Mean the test and show result

mean_of_all_run = mean(result_mean,2);
figure(2)
semilogx(f_axis,mean_of_all_run)
hold on
grid on
axis([20 20000 40 120])
xlabel('Frequency [Hz]')
ylabel('Level [dB]')


%% make reverb calculation
clear all
fs = 44100;
BW = '1/3 octave'; 
N = 8;
F0 = 1000;

oneThirdOctaveFilter = octaveFilter('FilterOrder', N, ...
    'CenterFrequency', F0, 'Bandwidth', BW, 'SampleRate', fs);
F0 = getANSICenterFrequencies(oneThirdOctaveFilter);
F0(F0<99) = [];
F0(F0>5050) = [];
Nfc = length(F0);
for i=1:Nfc
    oneThirdOctaveFilterBank{i} = octaveFilter('FilterOrder', N, ...
        'CenterFrequency', F0(i), 'Bandwidth', BW, 'SampleRate', fs);
end

load('reverb_impulses_absorption_without_sp1.mat');
load('t_axis.mat')
figure(1)
plot(impulse);

load('highPass20.mat');
[b,a]=sos2tf(SOS,G);
impulse=filter(b,a,impulse);
figure(2)
plot(impulse);

interval = 3000;


for no = 1:1
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


N = (i-1);




for i=1:Nfc

output = oneThirdOctaveFilterBank{i}(impulse(:,no)); 

t_reverb = (output(1:N)).^2;

% for t=1:1:length(t_reverb)
% %Q(t) = trapz(t_reverb(t:end));
% %Q(t) = sum(t_reverb(t:end));
% end

Q = flip(cumtrapz(flip(t_reverb)))';

res = 10*log10(Q/max(Q));
figure(3)
plot(t_axis(1:length(res)),res)
hold on
no

% T_20_sample = res(length(find(res >= -5)):length(res)-length(find(res <= -25)));
% T_20_time   = t_axis(length(find(res >= -5)):length(res)-length(find(res <= -25)));
% p           = polyfit(T_20_time,T_20_sample,1);
% result      = polyval(p,t_axis(1:length(res)-length(find(res <= -25))));
% T_20_ls     = length(t_axis(length(find(result >= -10)):length(result)-length(find(result <= -20))))*6;
% T_20(no,i)  = round(T_20_ls/fs,2);

T_30_sample = res(length(find(res >= -5)):length(res)-length(find(res <= -35)));
T_30_time   = t_axis(length(find(res >= -5)):length(res)-length(find(res <= -35)));
p           = polyfit(T_30_time,T_30_sample,1);
result      = polyval(p,t_axis(1:length(res)-length(find(res <= -35))));
T_30_ls     = length(t_axis(length(find(result >= -10)):length(result)-length(find(result <= -20))))*6;
T_30(no,i)  = round(T_30_ls/fs,2);





end
 xlabel('Time [s]')
 ylabel('Relative Level [dB]')
 set(gca,'Ytick',-150:10:0)
 
 lgd = legend('100 Hz','125 Hz','160 Hz','200 Hz','250 Hz','315 Hz','400 Hz','500 Hz','630 Hz','800 Hz','1000 Hz','1250 Hz','1600 Hz','2000 Hz','2500 Hz','3150 Hz','4000 Hz','5000 Hz');
 title(lgd,'A3-006');
 set(gca,'fontsize',14)
 
 grid on
 grid minor
end