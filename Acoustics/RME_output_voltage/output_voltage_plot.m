
clear all
load('digital_number_at_zero_db.mat')

filename = 'rme_output_voltage.csv';
delimiterIn = ',';
headerlinesIn = 6;
output_voltage = importdata(filename,delimiterIn,headerlinesIn);

output = [output_voltage.data(:,2)];

rme_output = rme_output(44100+598:44100*1.5);

time_digital = [1:length(rme_output)]./44100;

time_voltage = [1:length(output)]./((15986)/(2*10)*1000);

yyaxis left
plot(time_voltage,output) %
axis([0 0.004 -5 5])
ylabel('Amplitude [V]')

yyaxis right
plot(time_digital,rme_output) %
axis([0 0.004 -5 5])
ylabel('Digital value [1]')
hold on
grid on

%yyaxis right
%ylabel('Right Side')

xlabel('Time [s]')



