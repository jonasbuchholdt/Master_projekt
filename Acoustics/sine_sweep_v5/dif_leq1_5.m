



p = ((sig(:,1))*(rms(sig(:,1))/(rms(sig(:,1)))));


sig_f = fft(sig(:,1));
ref_f = fft(p);

fre = sig_f./ref_f;

imp = real(ifft(fre));
plot(imp)

[tf,w] = freqz(imp,1,22000,44100);
f_axis =w;
result_d=(20*log10(abs(tf/(20*10^-6))));

semilogx(w,result_d)

l_Aeq(1) = 10*log10(((1/(1))*sum(imp.^2))/(20*10^-6).^2)

l_Aeq(2) = 10*log10(((1/(5))*sum(imp.^2))/(20*10^-6).^2)