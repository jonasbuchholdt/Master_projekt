function [ir,irtime,y_rms]=IRmeas_fft_soundcard(ts,frequencyRange,gainlevel,offset,inputChannel,fs)

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
            L = 1024; %1024;
            fileReader = dsp.AudioFileReader('sweep.wav','SamplesPerFrame',L);
            fs = fileReader.SampleRate;
           
            aPR = audioPlayerRecorder('SampleRate',fs,...               % Sampling Freq.
                          'RecorderChannelMapping',inputChannel,...  % Input channel(s)
                          'PlayerChannelMapping',[2],... % Output channel(s)
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
            leng = length(dataOut);
            y = y(1:leng);                        
            y_rms = rms(y);
            
            dataOut_f =  fft(dataOut);
            y_f       =  fft(y); 
            
            irEstimate = real(ifft(y_f./dataOut_f));            
            irEstimate = circshift(irEstimate,offset);
            ir = irEstimate;
            irtime = [1:length(irEstimate)]./fs;
            
            
    end