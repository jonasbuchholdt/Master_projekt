function [modfseg]=Windowing(signal,n_samples,w_shift,fft_size)

%%This function windows the signal and calculates the FFT signal of every segment.  

% Developed by Gabriel Brais Martinez Silvosa
% September, 2013

signal_reshape=reshape(signal,1,length(signal));
number_of_frames=floor(length(signal_reshape)/w_shift);
modfseg=0;


%%Windowing 
for i=2:number_of_frames-1
   if i==1
        seg1=signal(1:n_samples);
    else
        seg1=signal((w_shift*(i-1)/2):(w_shift*(i-1)/2 + n_samples));
   end


    wseg1=seg1;
 
    fseg1=fft(wseg1,fft_size);

                                     
    modfseg1=abs(fseg1(1:fft_size/2+1));
    
    modfseg1=(abs(modfseg1)).^2;
    modfseg=modfseg1 + modfseg;

    
end
modfseg=modfseg/fft_size;

