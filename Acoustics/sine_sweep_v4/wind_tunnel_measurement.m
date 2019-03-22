close;
clear;

if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

port = seriallist;
s = serial(port(5));
s.baudrate = 115200;
out = [];
fopen(s)
%fprintf(s,'*IDN?')

mic = 0.03;


%% measure

            L = 2048;
            fileReader = dsp.AudioFileReader('sweep.wav','SamplesPerFrame',L);
            fs = fileReader.SampleRate;
           
            aPR = audioPlayerRecorder('SampleRate',fs,...               % Sampling Freq.
                          'RecorderChannelMapping',[1 2],...  % Input channel(s)
                          'PlayerChannelMapping',1,... % Output channel(s)
                          'SupportVariableSize',true,...    % Enable variable buffer size 
                          'BufferSize',L);                  % Set buffer size
    
                      
                      out = [];    
                      
                      dat = [];
                      while ~isDone(fileReader)
                          audioToPlay = fileReader();
                          [audioRecorded,nUnderruns,nOverruns] = aPR(audioToPlay);
                          out = [out; audioRecorded];
                            t = strsplit(fscanf(s),'\t');
                            dat = [dat; t];
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

                      

weather = str2double(dat);
wind_speed = kron(weather(:,1), ones(L,1));
wind_direction = kron(weather(:,2), ones(L,1));
temp = kron(weather(:,3), ones(L,1));
humidity = kron(weather(:,4), ones(L,1));

                      
%%

wind_speed_m = movmean(wind_speed,4000);
wind_direction_m = movmean(wind_direction,4000);
temp_m = movmean(temp,4000);
humidity_m = movmean(humidity,4000);
spl = fliplr(out);%10*log10(((((out/mic).^2)))/(20*10^-6).^2);
x = [1:length(out)]./fs;

figure(1)
plot(x,spl)
title('Audio')
grid on


figure(2)
subplot(5,1,1);
plot(x,spl)
title('Audio')
grid on

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
load('ingen_kile_vs_ingen.mat')
[tf1u,w] = freqz((data(:,1)/0.131931494139380)/length(data),1,20000,fs);
[tf1m,w] = freqz((data(:,2)/0.131931494139380)/length(data),1,20000,fs);

load('ingen_kile_vs_ingen_2.mat')
[tf2u,w] = freqz((data(:,1)/0.131931494139380)/length(data),1,20000,fs);
[tf2m,w] = freqz((data(:,2)/0.131931494139380)/length(data),1,20000,fs);

load('ingen_kile_vs_ingen_3.mat')
[tf3u,w] = freqz((data(:,1)/0.131931494139380)/length(data),1,20000,fs);
[tf3m,w] = freqz((data(:,2)/0.131931494139380)/length(data),1,20000,fs);

out_u = (tf1u+tf2u+tf3u)/3;
out_m = (tf1m+tf2m+tf3m)/3;

db_u = 20*log10(abs(out_u/(20*10^-6)));
db_m = 20*log10(abs(out_m/(20*10^-6)));
db = db_m;%-db_m;
%db = movmean(db,5);
db = [db(1:100); movmean(downsample(db(100+1:1000),2),3); movmean(downsample(db(1000+1:10000),15),2); movmean(downsample(db(10000+1:end),30),2)];
w =  [w(1:100);  movmean(downsample(w(100+1:1000),2),3); movmean(downsample(w(1000+1:10000),15),2);  movmean(downsample(w(10000+1:end),30),2)];
semilogx(w,db)

hold on
grid on
axis([ 0 20000 -40 80])
xlabel('Frequency [Hz]')
ylabel('SPL [dB]')

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
