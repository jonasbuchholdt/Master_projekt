
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                      %
%          SOUND LEVEL METER           %
%                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

%% This is the main program . 

Configuration_file;
Filter_coef = load ('Filter_coefficients.mat');

    disp('Par�metros de configuraci�n: OK');


%%Custom Calibration
if s.Calibration.calibrate==1
   
    [signal_ref,Fs_ref,Nbits_ref,p_pascal]=mic_calibration();    
    s.Calibration.Signal_Calibration=signal_ref;
    s.Calibration.p_pascal_ref=p_pascal;
    disp('Calibraci�n por el usuario: OK');

    
%% Default Calibration %%

elseif s.Calibration.calibrate==0 
    
    if s.Signal.device==0
        
        [signal_ref,Fs_ref,Nbits_ref]=audioread('Calibracion_94dB_1Khz_CEntrance_NTiAudio.wav');

    elseif s.Signal.device==1
        
        [signal_ref,Fs_ref,Nbits_ref]=wavread('Calibracion_94dB_1Khz_Art_Behringer.wav');

    end
                                                                                          
    p_94dBSPL=1; %%94 dBSPL equivalen a 1 pascal                                            
    s.Calibration.Signal_Calibration=signal_ref;
    s.Calibration.p_pascal_ref=p_94dBSPL;
    disp('Calibraci�n por defecto: OK');
end

%%%%%%%%%%%%%%%%%%%%%%%%
% CALIBRATION FILENAME %
%%%%%%%%%%%%%%%%%%%%%%%%

%CENTRANCE: Calibracion_94dB_1Khz_CEntrance_NTiAudio.wav

%ART: Calibracion_94dB_1Khz_Art_Behringer.wav




%%Frequency Response Calibration : ( Not developed )

% [H_freq_res_cal]=frequency_response_calibration(sys_signal_freq_res_cal,sys_Fs_freq_res_cal,ref_signal_freq_res_cal,ref_Fs_freq_res_cal);

%%

