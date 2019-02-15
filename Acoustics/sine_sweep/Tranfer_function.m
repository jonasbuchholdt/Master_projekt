function [faxis, transfer_function, irtime, impulse_response] = Tranfer_function(gain)
%%
flower= 20;                             % lower frequency border for sweep      [Hz]
fupper=22000;                           % upper frequency border for sweep      [Hz]
ts= 1;                                  % length of sweep                        [s]
tw= 1;                                  % est. length of IR                      [s]
playgain=gain;                            % gain for sweep playback               [dB]


incal=0.1;                              % Input Calibration: What digital
                                        % RMS value corresponds to 1 Pa at
                                        % the microphone membrane?
                                        % 
outcal=0.1;                             % Output Calibration: What digital
                                        % RMS value corresponds to a
                                        % voltage of 1 Volt over the
                                        % speaker?
                                       

player=SynchronizedPlaybackAcquirer;    % initializing I-O via soundcard
[fs,impulse_response,irtime,tf,faxis]=IRmeas_fft(ts,tw,flower,fupper,playgain,player);
load('calibration.mat');
transfer_function = tf./calibration.preamp_transfer_function;
end

