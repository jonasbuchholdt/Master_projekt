

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

%%



point_source = abs(20*log10(30/0.001))

mic = abs(20*log10(30/1))


res = mic -point_source


%%

for i=1:length(limit)
    if limit(i) >40
       limit_ed(i) =40;
    end
    if limit(i) <40
        limit_ed(i)=limit(i);
    end
    %if limit(i) <1
    %    limit_ed(i)=1;
    %end
end

near = limit_ed;
far = 40-limit_ed;

near_1m = (1);
near_surface = (near+1);
far_surface  = (near_surface.*(2).^(far/3));

area_diff = far_surface/near_1m;


mic_db = -10*log10(area_diff);
semilogx(f,mic_db)
axis([20 20000 -50 -10])
%%
abs(20*log10(40/1))



%%





near_1m = 1;
near_surface = 4;
far_surface  = (4.*2.^2)

%%

near_1m = 1;
near_surface = 2+1;
far_surface  = near_surface*((2)^(1.5))




%%


clear

dis = 60;

f = [20:1:20000]';

number = 6;

H_kudo = 0.356;
H_dis = 0.004;

H = H_kudo*number + (number-1)*H_dis;

limit = real((3/2).*f/1000.*H^2.*sqrt(1-(1./(3.*(f/1000).*H))));

for i=1:length(limit)
    if limit(i) >dis
       limit_ed(i) =dis;
    end
    if limit(i) <dis
        limit_ed(i)=limit(i);
    end
    if limit(i) <0.5
        limit_ed(i)=0.5;
    end
end


for i = 1:length(limit_ed)
   %limit=8; 
areal = (limit_ed(i)/2);
area = areal*2^2;

a = [area area*2 area*4 area*8 area*16];
b = [area area*4 area*4*4 area*4*4*4 area*4*4*4*4];

p = polyfit(a,b,3);
x1 = linspace(8,64);
y1 = polyval(p,x1);

result = find(x1>dis);

area_diff = y1(result(1))/0.5;
mic_db(i) = -10*log10(area_diff);
end


%plot(a,b)
%hold on
%plot(x1,y1)
%axis([0 70 0 1200])

semilogx(f,mic_db)
hold on
axis([20 20000 -50 -10])












