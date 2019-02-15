function[Aux_s]= filter_bank(Aux_s)

%%This function performs FFT signal and octave analisys and Frequency
%%Weighting in Record Mode

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

octave_array=Aux_s.Signal.Octave_array;
third_octave_array=Aux_s.Signal.Third_Octave_array;
twelve_octave_array=Aux_s.Signal.Twelve_Octave_array;

filt_coef = Aux_s.Signal.Filter_coefficients;


%% FFT Frequency Weighting

if strcmp(Aux_s.Signal.Frequency_weighting.FFT,'A')
    
    %% A Weighting
    A_weighted_signal=filter(filt_coef.Afilter,Aux_s.Signal.Recorded);
    signal=A_weighted_signal;
    
elseif strcmp(Aux_s.Signal.Frequency_weighting.FFT,'C')
    
    %% C Weighting
    C_weighted_signal=filter(filt_coef.Cfilter,Aux_s.Signal.Recorded);
    signal=C_weighted_signal;
    
elseif strcmp(Aux_s.Signal.Frequency_weighting.FFT,'none')
    signal=Aux_s.Signal.Recorded;

end

%%Sound pressure calibration
signal_ref_mean=mean(abs(Aux_s.Calibration.Signal_Calibration));

signal=((signal/signal_ref_mean)*Aux_s.Calibration.p_pascal_ref);


%%Signal Windowing
modfsegW=Windowing(signal,Aux_s.Signal.n_samples,Aux_s.Signal.w_shift,Aux_s.Signal.fft_size);
% 
    disp('Cálculo de la FFT: OK');

%%

signal=Aux_s.Signal.Recorded;

%% Octave Frequency Weighting

if strcmp(Aux_s.Signal.Frequency_weighting.Octave,'A')
    
    %% A Weighting
    A_weighted_signal=filter(filt_coef.Afilter,signal);
    signal=A_weighted_signal;
    
elseif strcmp(Aux_s.Signal.Frequency_weighting.Octave,'C')
    
    %% C Weighting
    C_weighted_signal=filter(filt_coef.Cfilter,signal);
    signal=C_weighted_signal;
    
elseif strcmp(Aux_s.Signal.Frequency_weighting.Octave,'none')
    signal=signal;

end

%%




%% Octave Analisys

if strcmp(Aux_s.Signal.octave_analysis,'octave')
   octave_calibration_dB=zeros(10,1);
   dBSPL_octave_array_cal=zeros(length(octave_array),1);
   
   %% Octave Calibration from third_octave array calibration in dB
       q=1;
for a=1:length(Aux_s.Calibration.third_octave_calibration_dB)

    if q>=3       
        octave_calibration_dB(a/3)=10*log10(( 10^(Aux_s.Calibration.third_octave_calibration_dB(a-2)/10) + 10^(Aux_s.Calibration.third_octave_calibration_dB(a-1)/10) + 10^(Aux_s.Calibration.third_octave_calibration_dB(a)/10))/3 );
        q=0;
    end
    q=q+1;
    
end
  %% 
    for i=1:length(octave_array)
          
        disp('Filtrando señal por bandas de octava... ');
        % Output signal
            filtered_signal=filter(filt_coef.Hd_octave(i),signal); 
        
            filtered_signal=Leq(Aux_s,filtered_signal);
    
        dBSPL_octave_array_cal(i)=filtered_signal + octave_calibration_dB(i);

    end

end
  
%%

%%  Third Octave Analisys

if strcmp(Aux_s.Signal.octave_analysis,'third_octave')
       dBSPL_octave_array_cal=zeros(length(third_octave_array),1);

        for i=1:length(third_octave_array)
            
            disp('Filtrando señal por bandas de tercios de octava... ');

           
            % Output signal
            filtered_signal=filter(filt_coef.Hd_third(i),signal);
            
            filtered_signal=Leq(Aux_s,filtered_signal);
   %% Third Octave Calibration from third octave array calibration in dB

            dBSPL_octave_array_cal(i)=filtered_signal  + Aux_s.Calibration.third_octave_calibration_dB(i);

   %%

   
        end  



end

%%

%% Twelve Octave Analisys

if strcmp(Aux_s.Signal.octave_analysis,'twelve_octave')
   dBSPL_octave_array_cal=zeros(length(third_octave_array),1);
   
        for i=1:15
   
            disp('Filtrando señal por bandas de doceavos de octava... ');

           
            % Output signal
            filtered_signal=filter(filt_coef.Hd_third(i),signal);
           
            filtered_signal=Leq(Aux_s,filtered_signal);


        dBSPL_octave_array_cal(i)=filtered_signal;

        
        end
%         q=1;
        for i=1:length(twelve_octave_array)

            disp('Filtrando señal por bandas de doceavos de octava... ');

           
            % Output Signal
            filtered_signal=filter(filt_coef.Hd_twelve(i),signal); 
                      
            filtered_signal=Leq(Aux_s,filtered_signal);

            dBSPL_octave_array_cal(i+15)=filtered_signal;
           
        end
    
       
end

    disp('Filtrado de señal: OK');


%%


%%SPL
[data_dBSPLW data_p]=SPL(Aux_s);
    disp('Cálculo de SPL: OK');


%%Leq
signal_Leq=Aux_s.Signal.Recorded;
%% Leq Frequency Weighting

if strcmp(Aux_s.Signal.Frequency_weighting.Leq,'A')
    %% A Weighting
    A_weighted_signal=filter(filt_coef.Afilter,signal_Leq);
    signal_Leq=A_weighted_signal;
    
    
elseif strcmp(Aux_s.Signal.Frequency_weighting.Leq,'none')
    signal_Leq=signal_Leq;

end
data_Leq_T=Leq(Aux_s,signal_Leq);
    disp('Cálculo de Leq: OK');


%% Calibrate fft signal
 fft_signal_cal = FRcal(modfsegW,Aux_s.Signal.Third_Octave_round,Aux_s.Calibration.third_octave_calibration_dB);
%%

Aux_s.Signal.fft=fft_signal_cal;
% Aux_s.Signal.fft=modfsegW; % No fft signal frequency calibration %
Aux_s.Signal.Pressure=data_p;
Aux_s.Signal.dBSPL=data_dBSPLW;
Aux_s.Signal.LeqT=data_Leq_T;
Aux_s.Signal.octave_analysis_array=dBSPL_octave_array_cal;
%%Plot results
filter_bank_plot(Aux_s);

        