function [t_axis,t_result] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs)


switch cmd
    case 'cali_soundcard'
        load('calibration.mat');
        load('highPass20.mat');
        [impulse_response,~,y_rms]=IRmeas_fft_soundcard(sweepTime,frequencyRange,gain,offset,inputChannel,fs);
        irEstimate_distortion_free = impulse_response(1:length(impulse_response)/2);
        [b,a]=sos2tf(SOS,G);
        ir=filter(b,a,irEstimate_distortion_free);
        [tf,~] = freqz(ir,1,frequencyRange(2),fs); 
        calibration.preamp_transfer_function=tf;
        calibration.preamp_gain=y_rms; 
        save('calibration.mat','calibration','-append');  
     
    case 'cali_mic'
        %AutoPlayrecInit(fs);
        %x = playrec('rec',2*fs,inputChannel);
        %y = playrec('getRec',x);
        %add = rms(y);          
        load('calibration.mat')
        %calibration.mic_sensitivity = add;
        calibration.mic_sensitivity = 0.0367; 
        save('calibration.mat','calibration','-append');        

     
     case 'test'                             
        [impulse_response,irtime]=IRmeas_fft_womics(sweepTime,frequencyRange,gain,offset,inputChannel,fs);
        t_axis = irtime;
        t_result = impulse_response;

       
    case 'transfer'                                                
        [impulse_response,irtime]=IRmeas_fft(sweepTime,frequencyRange,gain,offset,inputChannel,fs);
        t_axis = irtime;
        t_result = impulse_response;
end