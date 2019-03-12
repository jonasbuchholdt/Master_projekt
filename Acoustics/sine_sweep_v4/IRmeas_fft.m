function [ir,irtime,res]=IRmeas_fft(ts,frequencyRange,gainlevel,offset,inputChannel,fs)

                        res = 0;
            gainLin = db2mag(gainlevel);
            t = 0:1/fs:ts - (1/fs);
            x = chirp(t,frequencyRange(1),ts,frequencyRange(2),'logarithmic');
            x = gainLin * x;            
            fadeInTime = 0.08;
            fadeInSamps = ceil(fadeInTime * fs); % number of samples over which to fade in/out
            
            % Calculate fadeIn/fadeOut vectors
            t1 = 0:1/fadeInSamps:1-(1/fadeInSamps);
            fadeIn = sin(1/2*pi*t1);
            
            fadeOutTime = 0.01;
            fadeOutSamps = ceil(fadeOutTime * fs); % number of samples over which to fade in/out
            t2 = (1-(1/fadeOutSamps):-(1/fadeOutSamps):0);
            fadeOut = sin(1/2*pi*t2);
            
            % Apply fade vectors
            x(1:fadeInSamps) = x(1:fadeInSamps) .* fadeIn;
            x(end-fadeOutSamps+1:end) = x(end-fadeOutSamps+1:end) .* fadeOut;
            
            % In practice, it is necessary to add silence to the end of the chirp to
            % ensure we don't lose the tail of the impulse response
            % We'll also add some to the start to account for latency
            startSilence = ceil(fs/10);
            endSilence = 2*fs;
            dataOut = [zeros(startSilence,1); x'; zeros(endSilence,1);zeros(506,1)];
            

            % Perform capture
            audiowrite("sweep.wav",dataOut,fs)
            L = 2048;
            fileReader = dsp.AudioFileReader('sweep.wav','SamplesPerFrame',L);
            fs = fileReader.SampleRate;
           
            aPR = audioPlayerRecorder('SampleRate',fs,...               % Sampling Freq.
                          'RecorderChannelMapping',inputChannel,...  % Input channel(s)
                          'PlayerChannelMapping',1,... % Output channel(s)
                          'SupportVariableSize',true,...    % Enable variable buffer size 
                          'BufferSize',L);                  % Set buffer size
    
                      
                      out = [];                      
                      while ~isDone(fileReader)
                          audioToPlay = fileReader();
                          [audioRecorded,nUnderruns,nOverruns] = aPR(audioToPlay);
                          out = [out; audioRecorded];
                          if nUnderruns > 0
                              fprintf('Audio player queue was underrun by %d samples.\n',nUnderruns);                                
                                res = 1;
                          end
                          if nOverruns > 0
                              fprintf('Audio recorder queue was overrun by %d samples.\n',nOverruns);
                                res = 1;
                          end
                      end
                      release(fileReader);
                      release(aPR);
                      
            load('calibration.mat')
            
         for k = 1:length(inputChannel)
            y = out(:,k);
            y=y*(calibration.preamp_gain)/(calibration.mic_sensitivity(k));
            y=y(1:length(dataOut));
            
            dataOut_f =fft(dataOut);
            y_f       =fft(y);
            
            irEstimate = real(ifft(y_f./dataOut_f));            
            irEstimate = circshift(irEstimate,offset);          
            ir(:,k) = irEstimate; 
            irtime = [1:length(irEstimate)]./fs;           
         end
            
            
    end