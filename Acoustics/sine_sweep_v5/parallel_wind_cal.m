%%
clear 
warning off
load('impulses_2.mat');
[fs,calibration,frequencyRange,gain,inputChannel,sweepTime,a,b,cmd] = initial_data('transfer');

c=0;
%%
c = c+1;
down1 = 1;
down2 = 1;
down3 = 20;
down4 = 50;

angle = 90;
ir_number = 10;
l_eq_no   = c;

% n5 - 3

ir_num = 10;

ir_no = ir_number;
ir_no_st = ir_number;


clear ir_downwards
clear ir_upwards
clear l_eq_center
clear l_eq_downwards
clear l_eq_upwards
start=1;


for i=start:1:ir_num
number = i;
ir_downwards_pre(:,i) = eval(strcat('data',int2str(number),'tile_n5_angle',int2str(angle),'.ir_downwards'));
ir_center_pre(:,i) = eval(strcat('data',int2str(number),'tile_n5_angle',int2str(angle),'.ir_center'));
ir_upwards_pre(:,i) = eval(strcat('data',int2str(number),'tile_n5_angle',int2str(angle),'.ir_upwards'));

wind_speed1(:,i) = eval(strcat('data',int2str(number),'tile_n5_angle',int2str(angle),'.wind_speed1'));
wind_speed2(:,i) = eval(strcat('data',int2str(number),'tile_n5_angle',int2str(angle),'.wind_speed2'));
wind_direction1(:,i) = eval(strcat('data',int2str(number),'tile_n5_angle',int2str(angle),'.wind_direction1'));
wind_direction2(:,i) = eval(strcat('data',int2str(number),'tile_n5_angle',int2str(angle),'.wind_direction2'));
temp(:,i) = eval(strcat('data',int2str(number),'tile_n5_angle',int2str(angle),'.temp'));
humidity(:,i) = eval(strcat('data',int2str(number),'tile_n5_angle',int2str(angle),'.humidity'));
end

irtime = eval(strcat('data',int2str(number),'tile_n5_angle',int2str(angle),'.irtime'));
weathertime = eval(strcat('data',int2str(number),'tile_n5_angle',int2str(angle),'.weathertime'));


ir_downwards_no = (ir_downwards_pre(1:20000,ir_no_st:ir_no)*10^(10/20)); %*10^(5/20)
ir_center_no = (ir_center_pre(1:20000,ir_no_st:ir_no)*10^(10/20));
ir_upwards_no = (ir_upwards_pre(1:20000,ir_no_st:ir_no)*10^(10/20)); 



% window first
L = numel(ir_upwards_no);
mu_low = 5000-1350;
mu_high = 13000-1350;
sigma = 600;
x = [1:1:L];
wdummy = ones(L,1)';
window_low  = cdf('Normal',x,mu_low,sigma);
window_high  = wdummy - cdf('Normal',x,mu_high,sigma);
window_first = (window_low .* window_high)';

% window center
L = numel(ir_upwards_no);
mu_low = 5000;
mu_high = 13000;
sigma = 600;
x = [1:1:L];
wdummy = ones(L,1)';
window_low  = cdf('Normal',x,mu_low,sigma);
window_high  = wdummy - cdf('Normal',x,mu_high,sigma);
window_center = (window_low .* window_high)';

% window back
L = numel(ir_upwards_no);
mu_low = 5000+1350;
mu_high = 13000+1350;
sigma = 600;
x = [1:1:L];
wdummy = ones(L,1)';
window_low  = cdf('Normal',x,mu_low,sigma);
window_high  = wdummy - cdf('Normal',x,mu_high,sigma);
window_back = (window_low .* window_high)';


% filter at 40 Hz and window
load('40Hz_2order_filter.mat');
[b,a]=sos2tf(SOS,G);
ir_downwards_fi=filter(b,a,ir_downwards_no);
ir_downwards_win = ir_downwards_fi.*window_first;
ir_center_fi=filter(b,a,ir_center_no);
ir_center_win = ir_center_fi.*window_center;
ir_upwards_fi=filter(b,a,ir_upwards_no);
ir_upwards_win = ir_upwards_fi.*window_back;

