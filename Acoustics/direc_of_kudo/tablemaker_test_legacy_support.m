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
    t_m = movmean(tf,100);
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
         if p_mat(k,l)<=10^(-21/20)
             p_mat(k,l)=10^(-21/20);
         end
     end
end


p_mat(1,1)=10^(-21/20);
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
p_mat_db = 20*log10(movmean(p_mat,2));


x = phi_mat;%[downsample(phi_mat(1:55,:),down1); downsample(phi_mat(55+1:872,:),down2); downsample(phi_mat(872+1:1280,:),down3); downsample(phi_mat(1280+1:end,:),down4)];
y = f_mat;%[downsample(f_mat(1:55,:),down1); downsample(f_mat(55+1:872,:),down2); downsample(f_mat(872+1:1280,:),down3); downsample(f_mat(1280+1:end,:),down4)];
z = p_mat_db;%[downsample(p_mat_db(1:55,:),down1); downsample(p_mat_db(55+1:872,:),down2); downsample(p_mat_db(872+1:1280,:),down3); downsample(p_mat_db(1280+1:end,:),down4)];


%x = [movmean(x(1:56,:),down1); movmean(x(56+1:round(872/down2),:),down2+3); movmean(x(round(872/down2)+1:round(9035/down3),:),down3); movmean(x(round(9035/down3)+1:end,:),down4)];
%y = [movmean(y(1:56,:),down1); movmean(y(56+1:round(872/down2),:),down2+3); movmean(y(round(872/down2)+1:round(9035/down3),:),down3); movmean(y(round(9035/down3)+1:end,:),down4)];
%z = [movmean(z(1:56,:),down1); movmean(z(56+1:round(872/down2),:),down2+3); movmean(z(round(872/down2)+1:round(9035/down3),:),down3); movmean(z(round(9035/down3)+1:end,:),down4)];



s=contourf(y,x,z,'LineStyle','none','LevelList',[-24:3:0]);

%[M,c]=contour(y,x,z,'LevelList',[-21:3:-3]);
%s=surf(y(:,17:end-16),x(:,17:end-16),z(:,17:end-16));
%s.EdgeColor = 'interp';
%c.LineWidth = 3;
hold on

set(gca, 'XScale', 'log')
colormap('jet(7)');
c=colorbar;



set(c, 'XTick',  linspace(-21, 0, 7+1));
%c.TickLabels({'-3','-6','-9','-12','-15','-18','-21','-60'});
c.Label.String='Deviation [dB]';
axis([flower fupper 360-180-100 180+100 -21 0]);
view(0,90)
%refline(s,[50*ones(1,length(f_mat(:,1)))' f_mat(:,1) 0*ones(1,length(f_mat(:,1)))])
%line(50,f_mat,100)

%plot([180,180],[40,20000],'k','LineWidth', 2)
%plot([180-50,180-50],[40,20000],'k','LineWidth', 2)


ylabel('Angle [Deg]');
%xticks([0 60 120 180 240 300 360])
%xticklabels({'-180','-120','-60','0','60','120','180'})
yticks([ 5 30 55 80 105 130 155 180 205 230 255 280 305 330 355])
yticklabels({'-175','-150','-125','-100','-75','-50','-25','0','25','50','75','100','125','150','175'})
xlabel('Frequency [Hz]');
zlabel('Deviation [dB]');

grid on

%%

[Y,Z]=meshgrid(y,z);
%%
data = [ X(:) Y(:) Z(:) ]
% or -ascii
save P.dat data -ASCII
size(X)

%%
s=contourf(x,y,z,'LineStyle','none','LevelList',[-24:3:0]);
hold on
set(gca, 'YScale', 'log')
colormap('jet(7)');
c=colorbar('XTickLabel',{'-60','-21','-18','-15','-12','-9','-6','-3','0'});

c.Ruler.TickLabelFormat='%g%%'

set(c, 'YTick',  linspace(-24, 0, 7+2));
%c.TickLabels({'-3','-6','-9','-12','-15','-18','-21','-60'});
c.Label.String='Deviation [dB]';
axis([0 360 flower fupper -24 0]);
view(90,90)
%refline(s,[50*ones(1,length(f_mat(:,1)))' f_mat(:,1) 0*ones(1,length(f_mat(:,1)))])
%line(50,f_mat,100)

%plot([180,180],[40,20000],'k','LineWidth', 2)
%plot([180-50,180-50],[40,20000],'k','LineWidth', 2)


xlabel('Angle [Deg]');
%xticks([0 60 120 180 240 300 360])
%xticklabels({'-180','-120','-60','0','60','120','180'})
xticks([ 5 30 55 80 105 130 155 180 205 230 255 280 305 330 355])
xticklabels({'-175','-150','-125','-100','-75','-50','-25','0','25','50','75','100','125','150','175'})
ylabel('Frequency [Hz]');
zlabel('Deviation [dB]');

%%
hA1 = subplot(1,1,1);
s=contourf(phi_mat,f_mat,20*log10(p_mat),'LineStyle','none','LevelList',[-36:3:0]);
%set(hA1,'yscale','log');
colormap('jet(12)');
c=colorbar;
set(c, 'YTick', linspace(-36, 0, 13));
c.Label.String='Deviation [dB]';
axis([0 360 flower fupper -7 1]);
xlabel('Angle [Deg]');
xticks([0 60 120 180 240 300 360])
xticklabels({'-180','-120','-60','0','60','120','180'})
ylabel('Frequency [Hz]');
zlabel('Deviation [dB]');
%pbaspect([1 2 1])
%set(s, 'EdgeColor', 'interp', 'FaceColor', 'interp');
%s.EdgeColor = 'none';
view(90,90)
set(gca,'FontSize', 12);
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.02))
fig.PaperPositionMode   = 'auto';
c.Label.FontSize = 13;
