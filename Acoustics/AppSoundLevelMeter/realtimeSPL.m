function realtimeSPL(signal_ref,p_pascal_ref,FFT_Frequency_weighting,Time_weighting,n_samples,w_shift,fft_size,SPL_Frequency_weighting,Leq_Frequency_weighting,third_octave,third_octave_calibration_dB,Filter_coef,device)

%%This function starts Real Time Mode

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

clc;

%Acquisition settings
[ai,nfft,sampleRate] = initSC;
pause(0.250)
%Acquisition
signal = peekdata(ai,nfft);

%Signal analisys
[modfseg,data_dBSPL,signal,data_Leq_T] = estL(signal,nfft,sampleRate,signal_ref,p_pascal_ref,FFT_Frequency_weighting,Time_weighting,n_samples,w_shift,fft_size,SPL_Frequency_weighting,Leq_Frequency_weighting,Filter_coef);

%set Plot results
initDP(ai,sampleRate,FFT_Frequency_weighting,signal,modfseg,data_dBSPL,signal_ref,p_pascal_ref,Time_weighting,n_samples,w_shift,fft_size,SPL_Frequency_weighting,Leq_Frequency_weighting,data_Leq_T,third_octave,third_octave_calibration_dB,Filter_coef,device);

%Start real-time data acquisition.
set(ai,'TimerFcn',@upD);
