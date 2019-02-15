%%%%%%%%%%%%%%%%%%%%%%%%
%% Configuration File %%
%%%%%%%%%%%%%%%%%%%%%%%%

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

% This file is to set up the acquisition and plotting options 

%Device: 
    %CEntrance + NTi Audio --> 0
    %Art + Behringer       --> 1

s.Signal.device=0;


%Calibration: yes=1 / no=0

s.Calibration.calibrate=0;


%Mode: 'record'/'realtime'

s.Signal.mode='realtime';

%if record: 

    %duration: 5/15/30 s

    s.Signal.duration=5;

    % 'octave'/'third_octave'/'twelve_octave'  [63 Hz - 1KHz](3) [1 KHz - 16 KHz](12)
    
    s.Signal.octave_analysis='third_octave';
    
    % Octave Frequency Weighting: 'A'/'C'/'none'
    
    s.Signal.Frequency_weighting.Octave='none';
    

% FFT Frequency Weighting: 'A'/'C'/'none'

s.Signal.Frequency_weighting.FFT='A';

% FFT Settings: 2048/4096/8192

s.Signal.fft_size=2048;    



% SPL Frequency Weighting: 'A'/'C'/'none'

s.Signal.Frequency_weighting.SPL='A';


% SPL Time Weighting: 'Fast'/'Slow'/'none'

s.Signal.Time_weighting='Fast';


% Leq Frequency Weighting: 'A'/'none'

s.Signal.Frequency_weighting.Leq='A';

