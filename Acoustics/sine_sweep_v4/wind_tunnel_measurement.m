close;
clear;

if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

port = seriallist;
s = serial(port(5));
s=serial(port(5),'InputBufferSize',512,'Baudrate',115200); 
%s.ReadAsyncMode = 'manual';
%s.Terminator = 'LF';
out = [];

mic = 0.03;


% measure

            L = 2048;
            fileReader = dsp.AudioFileReader('sweep.wav','SamplesPerFrame',L);
            fs = fileReader.SampleRate;

            
            aPR = audioPlayerRecorder('SampleRate',fs,...               % Sampling Freq.
                          'RecorderChannelMapping',[1 2],...  % Input channel(s)
                          'PlayerChannelMapping',[1 2],... % Output channel(s)
                          'SupportVariableSize',true,...    % Enable variable buffer size 
                          'BufferSize',L);                  % Set buffer size
    
                      
                      out = [];                         
                      data = [];
                      fopen(s)

                      while ~isDone(fileReader)
                          audioToPlay = fileReader();
                          
                          [audioRecorded,nUnderruns,nOverruns] = aPR(audioToPlay);
                          out = [out; audioRecorded];
                          
                          dat=strsplit(fscanf(s),'\t'); 
                          data = [data; dat];
                          
                          if nUnderruns > 0
                              fprintf('Audio player queue was underrun by %d samples.\n',nUnderruns);                                
                                res = 1;
                          end
                          if nOverruns > 0
                              fprintf('Audio recorder queue was overrun by %d samples.\n',nOverruns);
                                res = 1;
                          end
                      end
                      release(fileReader);
                      release(aPR);


  fclose(s)  

                      
interp = floor(length(out)/length(dat));
weather = kron(str2double(data), ones(interp,1));


while(1)
    weather = [weather; weather(end,:)];
    if length(weather)>=length(out)
        break
    end
end

wind_speed = (weather(:,1)*(2.25/1))*0.44704;
wind_direction = weather(:,2)/1024*359;
temp = weather(:,3);
humidity = weather(:,4);

                      


wind_speed_m = movmean(wind_speed,6000);
wind_direction_m = movmean(wind_direction,1);
temp_m = movmean(temp,1);
humidity_m = movmean(humidity,1);
spl = fliplr(out);%10*log10(((((out/mic).^2)))/(20*10^-6).^2);
x = [1:length(out)]./fs;

meas_fs = length(weather)/x(end)
%x_m = [1:length(weather)]./meas_fs;

figure(1)
plot(x,spl)
title('Audio')
grid on


figure(2)
subplot(5,1,1);
plot(x,spl)
title('Audio')
grid on
axis([0 8 -5 5])

subplot(5,1,2);
plot(x,wind_speed_m)
title('Wind speed')
grid on
axis([0 8 0 15])

subplot(5,1,3);
plot(x,wind_direction_m)
title('Wind direction')
grid on
axis([0 8 0 360])

subplot(5,1,4);
plot(x,temp_m)
title('Temperature')
grid on
axis([0 8 0 30])

subplot(5,1,5);
plot(x,humidity_m)
title('Humidity')
grid on
axis([0 8 0 100])


data(:,1) = spl(:,1);
data(:,2) = spl(:,2);
data(:,3) = wind_speed_m;
data(:,4) = wind_direction_m;
data(:,5) = temp_m;
data(:,6) = humidity_m;


%%
fs = 44100;


load('ingen_vind.mat')
[tf1u,w] = freqz((data(:,1)/0.131931494139380)/length(data),1,20000,fs);
[tf1m,w] = freqz((data(:,2)/0.131931494139380)/length(data),1,20000,fs);

load('ingen_vind_2.mat')
[tf2u,w] = freqz((data(:,1)/0.131931494139380)/length(data),1,20000,fs);
[tf2m,w] = freqz((data(:,2)/0.131931494139380)/length(data),1,20000,fs);

load('ingen_vind_3.mat')
[tf3u,w] = freqz((data(:,1)/0.131931494139380)/length(data),1,20000,fs);
[tf3m,w] = freqz((data(:,2)/0.131931494139380)/length(data),1,20000,fs);


%out_ref = (tf1m+tf2m+tf3m)/3;
%db_ref = 20*log10(abs(out_ref/(20*10^-6)));
%db_mref = [db_ref(1:100); movmean(downsample(db_ref(100+1:1000),2),3); movmean(downsample(db_ref(1000+1:10000),15),2); movmean(downsample(db_ref(10000+1:end),30),2)];

out_ref = (tf1u+tf2u+tf3u)/3;
db_ref = 20*log10(abs(out_ref/(20*10^-6)));
db_uref = [db_ref(1:100); movmean(downsample(db_ref(100+1:1000),2),3); movmean(downsample(db_ref(1000+1:10000),15),2); movmean(downsample(db_ref(10000+1:end),30),2)];



load('stor_kile_vs_ingen.mat')
[tf1u,w] = freqz((data(:,1)/0.131931494139380)/length(data),1,20000,fs);
[tf1m,w] = freqz((data(:,2)/0.131931494139380)/length(data),1,20000,fs);

load('stor_kile_vs_ingen_2.mat')
[tf2u,w] = freqz((data(:,1)/0.131931494139380)/length(data),1,20000,fs);
[tf2m,w] = freqz((data(:,2)/0.131931494139380)/length(data),1,20000,fs);

load('stor_kile_vs_ingen_3.mat')
[tf3u,w] = freqz((data(:,1)/0.131931494139380)/length(data),1,20000,fs);
[tf3m,w] = freqz((data(:,2)/0.131931494139380)/length(data),1,20000,fs);

