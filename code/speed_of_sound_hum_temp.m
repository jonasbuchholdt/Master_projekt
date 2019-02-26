%%
clear

humidity = [0 30 40 50 80 100];
temperature = [5 10 15 20 30 40];

data = [0.91 0.952 0.966 0.980 1.02 1.05
        1.81 1.87 1.89 1.91 1.97 2.01
        2.71 2.79 2.82 2.85 2.93 2.98
        3.60 3.71 3.75 3.79 3.90 3.98
        5.35 5.55 5.62 5.69 5.90 6.03
        7.07 7.43 7.54 7.66 8.03 8.27];
    
c_re = 331.45;

speed = (data/100)*c_re + c_re;



plot(temperature,speed(:,6))
hold on
plot(temperature,speed(:,5))
plot(temperature,speed(:,4))
plot(temperature,speed(:,3))
plot(temperature,speed(:,2))
plot(temperature,speed(:,1))


xlabel('Temperature [\si{\celsius}]')
ylabel('speed of sound [\si{\meter\per\second}]')

leg = legend('100%','80%','50%','40%','30%','0%','location','northwest');
title(leg,'Humidity')

%((4-3)/3)*100=p

%((4-3)/3)=(p/100)

%4=((p/100)*3)+3







