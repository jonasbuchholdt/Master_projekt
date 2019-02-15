function [L_pF,L_pS]= OneThirdOctaveAnalyser(timeF,timeS,input,fs) 

%% constants 
%  fs=48000;
%  timeF = 0.125;
%  timeS = 1;
%  input = buffer(1:48000);
 
tauF = timeF*fs;
tauS = timeS*fs;
p0 = 20*10^(-6);

%% Analyser

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


for i=1:Nfc
    oneThirdOctaveFilter = oneThirdOctaveFilterBank{i};
    output(:,i) = oneThirdOctaveFilter(input);   
    p_eF(i) = ((1/tauF)*trapz(output(:,i).^2.*exp(([1:length(output(:,i))]-length(output(:,i)))/tauF)'))^(1/2);
    p_eS(i) = ((1/tauS)*trapz(output(:,i).^2.*exp(([1:length(output(:,i))]-length(output(:,i)))/tauS)'))^(1/2);
    L_pF(i) = 20*log10((p_eF(i)/p0));
    L_pS(i) = 20*log10((p_eS(i)/p0));
end







