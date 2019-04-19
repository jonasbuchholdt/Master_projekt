%% make calibration file
clear;
calibration = struct;            
calibration.date=date;            
save('calibration.mat','calibration');



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
tim = 1;
for i=1:tim
    i
[fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data('transfer');
[ir_axis,ir(:,:,i),res] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
if res == 1
    [ir_axis,ir(:,:,i),res] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs);
end
end


load('highPass20.mat');
        [b,a]=sos2tf(SOS,G);
        ir=filter(b,a,ir);
        figure(1)
plot(ir(:,1))


ir_result=ir(1:end/2);     

[tf,w] = freqz(ir_result,1,frequencyRange(2),fs);
f_axis = w;
result=20*log10(abs(tf/(20*10^-6)));


figure(2)
semilogx(f_axis,result)
hold on
grid on
grid minor
axis([50 20000 55 85])
xlabel('Frequency [Hz]')
ylabel('Level [dB]')
legend('mic1')


%%
clear 
[fs,calibration,frequencyRange,gain,inputChannel,offset,sweepTime,a,b,cmd] = initial_data('transfer');

down1 = 1;
down2 = 2;
down3 = 20;
down4 = 50;

load('mic_ref_without_ball.mat','ir_result');
ref = ir_result;
load('mic_ref_with_ball_large_rock_single','ir_result');
mes = ir_result;

clear ir_result;

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



db_ref=20*log10(abs(tf_ref/(20*10^-6)));
db_mes=20*log10(abs(tf_mes/(20*10^-6)));



db_ref = [downsample(db_ref(1:100),down1); downsample(db_ref(100+1:1000),down2); downsample(db_ref(1000+1:10000),down3); downsample(db_ref(10000+1:end),down4)];
db_mes = [downsample(db_mes(1:100),down1); downsample(db_mes(100+1:1000),down2); downsample(db_mes(1000+1:10000),down3); downsample(db_mes(10000+1:end),down4)];

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
legend('Without windscreen','Windscreen, conf 4')

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