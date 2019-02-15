function upD(obj,kk)

%%This function updates the sound acquisition and the SPL, Leq, FFT signal and
%%time domain signal values in Real Time Mode.

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

% Extract figure data from callback object.
figData = obj.userData;
% Read current input data from sound card.
signal = peekdata(obj,obj.SamplesPerTrigger);flushdata(obj);

% Estimate signal level
[modfseg,data_dBSPL,signal,data_Leq_T] = estL(signal,obj.SamplesPerTrigger,obj.SampleRate,figData.signal_ref,figData.p_pascal_ref,figData.FFT_Frequency_weighting,figData.Time_weighting,figData.n_samples,figData.w_shift,figData.fft_size,figData.SPL_Frequency_weighting,figData.Leq_Frequency_weighting,figData.Filter_coef);

% Calibrate fft signal
fft_signal_cal = FRcal(modfseg,figData.third_octave,figData.third_octave_calibration_dB);

%%Update SPL
if strcmp(figData.SPL_Frequency_weighting,'A')
    dBA_str = sprintf('%5.1f%s',data_dBSPL,' dBA');
elseif strcmp(figData.SPL_Frequency_weighting,'C')
    dBA_str = sprintf('%5.1f%s',data_dBSPL,' dBC');
elseif strcmp(figData.SPL_Frequency_weighting,'none')
    dBA_str = sprintf('%5.1f%s',data_dBSPL,' dB');
end

persistent t;

if isempty(t)
% Update sound level meter display.
set(figData.dBA_text,'string',dBA_str);
%%
t=0;

elseif t==4
% Update sound level meter display.
set(figData.dBA_text,'string',dBA_str);
t=0;
end
t=t+1;


%%Update Leq
if strcmp(figData.Leq_Frequency_weighting,'A')
    Leq_str = sprintf('%5.1f%s',data_Leq_T,' dBA');
elseif strcmp(figData.Leq_Frequency_weighting,'C')
    Leq_str = sprintf('%5.1f%s',data_Leq_T,' dBC');
elseif strcmp(figData.Leq_Frequency_weighting,'none')
    Leq_str = sprintf('%5.1f%s',data_Leq_T,' dB');
end

% Update sound level meter display.
set(figData.Leq_text,'string',Leq_str);


%%

upPlotD(obj.sampleRate,fft_signal_cal,signal,figData.FFT_Frequency_weighting,figData.fft_size,figData.device);


