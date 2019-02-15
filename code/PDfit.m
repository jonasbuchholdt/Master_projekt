clearvars
close all


N = 100000;                                 % number of samples

x = [-5:0.1:5];

%samples = rand(1,N);
samples = randn(1,N);

my = mean(samples)
ssq= var(samples);

gaussian = (1/sqrt(2*pi*ssq))*exp(-((x-my).^2)/(2*ssq));

figure()
%histogram(samples, 25,'Normalization','probability')
histfit(samples)
%pd = fitdist(samples','Normal')
hold on
plot(x,gaussian)