out_u = (tf1u+tf2u+tf3u)/3;
out_m = (tf1m+tf2m+tf3m)/3;

db_u = 20*log10(abs(out_u/(20*10^-6)));
db_m = 20*log10(abs(out_m/(20*10^-6)));
%db = db_u-db_m;
%db = movmean(db,5);

db_mm = [db_m(1:100); movmean(downsample(db_m(100+1:1000),2),3); movmean(downsample(db_m(1000+1:10000),15),2); movmean(downsample(db_m(10000+1:end),30),2)];
db_um = [db_u(1:100); movmean(downsample(db_u(100+1:1000),2),3); movmean(downsample(db_u(1000+1:10000),15),2); movmean(downsample(db_u(10000+1:end),30),2)];
w =  [w(1:100);  downsample(w(100+1:1000),2); downsample(w(1000+1:10000),15);  downsample(w(10000+1:end),30)];
semilogx(w,db_uref)

hold on
semilogx(w,db_mm)
%semilogx(w,)
grid on
axis([ 2 20000 -60 60])
xlabel('Frequency [Hz]')
ylabel('SPL [dB]')
yticks(-50:10:80);
legend('Without wind','With wind and windscreen, conf 2')

%%

down1 = 2;
down2 = 15;
down3 = 70;
down4 = 160;

load('ingen_vind.mat')
Fs = 44100;
L = length(data);

X = data(:,1)/0.131931494139380;
Y = fft(X);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
tf1u = P1;

X = data(:,2)/0.131931494139380;
Y = fft(X);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
tf1m = P1;


load('ingen_vind_2.mat')

X = data(:,1)/0.131931494139380;
Y = fft(X);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
tf2u = P1;

X = data(:,2)/0.131931494139380;
Y = fft(X);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
tf2m = P1;

load('ingen_vind_3.mat')

X = data(:,1)/0.131931494139380;
Y = fft(X);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
tf3u = P1;

X = data(:,2)/0.131931494139380;
Y = fft(X);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
tf3m = P1;

%out_ref = (tf1m+tf2m+tf3m)/3;
%db_ref = 20*log10(abs(out_ref/(20*10^-6)));
%db_mref = [db_ref(1:100); movmean(downsample(db_ref(100+1:1000),2),3); movmean(downsample(db_ref(1000+1:10000),15),2); movmean(downsample(db_ref(10000+1:end),30),2)];

out_ref = (tf1u+tf2u+tf3u)/3;
db_ref = 20*log10(abs(out_ref/(20*10^-6)));
db_uref = [downsample(db_ref(1:716),down1); downsample(db_ref(716+1:7153),down2); downsample(db_ref(7153+1:71536),down3); downsample(db_ref(71536+1:end),down4)];



load('rock_kile_vs_ingen.mat')

X = data(:,1)/0.131931494139380;
Y = fft(X);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
tf1u = P1;

X = data(:,2)/0.131931494139380;
Y = fft(X);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
tf1m = P1;

load('rock_kile_vs_ingen_2.mat')

X = data(:,1)/0.131931494139380;
Y = fft(X);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
tf2u = P1;

X = data(:,2)/0.131931494139380;
Y = fft(X);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
tf2m = P1;

load('rock_kile_vs_ingen_3.mat')

X = data(:,1)/0.131931494139380;
Y = fft(X);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
tf3u = P1;

X = data(:,2)/0.131931494139380;
Y = fft(X);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
tf3m = P1;

f = (Fs*(0:(L/2))/L)';

out_u = (tf1u+tf2u+tf3u)/3;
out_m = (tf1m+tf2m+tf3m)/3;

db_u = 20*log10(abs(out_u/(20*10^-6)));
db_m = 20*log10(abs(out_m/(20*10^-6)));
%db = db_u-db_m;
%db = movmean(db,5);

db_mm = [downsample(db_m(1:716),down1); downsample(db_m(716+1:7153),down2); downsample(db_m(7153+1:71536),down3); downsample(db_m(71536+1:end),down4)];
db_um = [downsample(db_u(1:716),down1); downsample(db_u(716+1:7153),down2); downsample(db_u(7153+1:71536),down3); downsample(db_u(71536+1:end),down4)];

f =  [downsample(f(1:716),down1);  downsample(f(716+1:7153),down2); downsample(f(7153+1:71536),down3);  downsample(f(71536+1:end),down4)];
semilogx(f,db_uref)

hold on
semilogx(f,db_mm)
%semilogx(w,)
grid on
axis([ 2 20000 -40 70])
xlabel('Frequency [Hz]')
ylabel('SPL [dB]')
yticks(-50:10:90);
legend('Without wind','With wind and windscreen, conf 3')


%%
clear
load('ingen_vind.mat')
fs = 44100;
[tf1u,w] = freqz((data(:,1)/0.131931494139380)/length(data),1,20000,fs);

Fs = 44100;
L = length(data);
X = data(:,1)/0.131931494139380;
Y = fft(X);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
semilogx(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
hold on 
semilogx(w,abs(tf1u))
%%
load('ingen_vind.mat')

x = downsample([1:length(data)]./44100,100);

figure(1)

p1 = plot(x,downsample(data(:,1),100)/0.131931494139380)
p1.Color(4) = 0.45;
hold on

plot(x,downsample(data(:,2),100)/0.131931494139380)

xlabel('Time [s]')
ylabel('pressure [pa]')
grid on
axis([ 0 x(end) -0.2 0.2])


%% close
fclose(s)
delete(s)
clear s
