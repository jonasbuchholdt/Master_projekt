
  function [modfseg,data_dBSPL,signal,data_Leq_T] = estL(signal,nfft,sampleRate,signal_ref,p_pascal_ref,FFT_Frequency_weighting,Time_weighting,n_samples,w_shift,fft_size,SPL_Frequency_weighting,Leq_Frequency_weighting,Filter_coef)

%%This function estimates FFT signal , SPL and Leq acoustic parameters in
%%Real-Time Mode

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013
  
persistent t1;
persistent Leq1;



  %%Calibration
  p_ref=2*10^(-5);

  signal_ref_mean=mean(abs(signal_ref));
  
%%

%Save data acquisition signal
  signal_acq= signal; 
    

%% FFT Frequency Weighting

if strcmp(FFT_Frequency_weighting,'A')

    
        %%Filtro Ponderacion A
    A_weighted_signal=filter(Filter_coef.Afilter,signal,1);
    signal=A_weighted_signal;
    
elseif strcmp(FFT_Frequency_weighting,'C')

    
    %%Filtro Ponderacion C
    C_weighted_signal=filter(Filter_coef.Cfilter,signal,1);
    signal=C_weighted_signal;
    
elseif strcmp(FFT_Frequency_weighting,'none')
    
    signal=signal;
    
end

%%

%%Sound pressure calibration
  signal=(((signal/signal_ref_mean)*p_pascal_ref));

%%Windowing
  modfseg=Windowing(signal,n_samples,w_shift,fft_size);
  
  
  
%% SPL Frequency Weighting
signal=signal_acq;

if strcmp(SPL_Frequency_weighting,'A')

    
        %%Filtro Ponderacion A
    A_weighted_signal=filter(Filter_coef.Afilter,signal,1);
    signal=A_weighted_signal;
    
elseif strcmp(SPL_Frequency_weighting,'C')

    
    %%Filtro Ponderacion C
    C_weighted_signal=filter(Filter_coef.Cfilter,signal,1);
    signal=C_weighted_signal;
    
elseif strcmp(SPL_Frequency_weighting,'none')
    
    signal=signal_acq;
    
end

    
%%Ponderacion temporal Fast/Slow
data_p_squared=signal.^2;
max_signal=mean(data_p_squared);

if strcmp(Time_weighting,'Fast')
    
%Digital integrator

[b a]=bilinear(1,[1 1/0.125],sampleRate);
yf=filter(b,a,data_p_squared);
maxyf=mean(yf);
difyf=max_signal/maxyf;
data_p_f_squared=sqrt(yf*difyf);
%
    
elseif strcmp(Time_weighting,'Slow')
    
%Digital integrator

[b a]=bilinear(1,[1 1/1],sampleRate);
ys=filter(b,a,data_p_squared);
maxys=mean(ys);
difys=max_signal/maxys;
data_p_f_squared=sqrt(ys*difys);
%
    
elseif strcmp(Time_weighting,'none')
    
    data_p_f_squared=signal;
    
end

data_p_f_squared_root=(data_p_f_squared(1:(length(signal))));


%%

    
%%Windowing
    

signal_reshape=reshape(data_p_f_squared_root,1,length(data_p_f_squared_root));

number_of_frames=floor(length(signal_reshape)/w_shift);

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
%%


  wseg1_mean_SPL=(((wseg1_mean_SPL/signal_ref_mean)*p_pascal_ref));

%%SPL

data_dBSPL=(20*log10(mean(abs(wseg1_mean_SPL))/p_ref));

%%


%% Leq Frequency Weighting
signal=signal_acq;

if strcmp(Leq_Frequency_weighting,'A')

    
        %%Filtro Ponderacion A
    A_weighted_signal=filter(Filter_coef.Afilter,signal,1);
    signal=A_weighted_signal;
    
% elseif strcmp(Leq_Frequency_weighting,'C')
% 
%     
%     %%Filtro Ponderacion C
%     C_weighted_signal=filter(Filter_coef.Cfilter,signal,1);
%     signal=C_weighted_signal;
    
elseif strcmp(Leq_Frequency_weighting,'none')
    
    signal=signal_acq;
    
end
%%

%%Windowing
    

signal_reshape=reshape(signal,1,length(signal));

number_of_frames=floor(length(signal_reshape)/w_shift);

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

  wseg1_mean_Leq=(((wseg1_mean_Leq/signal_ref_mean)*p_pascal_ref));


%%

%%Leq

wseg1_mean_Leq_mean=mean(wseg1_mean_Leq);
data_Leq_mean=20*log10(wseg1_mean_Leq_mean/p_ref);
refreshRate=nfft/sampleRate;

if (length(signal_acq)==nfft)
    
if isempty(Leq1)

    Leq1 = refreshRate * (10^(data_Leq_mean/10));
else

    Leq1 = Leq1 + refreshRate * (10^(data_Leq_mean/10));

end

if isempty(t1)

  t1=1;
else

  t1=t1+1;
end
data_Leq_T=(10*log10(Leq1/(t1*refreshRate)));

else
    data_Leq_T=0;
end
%%Return data acquisition signal
signal=signal_acq;

%%
