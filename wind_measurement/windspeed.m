

%wind_m = movmean([wind31; wind32],20);

%still_m = movmean([still31; still32],20);

wind = movmean(LOG00031,2);
x = [1:1:length(wind)]/10;

plot(x,wind)
hold on
grid on
xlabel('Time [s]')
ylabel('wind speed [m/s]')

axis([0 70 0 12])
yticks(0:1:15);


%%

% 25 -150
% 26 -270
% 24 -330
% 28 ...

direction = movmean(LOG00030,1)-305;

for i=1:length(direction)
    if direction(i) < 0
        direction(i) = 360 + direction(i);
    end
end

direction = movmean(direction,2);

x = [1:1:length(direction)]/10;

plot(x,direction)
grid on
xlabel('Time [s]')
ylabel('direction [deg]')

axis([0 62 0 360])
yticks(0:20:360);
xticks(0:5:80);






