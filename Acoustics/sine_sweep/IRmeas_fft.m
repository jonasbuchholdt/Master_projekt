function [fs,ir,irtime,tf,faxis]=IRmeas_fft(ts,tw,flower,fupper,gainlevel,player)
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
            fs = player.SampleRate;
            
            
            % Set up swept sine using chirp function
            t = 0:1/fs:ts - (1/fs);

            x = chirp(t,flower,ts,fupper,'logarithmic');
            
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
            
            y(:,1) = playRecord(player, dataOut);
            

            load('calibration.mat')
            
            
            y=y*(calibration.preamp_gain)/(calibration.mic_sensitivity);
            %y=y*(rms(y(7733:51840))/MICROPHONE_calibration);
            
            dataOut_f =fft(dataOut);
            y_f       =fft(y);
            
            irEstimate = real(ifft(y_f./dataOut_f));
            
            irEstimate = circshift(irEstimate,-3159);% rme= 3159 edirol=3295
            irEstimate=irEstimate;%*(1/MICROPHONE_calibration);
            
            ir = irEstimate;
            
            
            
            irtime = [1:length(irEstimate)]./fs;
            
            
            irEstimate_distortion_less = irEstimate(1:length(irEstimate)/2);
            
            
            
            % Calculate response for entire frequency range
            [freqResp,w] = freqz(irEstimate_distortion_less,1,22000,fs);
            
            % Convert complex filt response to magnitude dB.
            %tf = 20*log10(abs(freqResp));
            tf = freqResp;
            faxis = w;
            
    end