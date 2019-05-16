
clear

humidity = 46;
temperature = 12;
pa = 101.325;
pr = 101.325;
T_0 = 293.15;
T_01 = 273.16;
T = 273.15 + temperature;
h=humidity*10^(-6.8346*(T_01/T)^(1.261)+4.6151);

f = [20:1:20000];



fro = (pa/pr)*(24+4.04*10^4*h*((0.02+h)/(0.391+h)));
frn = (pa/pr)*(T/T_0)^(-1/2)*(9+280*h*exp(-4.170*((T/T_0)^(-1/3)-1)));
a = 8.686.*f.^2.*((1.84*10.^(-11).*(pa/pr).^(-1).*(T/T_0).^(1/2))+(T/T_0).^(-5/2).*(0.01275.*(exp(-2239.1/T)).*(fro+(f.^2/fro)).^(-1)+0.1068.*(exp(-3352/T)).*(frn+(f.^2/frn)).^(-1)));
an = -a*10;

semilogx(an)


%%

clear 
[y,fs] = audioread('sweep.wav');


sig = y(:,1);



% viscosity filter ----
input = sig;
humidity = 46;
temperature = 12;
Fs = 44100;
L = length(input);
input_f = fft(input);
pa = 101.325;
pr = 101.325;
T_0 = 293.15;
T_01 = 273.16;
T = 273.15 + temperature;
h=humidity*10^(-6.8346*(T_01/T)^(1.261)+4.6151);
f = (Fs*(0:(L/2))/L)';
fro = (pa/pr)*(24+4.04*10^4*h*((0.02+h)/(0.391+h)));
frn = (pa/pr)*(T/T_0)^(-1/2)*(9+280*h*exp(-4.170*((T/T_0)^(-1/3)-1)));
a = 8.686.*f.^2.*((1.84*10.^(-11).*(pa/pr).^(-1).*(T/T_0).^(1/2))+(T/T_0).^(-5/2).*(0.01275.*(exp(-2239.1/T)).*(fro+(f.^2/fro)).^(-1)+0.1068.*(exp(-3352/T)).*(frn+(f.^2/frn)).^(-1)));
an = -a*10;
absorbtion = [10.^(an(2:end)/20); flip(10.^(an(2:end)/20))];
freq = (input_f.*absorbtion);
output = real(ifft(freq));
% ---------



sig_fil = output;


% generate frequency response
Y = fft(sig);
P2 = (Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
sig_f = P1;

Y = fft(sig_fil);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
sig_fil_f = P1;

w = (Fs*(0:(L/2))/L)';


% db
sig_db = (20*log10(abs(sig_f/(20*10^-6))));
sig_fil_db = (20*log10(abs(sig_fil_f/(20*10^-6))));

and = downsample(an,50)
wd = downsample(w,50)
semilogx(wd,and)
hold on
semilogx(wd,-and)
axis([20 20000 -6 6])
grid on
xlabel('Frequency [Hz]')
ylabel('Amplification [dB]')

legend({'Front microphone filter','Back microphone filter'},'Location','northwest')

%%

% plot
semilogx(w,sig_db+(-sig_db+65)-65)
hold on
semilogx(w,sig_fil_db+(-sig_db+65)-65)
grid on

%semilogx(w,an)
axis([20 20000 -10 2])








