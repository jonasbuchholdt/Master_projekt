function [t_axis,t_result,res] = Lacoustics(cmd,gain,offset,inputChannel,frequencyRange,sweepTime,fs)


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
                    
            L = 2048; %1024;
            fileReader = dsp.AudioFileReader('sweep.wav','SamplesPerFrame',L);
            fs = fileReader.SampleRate;
           
            aPR = audioPlayerRecorder('SampleRate',fs,...               % Sampling Freq.
                          'RecorderChannelMapping',inputChannel,...  % Input channel(s)
                          'PlayerChannelMapping',[1],... % Output channel(s)
                          'SupportVariableSize',true,...    % Enable variable buffer size 
                          'BufferSize',L);                  % Set buffer size
    
                      
                      out = [];                      
                      while ~isDone(fileReader)
                          audioToPlay = fileReader();
                          [audioRecorded,nUnderruns,nOverruns] = aPR(audioToPlay);
                          out = [out; audioRecorded];
                          if nUnderruns > 0
                              fprintf('Audio player queue was underrun by %d samples.\n',nUnderruns);
                          end
                          if nOverruns > 0
                              fprintf('Audio recorder queue was overrun by %d samples.\n',nOverruns);
                          end
                      end
                      release(fileReader);
                      release(aPR);
                      y = out;
        for k = 1:length(inputChannel)
            add(k) = rms(y(:,k));          
            load('calibration.mat')
            calibration.mic_sensitivity(k) = add(k);
        end
        %calibration.mic_sensitivity = 0.0367; 
        save('calibration.mat','calibration','-append');        

     
     case 'test'                             
        [impulse_response,irtime]=IRmeas_fft_womics(sweepTime,frequencyRange,gain,offset,inputChannel,fs);
        t_axis = irtime;
        t_result = impulse_response;

       
    case 'transfer'                                                
        [impulse_response,irtime,res]=IRmeas_fft(sweepTime,frequencyRange,gain,offset,inputChannel,fs);
        t_axis = irtime;
        t_result = impulse_response;
end