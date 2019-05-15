

clear 

down1 = 1;
down2 = 1;
down3 = 1;
down4 = 1;

f = [20:1:20000]';

number = 6;

H_kudo = 0.356;
H_dis = 0.004;

H = H_kudo*number + (number-1)*H_dis;

limit = real((3/2).*f/1000.*H^2.*sqrt(1-(1./(3.*(f/1000).*H))));


limit_n = [downsample(limit(1:100),down1);    downsample(limit(100+1:1000),down2);    downsample(limit(1000+1:10000),down3);  downsample(limit(10000+1:end),down4) ];
f_n     = [downsample(f(1:100),down1);        downsample(f(100+1:1000),down2);        downsample(f(1000+1:10000),down3);      downsample(f(10000+1:end),down4) ];


semilogx(f_n,limit_n)
hold on
axis([20 20000 0 100])
grid on
xlabel('Frequency [Hz]')
ylabel('Distances [m]')
%%

legend({'6 KUDO (2.156 meter)','3 KUDO (1.076 meter)'},'Location','northwest')





%%

L1 = 100;


L2 = L1-abs(20*log10(40/50))

loss = abs(20*log10(50/60))


