



%% 
 clear   
 
 load('res_n5.mat');
 mic_n5 = reshape(res_avg,[3,9]);

 load('resultat_n5.mat');
 resultat_n5 = [-100 -100 -100 -100 -100 -100 -100 -100 -100 -100 -100 -100 -100 -100 -100 -100 -100 -100 -100 -100 result(:,14)' result(:,17)' result(:,20)' result(:,23)' result(:,26)'];
 
 
 load('res_n1.mat');
 mic_n1 = reshape(res_avg,[3,9]);

  load('resultat_n1.mat');
 resultat_n1 = [-100 -100 -100 -100 -100 -100 -100 -100 -100 -100 -100 -100 result(:,14)' result(:,17)' result(:,20)' result(:,23)' result(:,26)'];
 
 load('res_p5.mat');
 mic_p5 = reshape(res_avg,[3,9]);

%% 
freq = [1 2 3 4 5 6 7 8 9];
%figure(1)
mic_no = 2  % 1 = back, 2 = center, 3 = front;
% bar(freq,mic_n5(mic_no,:))
% hold on
% bar(freq,mic_n1(mic_no,:))
% bar(freq,mic_p5(mic_no,:))
% grid on
%     set(gca,'Ytick',25:1:60)
%     set(gca,'xtick',1:1:9)
%     ylabel('Level [dB]')
%     xlabel('Octave [Hz]')
%     xticklabels({'63','125','250','500','1k','2k','4k','8k','16k'})
% alpha(.5)

figure(2)
plot(freq,mic_n5(mic_no,:))
hold on
plot(freq,mic_n1(mic_no,:))
%plot(freq,mic_p5(mic_no,:))
grid on




figure(2)
freq = [1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 8 8 8 9 9 9];
boxplot(resultat_n1,freq) 

freq = [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4 5 5 5 5 5 6 6 6 6 6 7 7 7 7 7 8 8 8 8 8 9 9 9 9 9];
boxplot(resultat_n5,freq) 

    set(gca,'Ytick',25:1:65)
    set(gca,'xtick',1:1:9)
    ylabel('Level [dB]')
    xlabel('Octave [Hz]')
    xticklabels({'63','125','250','500','1k','2k','4k','8k','16k'})
axis([0 10 25 65])

