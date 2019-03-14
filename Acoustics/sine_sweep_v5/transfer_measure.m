%% make calibration file
clear;
calibration = struct;            
calibration.date=date;            
save('calibration.mat','calibration');


%% Check impulse response offset
% rme= 3159 edirol=3295 firefly=3360
clear;
offset = -3159;
save('offset.mat','offset');
[fs,~,frequencyRange,gain,inputChannel,offset,sweepTime,~,~,cmd] = initial_data('test');
[t_axis,t_result] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
plot(t_result)


%% Calibrate the soundcard
clear;
[fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data('cali_soundcard');
Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
%% Show calibration of soundcard
cmd = 'test';
load('calibration.mat')
[~,ir] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
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


%% Calibrate the microphone
clear;
[fs,~,frequencyRange,gain,inputChannel,offset,sweepTime,~,~,cmd] = initial_data('cali_mic');
Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);


%% Show calibration of microphone
clear;
[fs,calibration,~,~,~,~,~,~,~,~] = initial_data('cali_mic');
p0 = 20*10^(-6);
blength = 3;
soundcard = audioDeviceReader('SampleRate',fs,'SamplesPerFrame',2048);          % setting up audio object
buffer = zeros(blength * fs, 1);            % initializing audio buffer
tic;

while toc < 10
    audioin = soundcard()/calibration.mic_sensitivity;                  % fetch samples from soundcard
    buffer = [buffer(2049:end); audioin];   % update buffer
end
out = 20*log10(rms(buffer)/p0);


%% calibrate One Third octave analysis 
clear;
[fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data('transfer');
[~,ir] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
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


%% Make impulse response
clear;
for i=1:10
    i
[fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data('transfer');
[ir_axis,ir(:,:,i),res] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
if res == 1
    [ir_axis,ir(:,:,i),res] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
end
end
%%
load('highpass_to_ir.mat');
[b,a]=sos2tf(SOS,G);
for i=1:10
ir(:,1,i)=filter(b,a,ir(:,1,i));
end

for i=1:10
ir(:,2,i)=filter(b,a,ir(:,2,i));
end

[fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data('transfer');

for i=1:10
    r(:,i) = xcorr(ir(:,1,1),ir(:,1,i));
    [M,inde1(i)] = max(r(:,i));
end

for i=1:10
    r(:,i) = xcorr(ir(:,2,1),ir(:,2,i));
    [M,inde2(i)] = max(r(:,i));
end

for i=1:10
    shif1(i) = inde1(i) - inde1(1);
    shif2(i) = inde2(i) - inde2(1);
end

for i=1:10
    ir_shift(:,1,i) = circshift(ir(:,1,i),shif1(i));
    ir_shift(:,2,i) = circshift(ir(:,2,i),shif2(i));
end

for i=1:10
    r(:,i) = xcorr(ir_shift(:,1,1),ir_shift(:,1,i));
    [M,inde1_ch(i)] = max(r(:,i));
end

for i=1:10
    r(:,i) = xcorr(ir_shift(:,2,1),ir_shift(:,2,i));
    [M,inde2_ch(i)] = max(r(:,i));
end

for i=1:10
    shif1_ch(i) = inde1_ch(i) - inde1_ch(1);
    shif2_ch(i) = inde2_ch(i) - inde2_ch(1);
end


figure(1)
for i=1:10
p1 = plot(squeeze(ir_shift(:,2,i)))
p1.Color(4) = 0.25;
hold on
end
ir_a = mean(ir_shift(:,:,:),3);
plot(ir_a(:,2))

for k=1:length(inputChannel)
ir_result=ir_a(1:end/2,k);      %filter(b,a,ir_a(1:3750+fs/100,k));%length(ir_a(:,k)/2),k));
[tf,w] = freqz(ir_result,1,frequencyRange(2),fs);
f_result = tf./calibration.preamp_transfer_function;

f_axis = w;
result=20*log10(abs(f_result/(20*10^-6)));
%number = 1;
result_mean(:,k) = movmean(result,40);
result_mean_d(:,k) = downsample(result_mean(:,k),10);
end
f_axis = downsample(f_axis,10);
%impulse(:,number) = ir_result;
%figure(1)
%plot(ir_axis(1:length(ir_result)),ir_result)
figure(2)
%semilogx(f_axis(21:end),result(21:end))
semilogx(f_axis(21:end),result_mean_d(21:end,1))
hold on
semilogx(f_axis(21:end),result_mean_d(21:end,2))
grid on
grid minor
axis([300 20000 20 120])
xlabel('Frequency [Hz]')
ylabel('Level [dB]')
legend('mic1','mic2')

%% Add more test points 
% number = number+1; % run number
% [~,ir] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
% ir_result=filter(b,a,ir(1:length(ir)/2));
% [tf,w] = freqz(ir_result,1,frequencyRange(2),fs);
% f_result = tf./calibration.preamp_transfer_function;
% f_axis = w;
% result=20*log10(abs(f_result)/(20*10^-6));
% result_mean(:,number) = movmean(result(21:end),100);
% figure(2)
% semilogx(f_axis(21:end),result_mean(:,number))
% impulse(:,number) = ir_result;


%% Mean the test and show result
mean_of_all_run = mean(result_mean,2);
figure(3)
semilogx(f_axis(1:length(mean_of_all_run)),mean_of_all_run)
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