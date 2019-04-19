function [ir,irtime,res]=IRmeas_fft(ts,frequencyRange,gainlevel,inputChannel,fs)

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
            dataOut(:,1) = [zeros(startSilence,1); x'; zeros(endSilence,1);zeros(506,1)];
            dataOut(:,2) = dataOut(:,1);
            

            % Perform capture
            %audiowrite("sweep.wav",dataOut,fs)
            %pause(1);
            L = 2048;
            fileReader = dsp.AudioFileReader('sweep.wav','SamplesPerFrame',L);
            fs = fileReader.SampleRate;
           
            aPR = audioPlayerRecorder('SampleRate',fs,...               % Sampling Freq.
                          'RecorderChannelMapping',inputChannel,...  % Input channel(s)
                          'PlayerChannelMapping',[1 2],... % Output channel(s)
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
            
            
            
            
            % convelution of signal
            input   = out(:,1);
            ref  = out(:,2)/(rms(out(:,2))/calibration.mic_sensitivity(1));            
            eps = 0.1; 
            L = numel(ref);
            W = hann(L); 
            uz1f = fft(W.*input,L); 
            uz2f = fft(W.*ref,L);
            ir = real(ifft((uz1f.*conj(uz2f))./(uz2f.*conj(uz2f)+eps*mean(uz2f.*conj(uz2f)))));           
            irtime = [1:length(ir)]./fs;           
         
            
            
    end