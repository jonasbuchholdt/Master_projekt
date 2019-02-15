function stopSC(kk,kk2)

%%This function checks the stop button and stops the sound acquisition or launches the Real Time Mode . 

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

% Obtain analog input device from data field.
figData = get(gcbf,'UserData');
ai = figData.ai;

% Stop/restart input device (if currently running).
if isrunning(ai)
    clear functions  % Clear persistent variables t1 and Leq1 from estL.m
   stop(ai);   
   set(figData.uiButton,'string','Restart');
else 

   delete(ai);
   realtimeSPL(figData.signal_ref,figData.p_pascal_ref,figData.FFT_Frequency_weighting,figData.Time_weighting ,figData.n_samples,figData.w_shift,figData.fft_size,figData.SPL_Frequency_weighting ,figData.Leq_Frequency_weighting,figData.third_octave,figData.third_octave_calibration_dB,figData.Filter_coef,figData.device );
end