%third octave round
third_octave=[25 32 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIRD OCTAVE FREQUENCY CALIBRATION ARRAY %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%CENTRANCE  [3.9 1.9 1.5 1.4 1.2 1 0.9 0.8 0.9 0.9 0.8 0.7 1 0.9 0.8 1.1 0 0.8 1.9 0 2 0.4 0.5 -0.8 0.7 0.6 0.3 -1.2 -1 -1.5];
%ART  [3.9 2 1.3 1.2 0.9 0.3 1 -0.1 0.3 0 0 -0.2 -0.1 -0.2 0.3 0.2 -0.1 0.8 -0.3 -2.2 4.8 -1.3 -0.9 -1.3 -1.8 1.4 -2.7 -0.2 -1.1 -3];

third_octave_calibration_dB_array_Art = [3.9 2 1.3 1.2 0.9 0.3 1 -0.1 0.3 0 0 -0.2 -0.1 -0.2 0.3 0.2 -0.1 0.8 -0.3 -2.2 4.8 -1.3 -0.9 -1.3 -1.8 1.4 -2.7 -0.2 -1.1 -3];
third_octave_calibration_dB_array_CEntrance = [3.9 1.9 1.5 1.4 1.2 1 0.9 0.8 0.9 0.9 0.8 0.7 1 0.9 0.8 1.1 0 0.8 1.9 0 2 0.4 0.5 -0.8 0.7 0.6 0.3 -1.2 -1 -1.5];
ceros=zeros(1,30);

if s.Signal.device==0
    
    third_octave_calibration_dB= third_octave_calibration_dB_array_CEntrance;
    
elseif s.Signal.device==1
    
    third_octave_calibration_dB= third_octave_calibration_dB_array_Art;
    
end



%octave vector
octave_array=[31.62 63.1 125.89 251.19 501.19 1000 1995.26 3981.07 7943.28 15848.93];

%third octave vector
third_octave_array=[25.12 31.62 39.81 50.12 63.1 79.43 100 125.89 158.49 199.53 251.19 316.23 398.11 501.19 630.96 794.33 1000 1258.93 1584.89 1995.26 2511.89 3162.28 3981.07 5011.87 6309.57 7943.28 10000 12589.25 15848.93 19952.62];

%third and twelve octave vector
twelve_octave_array=[670 710 750 800 850 900 950 1000 1060 1120 1180 1250 1320 1400 1500 1600 1700 1800 1900 2000 2120 2240 2360 2500 2650 2800 3000 3150 3350 3550 3750 4000 4250 4500 4750 5000 5300 5600 6000 6300 6700 7100 7500 8000 8500 9000 9500 10000 10600 11200 11800 12500 13200 14000 15000 16000 17000 18000 19000 20000];
third_twelve_octave_array=[25.12 31.62 39.81 50.12 63.1 79.43 100 125.89 158.49 199.53 251.19 316.23 398.11 501.19 630.96 728.62 771.79 817.52 865.96 917.27 971.63 1000 1154.78 1223.21 1295.69 1372.46 1453.78 1539.93 1631.17 1727.83 1830.21 1938.65 2053.53 2175.2 2304.1 2440.62 2585.24 2738.42 2900.68 3072.56 3254.62 3447.47 3651.74 3868.12 4097.32 4340.1 4597.2 4869.68 5158.22 5463.87 5787.62 6130.56 6493.82 6878.6 7286.18 7717.92 8175.23 8659.64 9172.76 9716.28 10292 10901.85 11547.82 12232.071 12956.87 13724.61 14537.84 15399.27 16311.73 17278.26 18302.06 19386.53 20535.25 21752.04 23040.93];

p_ref=2*10^(-5);
s.Signal.Octave_array=octave_array;
s.Signal.Third_Octave_array=third_octave_array;
s.Signal.Twelve_Octave_array=twelve_octave_array;
s.Signal.Third_Twelve_Octave_array=third_twelve_octave_array;
s.Signal.Third_Octave_round=third_octave;

s.Signal.Filter_coefficients= Filter_coef;

s.Calibration.Fs_Signal_Calibration=Fs_ref;
s.Calibration.Nbits_Signal_Calibration=Nbits_ref;
s.Calibration.Pressure_ref=p_ref;
s.Calibration.third_octave_calibration_dB=third_octave_calibration_dB;
s.Calibration.third_octave_calibration_dB_array_Art = third_octave_calibration_dB_array_Art;
s.Calibration.third_octave_calibration_dB_array_CEntrance = third_octave_calibration_dB_array_CEntrance;

%%Record Mode
if strcmp(s.Signal.mode,'record')

        disp('Adquiriendo audio...');

 % To record with any duration execute : 
%     [signal,Fs,Nbits,time,nfft]= Record(s.Signal.duration);
%     refreshRate=s.Signal.duration;
 % instead of if - end sentence %%

if s.Signal.duration==5
    refreshRate=5;
    [signal,Fs,Nbits,time,nfft]=Record(refreshRate);
elseif s.Signal.duration==15
    refreshRate=15;
    [signal,Fs,Nbits,time,nfft]=Record(refreshRate);
elseif s.Signal.duration==30
    refreshRate=30;
    [signal,Fs,Nbits,time,nfft]=Record(refreshRate);
end
    disp('Adquisici�n de audio: OK');

%%

%Window size (samples per window)
s.Signal.n_samples=3000;
%Overlap
s.Signal.overlap=0;
%Window shift in Windowing
s.Signal.w_shift = s.Signal.n_samples - ((s.Signal.overlap/100)*(s.Signal.n_samples));

%Stored signal parameters.
s.Signal.Recorded=signal;
s.Signal.RMS=signal/sqrt(2);
s.Signal.Time=time;
s.Signal.Fs=Fs;
s.Signal.Time_seconds=length(s.Signal.Recorded)/s.Signal.Fs;
s.Signal.Nbits=Nbits;
s.Signal.RefreshRate=refreshRate;
s.Signal.RefreshRate=s.Signal.duration;
s.Signal.SamplesPerTrigger=nfft;

Aux_s=s;

%%Signal Analisys
[s]=filter_bank(Aux_s);

%%

%%Real Time Mode
elseif strcmp(s.Signal.mode,'realtime')
    
    %Window size (samples per window)
    s.Signal.n_samples=1000;
    %Overlap
    s.Signal.overlap=0;
    %Window shift in Windowing
    s.Signal.w_shift = s.Signal.n_samples - ((s.Signal.overlap/100)*(s.Signal.n_samples));
    
    realtimeSPL(s.Calibration.Signal_Calibration,s.Calibration.p_pascal_ref,s.Signal.Frequency_weighting.FFT,s.Signal.Time_weighting,s.Signal.n_samples,s.Signal.w_shift,s.Signal.fft_size,s.Signal.Frequency_weighting.SPL,s.Signal.Frequency_weighting.Leq,third_octave,s.Calibration.third_octave_calibration_dB,s.Signal.Filter_coefficients,s.Signal.device);
    

end    


