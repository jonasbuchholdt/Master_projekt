

clear 
v = 10;
wind = pi/2;
c_r = 343;
step = 65;
speaker_dis = 20;

front = [0; 1];
ray = [0; 0];


for  g=1:1:31
clear d;
clear p;
clear e;
clear phi;
clear a;
clear w;
clear theta;
clear a_direction;
clear t_r;
clear dis_r
clear leng_r

[x, y] = pol2cart(deg2rad(-45+(g-1)*3), 1);
a_direction(:,1) = [y; x];
a_direction(:,1) = 1/norm(a_direction(:,1),2)*a_direction(:,1);
leng_r(1) = norm(a_direction(:,1),2);

ray(:,1,g) = [0; 0];


theta(1) = sign(a_direction(1,1))*acos((a_direction(:,1)'*front)/(norm(a_direction(:,1))*1)); %asin((dis)/(1));
for i=1:step
    
d(:,i) = [v*(1/(c_r+v*sin(theta(i))))*sin(wind); v*(1/(c_r+v*sin(theta(i))))*cos(wind)]; 
p(:,i) = (d(:,i)'*(-a_direction(:,i)))/norm(a_direction(:,i))^2 * (-a_direction(:,i));
e(:,i) = d(:,i)-p(:,i);
phi(i) = asin(norm(e(:,i)));
a(:,i) = a_direction(:,i)*cos(phi(i));
w(:,i) = a(:,i)+e(:,i);
theta(i+1) = sign(w(1,i))*acos(((w(:,i)'*front)) / (norm(w(:,i))*norm(front)));
a_direction(:,i+1) = w(:,i);

leng_r(i+1) = norm(w(:,i),2);
ray(:,i+1,g) = ray(:,i,g)+w(:,i);
dis_r(:,i) = ((w(:,i)'*front)/(norm(front)^2))*(front); 
t_r(:,i) = (1/(c_r+v*sin(theta(i))))*sin(wind);

    %if sum(t_r) >= sum(t_l)
        %break
    %end
end

end


area = [ray(1,:,1); ray(2,:,1)]'
for i=1:g
   area = [area; ray(1,end,i) ray(2,end,i)] ;
end
area = [area; flip(ray(1,:,end))' flip(ray(2,:,end))']


%%

plot(0-speaker_dis/2, 0,'x','MarkerSize',10,'color',[1 0 0])
hold on
plot(0+speaker_dis/2, 0,'x','MarkerSize',10,'color',[1 0 0])

f = fill(area(:,1)-speaker_dis/2, area(:,2), [0.6 0.6 0.6]);
set(f,'facealpha',.5)

h = fill(area(:,1)+speaker_dis/2, area(:,2), [0.6 0.6 0.6]);
set(h,'facealpha',.5)


%grid minor
set(gca,'xtick',[-140:10:140])
set(gca,'ytick',[-140:10:140])

xlabel('Length [m]')
ylabel('Width [m]')

legend('Left speaker',' Right speaker','Speaker coverage area')

grid on

