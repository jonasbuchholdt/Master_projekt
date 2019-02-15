classdef SynchronizedPlaybackAcquirer < handle
    % SynchronizedPlaybackAcquirer 
    
    %   Copyright 2016 The MathWorks, Inc.
    
    properties
        SamplesPerFrame(1,1) ...
            {mustBeNumeric,mustBeInteger,mustBePositive} = 1024;
    end
    
    properties (SetAccess = protected)
        % These properties are read-only for now
        PlayerNumChannels = 3;
        RecorderNumChannels = 1;
    end
    
    properties (Dependent)
        Device;
        SampleRate;
        PlayerChannelMapping;
        RecorderChannelMapping;
    end
    
    properties (Hidden, SetAccess = protected)
        PlayerRecorder;
    end
    
    methods % Constructor and set/get methods for the dependent properties
        function this = SynchronizedPlaybackAcquirer
            this.PlayerRecorder = audioPlayerRecorder;
        end
        
        function set.Device(this,val)
            this.PlayerRecorder.Device = val;
        end
        function val = get.Device(this)
            val = this.PlayerRecorder.Device;
        end
        
        function set.SampleRate(this,val)
            this.PlayerRecorder.SampleRate = val;
        end
        function val = get.SampleRate(this)
            val = this.PlayerRecorder.SampleRate;
        end
        
        function set.PlayerChannelMapping(this,val)
            % PlayerChannelMapping can be empty or a vector whose length is
            % equal to the PlayerNumChannels property value
            if isempty(val)
                validateattributes(val,{'numeric'},{}, ...
                    'set.PlayerChannelMapping','PlayerChannelMapping');
            else
                validateattributes(val,{'numeric'}, ...
                    {'finite','real','vector','positive','numel',this.PlayerNumChannels}, ...
                    'set.PlayerChannelMapping','PlayerChannelMapping');
            end
            this.PlayerRecorder.PlayerChannelMapping = val;
        end
        function val = get.PlayerChannelMapping(this)
            val = this.PlayerRecorder.PlayerChannelMapping;
            if isempty(val)
                s = info(this.PlayerRecorder);
                val = min(1,s.MaximumPlayerChannels);
            end
        end
        
        function set.RecorderChannelMapping(this,val)
            % RecorderChannelMapping must be a positive numeric scalar
            validateattributes(val,{'numeric'}, ...
                {'finite','real','vector','positive','numel',this.RecorderNumChannels}, ...
                'set.RecorderChannelMapping','RecorderChannelMapping');
            this.PlayerRecorder.RecorderChannelMapping = val;
        end
        function val = get.RecorderChannelMapping(this)
            val = this.PlayerRecorder.RecorderChannelMapping;
            if isempty(val)
                s = info(this.PlayerRecorder);
                val = min(1,s.MaximumRecorderChannels);
            end
        end
    end
    
    methods % Public methods
        function devCell = getAudioDevices(this)
            devCell = getAudioDevices(this.PlayerRecorder);
        end
        
        function [playerMaxChans,recorderMaxChans] = getMaxChannels(this)
            s = info(this.PlayerRecorder);
            playerMaxChans = s.MaximumPlayerChannels;
            recorderMaxChans = s.MaximumRecorderChannels;
        end
        
        function deviceSettings = getDeviceSettings(this)
            deviceSettings = struct();
            s = info(this.PlayerRecorder);
            deviceSettings.Device = s.DeviceName;
            deviceSettings.PlayerChannelMapping = this.PlayerChannelMapping;
            deviceSettings.RecorderChannelMapping = this.RecorderChannelMapping;
            deviceSettings.SampleRate = this.SampleRate;
        end
        
        function [recordedAudio,nUnderruns,nOverruns] = playRecord(this,audioToBePlayed)
            % Play the input audio and record it
            
            % Cache object properties
            Fs = this.SampleRate;
            frameLength = this.SamplesPerFrame;
            playerNumChans = this.PlayerNumChannels;
            recorderNumChans = this.RecorderNumChannels;
            
            % Prepare audio data: Trim the channels, and zeropad to account
            % for (dataLength/frameLength) being not an integer
            [dataLength,inNumChannels] = size(audioToBePlayed);
            if (inNumChannels >= playerNumChans)
                audioToBePlayed = audioToBePlayed(:,1:playerNumChans);
            else
                dupChans = repmat(audioToBePlayed(:,end),1,(playerNumChans-inNumChannels));
                audioToBePlayed = [audioToBePlayed,dupChans];
            end
            numFrames = ceil(dataLength/frameLength);
            zeroPad = zeros(numFrames*frameLength-dataLength,playerNumChans,'like',audioToBePlayed);
            audioToBePlayed = [audioToBePlayed; zeroPad];
            
            % Initialize and warmup the device for 1 second to ensure no
            % samples dropped at the start
            syncAudioDevice = this.PlayerRecorder;
            zeroFrame = zeros(frameLength,playerNumChans,'like',audioToBePlayed);
            setup(syncAudioDevice,zeroFrame);
            for idx = 1:ceil(1*Fs/frameLength)
                syncAudioDevice(zeroFrame);
            end
            
            % Stream processing loop: Play and record all the input data
            recordedAudio = zeros(numFrames*frameLength,recorderNumChans);
            nUnderruns = zeros(numFrames,1);
            nOverruns = zeros(numFrames,1);
            for idx = 1:numFrames
                start = frameLength*(idx-1)+1;
                stop = frameLength*idx;
                [recordedAudio(start:stop,:), nUnderruns(idx), nOverruns(idx)] = ...
                    syncAudioDevice(audioToBePlayed(start:stop,:));
            end
            
            % Report loss of synchronization
            if nargout < 2 && nnz(nUnderruns) > 0
                fprintf('Audio output queue was underrun during %d frames.\n', nnz(nUnderruns));
            end
            if nargout < 3 && nnz(nOverruns) > 0
                fprintf('Audio input queue was overrun during %d frames.\n', nnz(nOverruns));
            end
            
            % Release the audio device
            release(syncAudioDevice);
        end
    end
end
