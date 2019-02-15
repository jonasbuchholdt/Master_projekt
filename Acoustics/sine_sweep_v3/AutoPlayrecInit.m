function AutoPlayrecInit(fs)

%% Platform independent initialization of Playrec
% AUTOPLAYRECINIT(FS) automatically initialise playrec, if no
% input arguments is given, the default sampling frequency is 48kHz.

%% change the following path to your Playrec path
%addpath /Users/rop/Documents/MATLAB/playrec-master/
%addpath /Users/rop/Documents/MATLAB/playrec/
%%
if nargin<1; fs = 48e3; end

if playrec('isInitialised') == 0

    H = playrec('getDevices');

%    SC = 'QUAD-CAPTURE';
    SC = 'Fireface';
%    SC = 'UA-25';
%     SC = 'Realtek ASIO';
%    SC = 'ASIO MADIface USB';
    for i = 1:1:size(H,2)
        if  size(H(i).name,2) > 6 
            if  strcmp(H(i).name(1:length(SC)),SC) == 1 
                OutDevID = i-1;
                InDevID = i-1;
                break;
            end
        end
    end

    if  exist('OutDevID')
        playrec('init',fs,OutDevID,InDevID,12,12);%,480,100e-3,100e-3)
        fprintf('\n Sound Card: %s is initialized\n',SC)
    else
        fprintf('\n Sound Card: %s is not connected to the computern',SC)
    end

else
    fprintf('\n Sound Card is already initialized\n')
end
end



