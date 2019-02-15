function []=sound_meter(input)

%% constants 
clear all
load('signal.mat')
input = sig2;
T = 1/fs;
time = 0.125;
tau = time*fs;
p0 = 20*10^(-6);
p = abcfilt(input,'a');
%p = sig2;
figure(1)
%% time linear 
for i = 1:1:length(sig1)/tau
a=tau*(i-1)+1;
b=a+tau-1;
p_e = (1/tau*trapz(p(a:b).^2))^(1/2);
L_pl(i) = 20*log10((p_e/p0));
end
plot(L_pl)
hold on
%% time exponentials
for i = 1:1:length(sig1)/tau
a=tau*(i-1)+1;
b=a+tau-1;
p_e = ((1/tau)*trapz(p(1:b).^2.*exp(([1:b]-b)/tau)'))^(1/2);
L_pe(i) = 20*log10((p_e/p0));
end
plot(L_pe)
legend('linear','exp')
%% 
L_Aeq = 10*log10(1/(length(p))*trapz(p.^2/p0^2))
L_Aeq8h = 10*log10(1/(8*60*60*fs)*trapz(p.^2/p0^2))

%% One Third octave analysis
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
        'CenterFrequency', F0(i), 'Bandwidth', BW, 'SampleRate', fs); %#ok
end
clear oneThirdOctaveFilter
%yp = zeros(Nx,Nfc);

for i=1:Nfc
    oneThirdOctaveFilter = oneThirdOctaveFilterBank{i};
    yp(:,i) = oneThirdOctaveFilter(p);
end

L_Aeqthird = 10*log10(1/(length(yp))*trapz(yp.^2/p0^2))
figure(2)
b = bar(L_Aeqthird)
bl = b.BaseLine;
c = bl.Color;
bl.BaseValue = -100;

%% FFT way
L = length(p);             
fsig = fft(p);
P2 = abs(fsig/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(L/2))/L;
figure(3)
spec = 20*log10(abs(P1)/p0);
semilogx(f,spec)
hold on
axis([20 20000 -inf inf])
grid on



