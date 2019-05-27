
clear 

f = [1:1:20000];

sp = 343; %m

meter = 1;




wave_length_extension_factor = (meter*f)./sp;



%172 515 858 1201

%%
t = [0:1:90];
f = 90*4;
p = sin(2*pi*t/f);
x = [0:1:90];
plot(x,p)
grid on

%%


angle = 2
t = 25;
f = 90*4;
p = sin(2*pi*(t-angle)/f);









