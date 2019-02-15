function [data_Leq_T]=Leq(Aux_s,signal)

%%This function estimates Leq and performs Leq Frequency Weighting and Leq
%%Windowing in Record Mode

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

signal_ref=Aux_s.Calibration.Signal_Calibration;
p_ref=Aux_s.Calibration.Pressure_ref;
p_94dBSPL=Aux_s.Calibration.p_pascal_ref;

n_samples=Aux_s.Signal.n_samples;
w_shift=Aux_s.Signal.w_shift;
Aux_s.Signal.Time_seconds;

signal_ref_mean=mean(abs(signal_ref));

%% Leq Windowing

signal_reshape=reshape(signal,1,length(signal));

number_of_frames=floor(length(signal_reshape)/(w_shift));



wseg1_mean_Leq=zeros(number_of_frames-1,1);
for i=1:number_of_frames-1
   if i==1
        seg1=signal_reshape(1:n_samples);
    else
        seg1=signal_reshape((w_shift*(i-1)):(w_shift*(i-1)+n_samples));
   end

    wseg1=seg1;
   
    wseg1_mean_Leq(i)=mean(abs(wseg1));
end

%%
signal_p=((wseg1_mean_Leq/signal_ref_mean)*p_94dBSPL);



%%Leq

ti=n_samples/Aux_s.Signal.Fs;

Leq_matrix=zeros(length(signal_p),2);
data_Leq=20*log10(signal_p/p_ref);

for q=1:length(Leq_matrix)
    Leq_matrix(q,1)=data_Leq(q);
    Leq_matrix(q,2)=ti; 
end


Leq_sum=0;
for q=1:length(Leq_matrix)
   Leq_sum=Leq_sum + (Leq_matrix(q,2)*(10^(Leq_matrix(q,1)/10)));
    
end

data_Leq_T=10*log10(Leq_sum/Aux_s.Signal.Time_seconds);

%%