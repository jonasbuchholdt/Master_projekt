function fft_signal_cal = FRcal(fft_signal,third_octave,third_octave_calibration_dB) 

%This function calibrates the fft signal from a third octave array in dB. 

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

fft_signal_dB=10*log10(fft_signal);

 fft_signal_dB_cal=zeros(1,length(fft_signal));
 for i=1:length(third_octave)-1

     octave_3=third_octave(i);
     octave_3_next=third_octave(i+1);
     
     octave_3_cal=third_octave_calibration_dB(i);
     
     for j=round(length(fft_signal)*octave_3/20000):round(octave_3_next*length(fft_signal)/20000)
        
         index=round(length(fft_signal)*octave_3/20000);
         if index>0
            if (isempty(fft_signal_dB(index))==0)
                fft_signal_dB_cal(j)=fft_signal_dB(j) + octave_3_cal;
            end
         end
     end
     
     
 end
        
fft_signal_cal=zeros(1,length(fft_signal_dB_cal));

 for i=1:length(fft_signal_dB_cal)
 fft_signal_cal(i)=10^(fft_signal_dB_cal(i)/10);
 end
 
 