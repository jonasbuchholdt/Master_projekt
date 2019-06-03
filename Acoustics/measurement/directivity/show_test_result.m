% Four measurement is available, three with the plexiglass and one where 
% the plexiglas is removed. The measurement file is in this folder and the 
% number in the file name gives the directionality settings. The one with 
% without er without the plexiglass. Run this file and see the result. 
% To change the input file edit the name in load.


clear variables
%close all
down1 = 1;
down2 = 1; % 5
down3 = 1; %200
down4 = 1; %500

fs=44100;

ares=5;
astart=ares;
astop=360;

flower=40;
fupper=20000;

angles=[astart:ares:astop];

for h=1:(astop/ares)
    load('KUDO_direc_25_55.mat',(strcat('data',int2str((astart+(h-1)*ares)*10))));
    IR1s=eval(strcat('data',int2str((astart+(h-1)*ares)*10),'.ir(1:end/2)'));
    [tf,w]=freqz(IR1s,1,20000,fs);
    t_m = movmean(tf,1);
    tf1(:,h) = [downsample(t_m(1:91,:),down1); downsample(t_m(91+1:908,:),down2); downsample(t_m(908+1:9071,:),down3); downsample(t_m(9071+1:end,:),down4)];
    clearlist={strcat('data',int2str((astart+(h-1)*ares)*10))};
    clear(clearlist{:})
end
w = [downsample(w(1:91,:),down1); downsample(w(91+1:908,:),down2); downsample(w(908+1:9071,:),down3); downsample(w(9071+1:end,:),down4)];



%[discard index]=min(abs(w-f));
[trash iupper]=min(abs(w-fupper));
[trash ilower]=min(abs(w-flower));
clear trash
for k=[astart:ares:360]
    f_mat(:,(k/ares))=w(ilower:iupper);
end
tf1=tf1(ilower:iupper,:);

for k=1:size(tf1,1)
    p_mat(k,:)=abs(tf1(k,:))./max(abs(tf1(k,:)));
     for l=1:size(tf1,2)
         if p_mat(k,l)<=10^(-24/20)
             p_mat(k,l)=10^(-24/20);
         end
     end
end


p_mat(1,1)=10^(-24/20);
for k=1:size(tf1,1)
    phi_mat(:,(k))=angles;
end

phi_mat=phi_mat';
phi_mat=phi_mat(1:iupper-ilower+1,:);
p_mat=[p_mat(:,((length(angles)/2)+1):length(angles)) p_mat(:,1:length(angles)/2)];

p_mat= [p_mat(:,end) p_mat];
phi_mat = [zeros(size(p_mat,1),1) phi_mat];
f_mat = [f_mat(:,end) f_mat];


figure(3)
down1 = 1;
down2 = 1;
down3 = 1;
down4 = 1;
p_mat_db = 20*log10(movmean(p_mat,1));


x = phi_mat;%[downsample(phi_mat(1:55,:),down1); downsample(phi_mat(55+1:872,:),down2); downsample(phi_mat(872+1:1280,:),down3); downsample(phi_mat(1280+1:end,:),down4)];
y = f_mat;%[downsample(f_mat(1:55,:),down1); downsample(f_mat(55+1:872,:),down2); downsample(f_mat(872+1:1280,:),down3); downsample(f_mat(1280+1:end,:),down4)];
z = p_mat_db;%[downsample(p_mat_db(1:55,:),down1); downsample(p_mat_db(55+1:872,:),down2); downsample(p_mat_db(872+1:1280,:),down3); downsample(p_mat_db(1280+1:end,:),down4)];



[M,c]=contour(y,x,z,'LevelList',[-21:3:-0]);
hold on
set(gca, 'XScale', 'log')
colormap('jet(7)');
c=colorbar('XTickLabel',{'-60','-21','-18','-15','-12','-9','-6','-3','0'});
set(c, 'XTick',  linspace(-24, 0, 7+2));
c.Label.String='Deviation [dB]';
axis([flower fupper 360-180-100 180+100 -21 0]);
view(0,90)
ylabel('Angle [Deg]');
yticks([ 5 30 55 80 105 130 155 180 205 230 255 280 305 330 355])
yticklabels({'-175','-150','-125','-100','-75','-50','-25','0','25','50','75','100','125','150','175'})
xlabel('Frequency [Hz]');
zlabel('Deviation [dB]');
grid on
