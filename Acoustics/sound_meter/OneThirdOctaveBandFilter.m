
% Now design a 1/3-octave-band filter bank. Increase the order of each
% filter to 8:
clear all
Fs = 48000;      % Sampling Frequency (Hz)
BW = '1/3 octave'; 
N = 8;
F0 = 1000;
p0 = 20*10^(-6);


oneThirdOctaveFilter = octaveFilter('FilterOrder', N, ...
    'CenterFrequency', F0, 'Bandwidth', BW, 'SampleRate', Fs);
F0 = getANSICenterFrequencies(oneThirdOctaveFilter);
F0(F0<16) = [];
F0(F0>20e3) = [];
Nfc = length(F0);
for i=1:Nfc
    oneThirdOctaveFilterBank{i} = octaveFilter('FilterOrder', N, ...
        'CenterFrequency', F0(i), 'Bandwidth', BW, 'SampleRate', Fs); %#ok
end
clear oneThirdOctaveFilter


% make pink noise
Nx = 100000;
pinkNoise = dsp.ColoredNoise('Color','pink',...
                             'SamplesPerFrame',Nx,...
                             'NumChannels',1);



yp = zeros(Nx,Nfc);
tic,

while toc < 15
    % Run for 15 seconds
    xp = pinkNoise();
    for i=1:Nfc
        oneThirdOctaveFilter = oneThirdOctaveFilterBank{i};
        yp(:,i) = oneThirdOctaveFilter(xp);
    end
end

L_Aeq = 10*log10(1/(length(yp))*trapz(yp.^2/p0^2))
%%
visualize(oneThirdOctaveFilterBank{10}, 'class 1');
