function filter_bank_plot(Aux_s)

%%This function plots all the acoustics parameters from the signal analisys
%%in Record Mode

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

modfsegW=Aux_s.Signal.fft;
data_dBSPLW=Aux_s.Signal.dBSPL;
filter_array_fft_signal=Aux_s.Signal.octave_analysis_array;
fHz=0:Aux_s.Signal.Fs/Aux_s.Signal.fft_size:Aux_s.Signal.Fs/2;
data_Leq_T=Aux_s.Signal.LeqT;
p_ref=Aux_s.Calibration.Pressure_ref;


figure; clf;
set(gcf,'Name','Sound Level Meter  | Record Mode |');
set(gcf,'NumberTitle','off');


%%FFT plot
        
    
    
    if Aux_s.Signal.fft_size==2048
        
        if Aux_s.Signal.device==0
            cor=2.5/5;
            Plot=10*log10(modfsegW/(p_ref*cor*Aux_s.Signal.duration));    %CEntrance
            
        elseif Aux_s.Signal.device==1
            cor=2/5;
            Plot=10*log10(modfsegW/(p_ref*cor*Aux_s.Signal.duration));    %Art

        end
        
        
    elseif Aux_s.Signal.fft_size==4096
     
     if Aux_s.Signal.device==0
         cor=3.8/5;
        Plot=10*log10(modfsegW/(p_ref*cor*Aux_s.Signal.duration));    %CEntrance
     
     elseif Aux_s.Signal.device==1
         cor=3/5;
        Plot=10*log10(modfsegW/(p_ref*cor*Aux_s.Signal.duration));    %Art
         
     end
     
        
    elseif Aux_s.Signal.fft_size==8192
        
     
     if Aux_s.Signal.device==0
        cor=3.8/5;
        Plot=10*log10(modfsegW/(p_ref*cor*Aux_s.Signal.duration));    %CEntrance
     
     elseif Aux_s.Signal.device==1
         cor=3/5;
        Plot=10*log10(modfsegW/(p_ref*cor*Aux_s.Signal.duration));    %Art

         
     end
     
        
    end
    
    
    subplot(2,2,1);
    semilogx(fHz,Plot);
    axis ([ 20 24000 20 100 ]);
    xlabel('Frequency (Hz)');
    title(' FFT ');


if strcmp(Aux_s.Signal.Frequency_weighting.FFT,'A')
    
    ylabel('Magnitude (dBA)');
    
elseif strcmp(Aux_s.Signal.Frequency_weighting.FFT,'C')
    
    ylabel('Magnitude (dBC)');
    
elseif strcmp(Aux_s.Signal.Frequency_weighting.FFT,'none')
    
    ylabel('Magnitude (dB)');
    
end
%%    

%%Octave filter plot

        subplot(2,2,3);
        octave_max=max(filter_array_fft_signal,[],2);
        bar(octave_max);
        ylim([20 100]);

        
    
if strcmp(Aux_s.Signal.Frequency_weighting.Octave,'A')
    
        ylabel('Leq (dBA)');
        
elseif strcmp(Aux_s.Signal.Frequency_weighting.Octave,'C')
    
        ylabel('Leq (dBC)');
        
elseif strcmp(Aux_s.Signal.Frequency_weighting.Octave,'none')

        ylabel('Leq (dB)');
        
end

