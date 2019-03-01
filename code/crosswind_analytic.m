
clear 

ang = [1:1:180];
a = deg2rad(ang)';

A = 0.01;
M = [0.08];
r = 1;
k =(2*pi*10000)/343;

for b=1:1:180
p_m(b)=(A*(sqrt(1-M^2*sin(a(b))^2)-M*cos(a(b))))/(sqrt(2*pi*k*r)*(1-M^2)*(1-M^2*sin(a(b))^2)^(3/4))...
    *exp((1i*(sqrt(1-M^2*sin(a(b))^2)-M*cos(a(b)))*k*r)/(1-M^2)+(1i*pi)/(4));
end

M = 0;
r = 1;

for b=1:1:180
p_r(b)=(A*(sqrt(1-M^2*sin(a(b))^2)-M*cos(a(b))))/(sqrt(2*pi*k*r)*(1-M^2)*(1-M^2*sin(a(b))^2)^(3/4))...
    *exp((1i*(sqrt(1-M^2*sin(a(b))^2)-M*cos(a(b)))*k*r)/(1-M^2)+(1i*pi)/(4));
end
P = abs(p_m)./abs(p_r);

plot(P)
hold on