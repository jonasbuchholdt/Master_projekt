function [fs,y]=irmeas_fft_mic()

            % generate a x vector with 0
            ts= 1;
            player=SynchronizedPlaybackAcquirer; 
            fs = player.SampleRate;           
            t = 0:1/fs:ts - (1/fs);
            x = zeros(1,length(t));
      
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
                  
    end