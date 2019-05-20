



%% 
 clear   
 mic_no = 1  % 1 = back, 2 = center, 3 = front;
 load('res_n5.mat');
 mic_n5 = reshape(res_avg,[3,9]);

 load('resultat_n5.mat');
 resultat_n5 = [result(:,mic_no) result(:,mic_no+3) result(:,mic_no+6) result(:,mic_no+9) result(:,mic_no+12) result(:,mic_no+15) result(:,mic_no+18) result(:,mic_no+21) result(:,mic_no+24)];
 resultat_n5_rou = round(resultat_n5(:,2:end));
 resultat_n5_mean = mean(resultat_n5(:,2:end));
 resultat_n5_mean_rou = round(resultat_n5_mean);
 
 
 
 
 load('res_n1.mat');
 mic_n1 = reshape(res_avg,[3,9]);

  load('resultat_n1.mat');
 resultat_n1 = [result(:,mic_no) result(:,mic_no+3) result(:,mic_no+6) result(:,mic_no+9) result(:,mic_no+12) result(:,mic_no+15) result(:,mic_no+18) result(:,mic_no+21) result(:,mic_no+24)];
  resultat_n1_rou = round(resultat_n1(:,2:end));
  resultat_n1_mean = mean(resultat_n1(:,2:end));
  resultat_n1_mean_rou = round(resultat_n1_mean);

  res_mean = round(resultat_n5_mean-resultat_n1_mean,2);
  
 load('res_p5.mat');
 mic_p5 = reshape(res_avg,[3,9]);

 %%
 for i=1:length(resultat_n5)
 min_res_n5(i) = min(resultat_n5(:,i));
 end
 
 for i=1:length(resultat_n5)
 max_res_n5(i) = max(resultat_n5(:,i));
 end
 
  for i=1:length(resultat_n1)
 min_res_n1(i) = min(resultat_n1(:,i));
 end
 
 for i=1:length(resultat_n1)
 max_res_n1(i) = max(resultat_n1(:,i));
 end
 

freq = [1 2 3 4 5 6 7 8 9];
%figure(1)

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


x2 = [freq, fliplr(freq)];
inBetween = [max_res_n5, fliplr(min_res_n5)];
h = fill(x2, inBetween, 'b');
set(h,'facealpha',.2)
set(h,'EdgeColor','none')

x2 = [freq, fliplr(freq)];
inBetween = [max_res_n1, fliplr(min_res_n1)];
h = fill(x2, inBetween, 'r');
set(h,'facealpha',.2)
set(h,'EdgeColor','none')

    set(gca,'Ytick',25:1:68)
    set(gca,'xtick',1:1:9)
    ylabel('Level [dB]')
    xlabel('Octave [Hz]')
    xticklabels({'63','125','250','500','1k','2k','4k','8k','16k'})
axis([1 9 29 67])

legend('7 deg','3 deg')
%%


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

