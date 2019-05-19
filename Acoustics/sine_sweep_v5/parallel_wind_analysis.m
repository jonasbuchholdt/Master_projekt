



%%


back   = [40 37 40 39 29; 47 46 46 44 33; 49 46 50 48 37];
center = [1];
fronnt = [1];
freq = [1 2 4 8 16]
figure(1)
bar(freq,back(3,:))
hold on
bar(freq,back(2,:))
bar(freq,back(1,:))

figure(2)
plot(freq,back(3,:))
hold on
plot(freq,back(2,:))
plot(freq,back(1,:))