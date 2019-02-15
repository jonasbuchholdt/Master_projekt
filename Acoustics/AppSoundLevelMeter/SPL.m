function [data_dBSPLW wseg1_mean_SPL]=SPL(Aux_s)

%%This function estimates SPL and performs SPL Frequency Weighting,SPL Time Weighting and SPL
%%Windowing in Record Mode

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

signal_ref=Aux_s.Calibration.Signal_Calibration;
p_ref=Aux_s.Calibration.Pressure_ref;
p_94dBSPL=Aux_s.Calibration.p_pascal_ref;

filt_coef = Aux_s.Signal.Filter_coefficients;


n_samples=Aux_s.Signal.n_samples;
w_shift=Aux_s.Signal.w_shift;

signal_ref_mean=mean(abs(signal_ref));
signal=Aux_s.Signal.Recorded;

%% SPL Frequency Weighting

if strcmp(Aux_s.Signal.Frequency_weighting.SPL,'A')
    
    %% A Weighting
    A_weighted_signal=filter(filt_coef.Afilter,signal);
    signal=A_weighted_signal;
    
elseif strcmp(Aux_s.Signal.Frequency_weighting.SPL,'C')
    
    %% C Weighting
    C_weighted_signal=filter(filt_coef.Cfilter,signal);
    signal=C_weighted_signal;
    
elseif strcmp(Aux_s.Signal.Frequency_weighting.SPL,'none')
    signal=signal;

end

%%

%%Time Weighting: Fast/Slow/none

data_p_squared=signal.^2;

%Filtro paso bajo con polo real -1/t : t = (fast,slow)
if strcmp(Aux_s.Signal.Time_weighting,'Fast')

%Digital integrator
max_signal=mean(data_p_squared); 

[b a]=bilinear(1,[1 1/0.125],Aux_s.Signal.Fs);
yf=filter(b,a,data_p_squared);
maxyf=mean(yf);
difyf=max_signal/maxyf;
data_p_f_squared=difyf*yf;
data_p_f_squared_root=sqrt(data_p_f_squared(1:(length(signal)-1)));



elseif strcmp(Aux_s.Signal.Time_weighting,'Slow')

%Digital integrator
max_signal=mean(data_p_squared); 

[b a]=bilinear(1,[1 1/1],Aux_s.Signal.Fs);
ys=filter(b,a,data_p_squared);
maxys=mean(ys);
difys=max_signal/maxys;
data_p_f_squared=difys*ys;
data_p_f_squared_root=sqrt(data_p_f_squared(1:(length(signal)-1)));



elseif strcmp(Aux_s.Signal.Time_weighting,'none')
    data_p_f_squared_root=signal;
end


%%

% SPL Windowing

signal_reshape=reshape(data_p_f_squared_root,1,length(data_p_f_squared_root));

number_of_frames=floor(length(signal_reshape)/(w_shift));

wseg1_mean_SPL=zeros(number_of_frames-1,1);
for i=1:number_of_frames-1
   if i==1
        seg1=signal_reshape(1:n_samples);
    else
        seg1=signal_reshape((w_shift*(i-1)):(w_shift*(i-1)+n_samples));
   end

wseg1=seg1;
    
    
    wseg1_mean_SPL(i)=mean(abs(wseg1));

end

signal_p=((wseg1_mean_SPL/signal_ref_mean)*p_94dBSPL);


%%SPL

data_dBSPLW=(20*log10(signal_p/p_ref));

%%