% filter at 150 Hz
load('150Hz_2order_filter.mat');
[b,a]=sos2tf(SOS,G);
%ir_downwards_vis=filter(b,a,ir_downwards_win);
%ir_center_vis=filter(b,a,ir_center_win);
%ir_upwards_vis=filter(b,a,ir_upwards_win);

ir_downwards_vis=ir_downwards_win;
ir_center_vis=ir_center_win;
ir_upwards_vis=ir_upwards_win;


% weather
windspeed = mean([wind_speed1(:,ir_no_st:ir_no); wind_speed2(:,ir_no_st:ir_no)])
windsdirection = mean([wind_direction1(:,ir_no_st:ir_no); wind_direction2(:,ir_no_st:ir_no)])-180-90
temp_mes = mean(temp(:,ir_no_st:ir_no));
humidity_mes = mean(humidity(:,ir_no_st:ir_no));


% viscosity filter downwards ----
input = ir_downwards_vis;
humidity_vis = humidity_mes;
temperature = temp_mes;
Fs = 44100;
L = length(input);
input_f = fft(input);
pa = 101.325;
pr = 101.325;
T_0 = 293.15;
T_01 = 273.16;
T = 273.15 + temperature;
h=humidity_vis*10^(-6.8346*(T_01/T)^(1.261)+4.6151);
f = (Fs*(0:(L/2))/L)';
fro = (pa/pr)*(24+4.04*10^4*h*((0.02+h)/(0.391+h)));
frn = (pa/pr)*(T/T_0)^(-1/2)*(9+280*h*exp(-4.170*((T/T_0)^(-1/3)-1)));
a = 8.686.*f.^2.*((1.84*10.^(-11).*(pa/pr).^(-1).*(T/T_0).^(1/2))+(T/T_0).^(-5/2).*(0.01275.*(exp(-2239.1/T)).*(fro+(f.^2/fro)).^(-1)+0.1068.*(exp(-3352/T)).*(frn+(f.^2/frn)).^(-1)));
an = -a*10;
absorbtion = [10.^(an(2:end)/20); flip(10.^(an(2:end)/20))];
freq = (input_f.*absorbtion);
ir_downwards_dis = real(ifft(freq));
% ---------

% viscosity filter center ----
input = ir_center_vis;
humidity_vis = humidity_mes;
temperature = temp_mes;
Fs = 44100;
L = length(input);
input_f = fft(input);
pa = 101.325;
pr = 101.325;
T_0 = 293.15;
T_01 = 273.16;
T = 273.15 + temperature;
h=humidity_vis*10^(-6.8346*(T_01/T)^(1.261)+4.6151);
f = (Fs*(0:(L/2))/L)';
fro = (pa/pr)*(24+4.04*10^4*h*((0.02+h)/(0.391+h)));
frn = (pa/pr)*(T/T_0)^(-1/2)*(9+280*h*exp(-4.170*((T/T_0)^(-1/3)-1)));
a = 8.686.*f.^2.*((1.84*10.^(-11).*(pa/pr).^(-1).*(T/T_0).^(1/2))+(T/T_0).^(-5/2).*(0.01275.*(exp(-2239.1/T)).*(fro+(f.^2/fro)).^(-1)+0.1068.*(exp(-3352/T)).*(frn+(f.^2/frn)).^(-1)));
an = -a*10;
absorbtion = [10.^(an(2:end)/20); flip(10.^(an(2:end)/20))];
freq = (input_f);
ir_center = real(ifft(freq));
% ---------