F03=[25; 32; 40; 50; 63; 80; 100; 125; 160; 200; 250; 315; 400; 500; 630; 800; 1000; 1250; 1600; 2000; 2500; 3150; 4000; 5000; 6300; 8000; 10000; 12500; 16000; 20000];
F12=[25 32 40 50 63 80 100 125 160 200 250 315 400 500 670 710 750 800 850 900 950 1000 1060 1120 1180 1250 1320 1400 1500 1600 1700 1800 1900 2000 2120 2240 2360 2500 2650 2800 3000 3150 3350 3550 3750 4000 4250 4500 4750 5000 5300 5600 6000 6300 6700 7100 7500 8000 8500 9000 9500 10000 10600 11200 11800 12500 13200 14000 15000 16000 17000 18000 19000 20000];


    if strcmp(Aux_s.Signal.octave_analysis,'octave')
    
        title('Octave Analisys');    
        set(gca,'XTickLabel',[32; 63; 125; 250; 500; 1000; 2000; 4000; 8000; 16000]);
        xlabel('Octave Band');
        
    elseif strcmp(Aux_s.Signal.octave_analysis,'third_octave')
        
        title('Third Octave Analisys'); 
        xlabel('Third Octave Band');
        
          ax = axis;  
          axis([0 length(F03) ax(3) ax(4)]) 
          set(gca,'XTick',2:3:length(F03)); 		 
          set(gca,'XTickLabel',round(F03(2:3:length(F03))));
        
    elseif strcmp(Aux_s.Signal.octave_analysis,'twelve_octave')
    
        title('Twelve Octave Analisys'); 
        xlabel('Twelve Octave Band');
        
          ax = axis;  
          axis([0 length(F12) ax(3) ax(4)]) 
          set(gca,'XTick',2:12:length(F12)); 		 
          set(gca,'XTickLabel',round(F12(2:12:length(F12))));
        
    end
    
       
%%

%%Time-domain signal plot
    subplot(3,2,2);
    plot(Aux_s.Signal.Time,Aux_s.Signal.Recorded);
    axis([0 Aux_s.Signal.RefreshRate -1 1]);
    xlabel('Time (s)');
    ylabel('Value');
    title('Waveform');
%%    

    
%%SPL plot
    subplot(3,2,4);
    x_time=0:(length(data_dBSPLW)*(Aux_s.Signal.w_shift)/(Aux_s.Signal.Fs))/(length(data_dBSPLW)-1):(length(data_dBSPLW)*(Aux_s.Signal.w_shift)/(Aux_s.Signal.Fs));
    plot(x_time,data_dBSPLW);
    hold on
    data_Leq_T_vector=zeros(1,length(x_time));
    for p=1:length(x_time)
        data_Leq_T_vector(p)=data_Leq_T;
    end
    plot(x_time,data_Leq_T_vector,':r');
    ylim([20 100]);
    legend('SPL','Leq','Location','NorthEast');
    hold off

        xlabel('Time');

    if strcmp(Aux_s.Signal.Frequency_weighting.SPL,'A')
            
        ylabel('Magnitude (dBA)');

    elseif strcmp(Aux_s.Signal.Frequency_weighting.SPL,'C')

       ylabel('Magnitude (dBC)');
       
    elseif strcmp(Aux_s.Signal.Frequency_weighting.SPL,'none')

       ylabel('Magnitude (dB)');
       
    end


   if strcmp(Aux_s.Signal.Time_weighting,'Fast')
       
       title('Fast');
       
   elseif strcmp(Aux_s.Signal.Time_weighting,'Slow')
       
       title('Slow');
       
   elseif strcmp(Aux_s.Signal.Time_weighting,'none')
       
       title('No Temporal Weighting');
       
    end


%%

%%Leq plot
    subplot(6,2,12);

    if strcmp(Aux_s.Signal.Frequency_weighting.Leq,'A')

    
    axis off;
    Leq_str = sprintf('%5.1f%s',data_Leq_T,' dBA');
    Leq_text =  text(1.0,0.5,Leq_str,...
    'FontSize',38,'HorizontalAlignment','Right');
    title('\fontsize{24}Leq');

    elseif strcmp(Aux_s.Signal.Frequency_weighting.Leq,'none')
        
    axis off;
    Leq_str = sprintf('%5.1f%s',data_Leq_T,' dB');
    Leq_text =  text(1.0,0.5,Leq_str,...
    'FontSize',38,'HorizontalAlignment','Right');
    title('\fontsize{24}Leq');

    end
    
%%