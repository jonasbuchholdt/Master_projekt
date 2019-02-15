function [f_axis,f_result,t_axis,t_result] = Lacoustics(cmd,gain)


switch cmd
    case 'cali_soundcard'
        calibrate(gain)  
     
    case 'cali_mic'
        [fs,y]=irmeas_fft_mic();            
        add = rms(y)*sqrt(2);            
        load('calibration.mat')
        calibration.mic_sensitivity = add;        
        save('calibration.mat','calibration','-append');        

     
     case 'test'
        flower= 20;                             % lower frequency border for sweep      [Hz]
        fupper=22000;                           % upper frequency border for sweep      [Hz]
        ts= 1;                                  % length of sweep                        [s]
        tw= 1;                                  % est. length of IR                      [s]
        playgain=gain;                            % gain for sweep playback               [dB]
        incal=0.1;                          
        outcal=0.1;                             
        player=SynchronizedPlaybackAcquirer;    % initializing I-O via soundcard
        [fs,impulse_response,irtime,tf,faxis]=IRmeas_fft_womics(ts,tw,flower,fupper,playgain,player);
        t_axis = irtime;
        t_result = impulse_response;
        f_axis = faxis;
        f_result = tf;
       
    case 'transfer'
        [faxis, transfer_function, irtime, impulse_response] = Tranfer_function(gain);
        f_axis = faxis;
        f_result = transfer_function;
        t_axis = irtime;
        t_result = impulse_response;
end