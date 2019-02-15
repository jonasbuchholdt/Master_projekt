function upPlotD(sampleRate,modfseg,signal,FFT_Frequency_weighting,fft_size,device)

%%This function updates the plot results in Real Time Mode.

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

%%FFT plot
    subplot(2,1,1);
    p_ref=2*10^(-5);
    fHz=0:sampleRate/fft_size:sampleRate/2;
    
    if fft_size==2048
        
        if device==0
            cor=2.5/300;
            Plot=10*log10(modfseg/(p_ref*cor));    %CEntrance
            
        elseif device==1
            cor=2/300;
            Plot=10*log10(modfseg/(p_ref*cor));    %Art

        end
        
        
    elseif fft_size==4096
     
     if device==0
         cor=3.8/750;
        Plot=10*log10(modfseg/(p_ref*cor));    %CEntrance
     
     elseif device==1
         cor=3/750;
        Plot=10*log10(modfseg/(p_ref*cor));    %Art
         
     end
     
    elseif fft_size==8192
        
     
     if device==0
         cor=3.8/1500;
        Plot=10*log10(modfseg/(p_ref*cor));    %CEntrance
     
     elseif device==1
         cor=3/1500;
        Plot=10*log10(modfseg/(p_ref*cor));    %Art

         
     end
        
    end
    semilogx(fHz,Plot);
    axis ([ 20 24000 20 100 ]);
    grid on
    axis on
    xlabel('Frequency (Hz)');
    title(' FFT ');

    
if strcmp(FFT_Frequency_weighting,'A')
    ylabel('Magnitude (dBA)');
    
elseif strcmp(FFT_Frequency_weighting,'C')
    ylabel('Magnitude (dBC)');
elseif strcmp(FFT_Frequency_weighting,'none')
    ylabel('Magnitude (dB)');
    
end
     
%%

%% Time-domain signal plot
      subplot(2,2,4);
      plot(signal);
      axis([0 length(signal) -1 1]);
      axis on
      grid on

      title('Waveform');
%%