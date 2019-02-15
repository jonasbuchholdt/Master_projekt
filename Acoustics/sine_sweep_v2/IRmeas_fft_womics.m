function [fs,ir,irtime]=IRmeas_fft_soundcard(ts,frequencyRange,gainlevel,offset,inputChannel)
            % out:  ir          - impulse response      [vector, lin]
            %       irtime      - time axis for IR        [vector, s]
            %       tf          - transfer function      [vector, dB]
            %       faxis       - frequency axis for tf  [vector, Hz]
            %
            % in:   ts          - sweep duration                  [s]
            %       tw          - waiting time                    [s]
            %       gainlevel   - output level (0,...,-inf)      [dB]
            %       flower      - lower frequency border         [Hz]
            %       fupper      - upper frequency border         [Hz]
            %       player      - record/play object from main program
            %
            % Function for capturing an impulse response using sine sweep methodology
            % References:
            % 1. "Comparison of Different Impulse Response Measurement Techniques" -
            % Stan Guy-Bart, Embrechts Jean-Jacques, Achambeau Dominique
            % http://www.montefiore.ulg.ac.be/~stan/ArticleJAES.pdf
            % 2. "Advancement in Impulse Response Measurements By Sine Sweeps" -
            % Angelo Farina. AES Paper.
            % 3. "A Method of Measuring Low-Noise
            % Acoustical Impulse Responses at0
            % High Sampling Rates"
            % https://www.princeton.edu/3D3A/Publications/Tylka_AES137_IRMeasurements-slides.pdf
            %%
            % properties
            gainLin = db2mag(gainlevel);
            %IRDuration = this.MinIRDuration;
            %this.ActualIRDuration = IRDuration;
            %fs = player.SampleRate;
            fs = 44100;
            
            % Set up swept sine using chirp function
            t = 0:1/fs:ts - (1/fs);

            x = chirp(t,frequencyRange(1),ts,frequencyRange(2),'logarithmic');
            
            % apply gain scaling to form test signal x
            x = gainLin * x;
            
            % Add exponential/sin attenuation to the beginning and end of the excitation
            % signal in order to minimize the influence of transients.
            
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
            L = 1024;
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
                          end
                          if nOverruns > 0
                              fprintf('Audio recorder queue was overrun by %d samples.\n',nOverruns);
                          end
                      end
                      release(fileReader);
                      release(aPR);
            
            
      
            
         for k = 1:length(inputChannel)
            y = out(:,k);
            y=y(1:length(dataOut));
            
            dataOut_f =fft(dataOut);
            y_f       =fft(y);
            
            irEstimate = real(ifft(y_f./dataOut_f));            
            irEstimate = circshift(irEstimate,offset);         
            ir(:,k) = irEstimate;                        
            irtime = [1:length(irEstimate)]./fs;           
         end
 
            
    end