% viscosity filter upwards ----
input = ir_upwards_vis;
humidity_vis = humidity_mes;
temperature = temp_mes;
Fs = 44100;
L = length(input);
input_f = fft(input);
pa = 101.325;
pr = 101.325;
T_0 = 293.15;
T_01 = 273.16;
T = 273.15 + temperature;
h=humidity_vis*10^(-6.8346*(T_01/T)^(1.261)+4.6151);
f = (Fs*(0:(L/2))/L)';
fro = (pa/pr)*(24+4.04*10^4*h*((0.02+h)/(0.391+h)));
frn = (pa/pr)*(T/T_0)^(-1/2)*(9+280*h*exp(-4.170*((T/T_0)^(-1/3)-1)));
a = 8.686.*f.^2.*((1.84*10.^(-11).*(pa/pr).^(-1).*(T/T_0).^(1/2))+(T/T_0).^(-5/2).*(0.01275.*(exp(-2239.1/T)).*(fro+(f.^2/fro)).^(-1)+0.1068.*(exp(-3352/T)).*(frn+(f.^2/frn)).^(-1)));
an = -a*10;
absorbtion = [10.^(an(2:end)/20); flip(10.^(an(2:end)/20))];
freq = (input_f./absorbtion);
ir_upwards_dis = real(ifft(freq));
% ---------


% distance filter -------
f = (Fs*(0:(L/2))/L)';
number = 6;
H_kudo = 0.356;
H_dis = 0.004;
H = H_kudo*number + (number-1)*H_dis;
limit = real((3/2).*f/1000.*H^2.*sqrt(1-(1./(3.*(f/1000).*H))));

for v=1:1:3
    
dis = 30+(v*10);
ref = 1;

for i=1:length(limit)
    if limit(i) >dis
       limit_ed(i) =dis;
    end
    if limit(i) <dis
        limit_ed(i)=limit(i);
    end
    if limit(i) <ref
        limit_ed(i)=ref;
    end
end


for i = 1:length(limit_ed)
areal = (limit_ed(i)/2);
area = areal*2^2;

a = [area area*2 area*4 area*8 area*16];
b = [area area*4 area*4*4 area*4*4*4 area*4*4*4*4];

p = polyfit(a,b,3);
x1 = linspace(8,64);
y1 = polyval(p,x1);

result_find = find(x1>dis);

area_diff = y1(result_find(1))/ref;
mic_db(v,i) = -10*log10(area_diff);
end
end
dif_40_50 = (mic_db(2,:)-mic_db(1,:))';
dif_50_60 = (mic_db(2,:)-mic_db(3,:))';

% first mic
input = ir_downwards_dis;
input_f = fft(input);
loss = abs([10.^(dif_40_50(2:end)/20); flip(10.^(dif_40_50(2:end)/20))]);
freq = (input_f.*loss);
ir_downwards= real(ifft(freq));

% back mic
input = ir_upwards_dis;
input_f = fft(input);
loss = abs([10.^(dif_50_60(2:end)/20); flip(10.^(dif_50_60(2:end)/20))]);
freq = (input_f.*loss);
ir_upwards = real(ifft(freq));

% ------------------------------


BW = '1 octave';
N = 6;           % Filter Order
F0 = 1000;       % Center Frequency (Hz)
Fs = 44100;      % Sampling Frequency (Hz)
oneOctaveFilter = octaveFilter('FilterOrder', N, ...
    'CenterFrequency', F0, 'Bandwidth', BW, 'SampleRate', Fs);

F0 = getANSICenterFrequencies(oneOctaveFilter);
F0(F0<60) = [];
F0(F0>20e3) = [];
F0(9)=1.584893192461113e+04;
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
for i=1:Nfc
result(l_eq_no,b) = l_eq_upwards(i);
result(l_eq_no,b+1) = l_eq_center(i);
result(l_eq_no,b+2) = l_eq_downwards(i);
b=b+3;
end

 %%
 res_men = round(result);
 res_avg = round(mean(result),2);
 
 for i=1:Nfc   
 res_dif(:,i) = result(:,3+(i-1)*3) - result(:,1+(i-1)*3);
 end
 
 res_dif_rou = round(res_dif,2)
 %%

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
semilogx(f_axis,downwards_refraction)
hold on
%semilogx(f_axis,center_refraction)
semilogx(f_axis,upwards_refraction)
grid on
grid minor
axis([100 20000 20 100])
ylabel('Level [dB]')
xlabel('Frequency [Hz]')
legend({'first','back'},'Location','northeast')

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
