function initDP(ai,sampleRate,FFT_Frequency_weighting,signal,modfseg,data_dBSPL,signal_ref,p_pascal_ref,Time_weighting,n_samples,w_shift,fft_size,SPL_Frequency_weighting,Leq_Frequency_weighting,data_Leq_T,third_octave,third_octave_calibration_dB,Filter_coef,device)

%%This function initializes the program display where the acoustic parameters are plotted in Real Time Mode. 

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

% Create figure window.
figWindow = figure(1); clf;
set(gcf,'Name','Sound Level Meter  | Real Time Mode |');
set(gcf,'NumberTitle','off','MenuBar','none');
    axis on;
    subplot(2,1,1);
    p_ref=2*10^(-5);
    fHz=0:sampleRate/fft_size:sampleRate/2;
    fftPlot = semilogx(fHz,10*log10(modfseg/p_ref));
    axis ([ 20 24000 20 100 ]);
    grid on
    xlabel('Frequency (Hz)');
    title(' FFT ');

if strcmp(FFT_Frequency_weighting,'A')
    ylabel('Magnitude (dBA)');
elseif strcmp(FFT_Frequency_weighting,'C')
    ylabel('Magnitude (dBC)');
elseif strcmp(FFT_Frequency_weighting,'none')
    ylabel('Magnitude (dB)');
end
  

% SPL
    subplot(8,3,16);
    axis off;

if strcmp(SPL_Frequency_weighting,'A')
    dBA_str = sprintf('%5.1f%s',data_dBSPL,' dBA');
    dBA_text =  text(1.0,0.5,dBA_str,...
    'FontSize',25,'HorizontalAlignment','Right');
    title('\fontsize{14}SPL');
    
elseif strcmp(SPL_Frequency_weighting,'C')
    dBA_str = sprintf('%5.1f%s',data_dBSPL,' dBC');
    dBA_text =  text(1.0,0.5,dBA_str,...
    'FontSize',25,'HorizontalAlignment','Right');
    title('\fontsize{14}SPL');
    
elseif strcmp(SPL_Frequency_weighting,'none')
    dBA_str = sprintf('%5.1f%s',data_dBSPL,' dB');
    dBA_text =  text(1.0,0.5,dBA_str,...
    'FontSize',25,'HorizontalAlignment','Right');
    title('\fontsize{14}SPL');
    
end

% Leq
    subplot(8,3,22);
    axis off;

if strcmp(Leq_Frequency_weighting,'A')
    Leq_str = sprintf('%5.1f%s',data_Leq_T,' dBA');
    Leq_text =  text(1.0,0.5,Leq_str,...
    'FontSize',25,'HorizontalAlignment','Right');
    title('\fontsize{14}Leq');
    
elseif strcmp(Leq_Frequency_weighting,'C')
    Leq_str = sprintf('%5.1f%s',data_Leq_T,' dBC');
    Leq_text =  text(1.0,0.5,Leq_str,...
    'FontSize',25,'HorizontalAlignment','Right');
    title('\fontsize{14}Leq');

elseif strcmp(Leq_Frequency_weighting,'none')
    Leq_str = sprintf('%5.1f%s',data_Leq_T,' dB');
    Leq_text =  text(1.0,0.5,Leq_str,...
    'FontSize',25,'HorizontalAlignment','Right');
    title('\fontsize{14}Leq');
    
end

% Time-domain signal
      subplot(2,2,4);
    samplePlot = plot(signal);
      axis on;
      grid on;
      xlabel('Time (s)');
      ylabel('Value');
      title('Waveform');

% Create start/stop pushbutton.
uiButton = uicontrol('Style','pushbutton',...
   'Units', 'normalized',...
   'Position',[0.0150 0.0111 0.1 0.0556],...
   'Value',1,'String','Stop',...
   'Callback',@stopSC);

% Store global variables in figure data field.
% Note: This is used to pass variables between functions.
figData.figureWindow = figWindow;
figData.uiButton     = uiButton;
figData.samplePlot   = samplePlot;
figData.fftPlot      = fftPlot;
figData.dBA_text     = dBA_text;
figData.ai           = ai;
figData.FFT_Frequency_weighting    = FFT_Frequency_weighting;
figData.signal_ref   = signal_ref;
figData.p_pascal_ref        = p_pascal_ref;
figData.Time_weighting   = Time_weighting;
figData.n_samples         = n_samples;
figData.w_shift           = w_shift;
figData.fft_size          = fft_size;
figData.SPL_Frequency_weighting    = SPL_Frequency_weighting;
figData.Leq_Frequency_weighting    = Leq_Frequency_weighting;
figData.Leq_text       = Leq_text;

figData.third_octave    = third_octave;
figData.third_octave_calibration_dB = third_octave_calibration_dB;
figData.Filter_coef     = Filter_coef;
figData.device          = device;

set(gcf,'UserData',figData);
set(ai,'UserData',figData);  
   