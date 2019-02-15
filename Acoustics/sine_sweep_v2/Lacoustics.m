function [f_axis,f_result,t_axis,t_result] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime)


switch cmd
    case 'cali_soundcard'
        load('calibration.mat');
        load('highPass20.mat');
        [fs,impulse_response,irtime]=IRmeas_fft_soundcard(sweepTime,frequencyRange,gain,offset,inputChannel);
        irEstimate = impulse_response(1:length(impulse_response)/2);
        [b,a]=sos2tf(SOS,G);
        irEstimate_distortion_less=filter(b,a,irEstimate);
        [tf,w] = freqz(irEstimate_distortion_less,1,frequencyRange(2),fs);        
        calibration.preamp_transfer_function=tf;
        save('calibration.mat','calibration','-append');  
     
    case 'cali_mic'
        [fs,y]=irmeas_fft_mic();            
        add = rms(y)*sqrt(2);            
        load('calibration.mat')
        %calibration.mic_sensitivity = add;
        calibration.mic_sensitivity = 0.15; 
        save('calibration.mat','calibration','-append');        

     
     case 'test'                             
        %player=SynchronizedPlaybackAcquirer;    % initializing I-O via soundcard
        [fs,impulse_response,irtime]=IRmeas_fft_womics(sweepTime,frequencyRange,gain,offset,inputChannel);
        t_axis = irtime;
        t_result = impulse_response;
        f_axis = 0;
        f_result = 0;
       
    case 'transfer'                                                
        [fs,impulse_response,irtime]=IRmeas_fft(sweepTime,frequencyRange,gain,offset,inputChannel);
        f_axis = 0;
        f_result = 0;
        t_axis = irtime;
        t_result = impulse_response;
end