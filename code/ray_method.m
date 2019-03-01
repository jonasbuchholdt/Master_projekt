
%%

clear 
v = 10;
wind = pi/2;
c_r = 343;
step = 65;
speaker_dis = 20;
front = [0; 1];
point_l = [0; 0];

[x, y] = pol2cart(deg2rad(-45), 1)
a_direction(:,1) = [y; x]
a_direction(:,1) = res/norm(a_direction(:,1),2)*a_direction(:,1)
leng_l(1) = norm(a_direction(:,1),2)

theta(1) = sign(a_direction(1,1))*acos((a_direction(:,1)'*front)/(norm(a_direction(:,1))*1));
for i=1:step*(1/res) 
    
    
 S_x = cos(pi/2)/(c_r+norm(v)*cos(pi/2-0));
 
 S_z = sin(pi/2)/(c_r+norm(v)*cos(pi/2-0))
    
    
    
    
d(:,i) = [(v*res) * ((1*res)/(c_r+v*sin(theta(i)))) * sin(wind); v * ((1*res)/(c_r+v*sin(theta(i)))) * cos(wind)]; 
p(:,i) = (d(:,i)' * (-a_direction(:,i)))/norm(a_direction(:,i))^2 * (-a_direction(:,i));
e(:,i) = d(:,i) - p(:,i);
phi(i) = asin(norm((1/res)*e(:,i)));
a(:,i) = a_direction(:,i) * cos(phi(i));
w(:,i) = a(:,i) + e(:,i);
theta(i+1) = sign(w(1,i)) * acos(((w(:,i)'*front)) / (norm(w(:,i))*norm(front)));
a_direction(:,i+1) = w(:,i);

leng_l(i+1) = norm(w(:,i),2);
point_l(:,i+1) = point_l(:,i)+w(:,i);
dis_l(:,i) = ((w(:,i)'*front)/(norm(front)^2))*(front); 
t_l(:,i) = (1/(c_r+v*sin(theta(i))))*sin(wind);
end













%%
point_r = [0; 0];
%direction(:,1) = [0.9; 0.1]
a_direction(:,1) = [0.707; 0.707]
a_direction(:,1) = 1/norm(a_direction(:,1),2)*a_direction(:,1)
leng_r(1) = norm(a_direction(:,1),2)

theta(1) = sign(a_direction(1,1))*acos((a_direction(:,1)'*[0 1]')/(norm(a_direction(:,1))*1)); %asin((dis)/(1));
for i=1:step+step
    
d(:,i) = [v*(1/(c_r+v*sin(theta(i))))*sin(wind); v*(1/(c_r+v*sin(theta(i))))*cos(wind)]; 
p(:,i) = (d(:,i)'*(-a_direction(:,i)))/norm(a_direction(:,i))^2 * (-a_direction(:,i));
e(:,i) = d(:,i)-p(:,i);
phi(i) = asin(norm(e(:,i)));
a(:,i) = a_direction(:,i)*cos(phi(i));
w(:,i) = a(:,i)+e(:,i);
theta(i+1) = sign(w(1,i))*acos(((w(:,i)'*front)) / (norm(w(:,i))*norm(front)));
a_direction(:,i+1) = w(:,i);

leng_r(i+1) = norm(w(:,i),2);
point_r(:,i+1) = point_r(:,i)+w(:,i);
dis_r(:,i) = ((w(:,i)'*front)/(norm(front)^2))*(front); 
t_r(:,i) = (1/(c_r+v*sin(theta(i))))*sin(wind);

    if sum(t_r) >= sum(t_l)
        break
    end
end

%sum(dis(2,:))

plot([point_l(1,:)+speaker_dis/2 flip(point_r(1,:))+speaker_dis/2],[point_l(2,:) flip(point_r(2,:))],'Color',[0.6 0.6 0.6])
hold on
plot([point_l(1,:)-speaker_dis/2 flip(point_r(1,:))-speaker_dis/2],[point_l(2,:) flip(point_r(2,:))],'Color',[0.6 0.6 0.6])

grid on
axis equal


h = fill([point_l(1,:)+speaker_dis/2 flip(point_r(1,:))+speaker_dis/2],[point_l(2,:) flip(point_r(2,:))], [0.6 0.6 0.6]);
set(h,'facealpha',.5)

h = fill([point_l(1,:)-speaker_dis/2 flip(point_r(1,:))-speaker_dis/2],[point_l(2,:) flip(point_r(2,:))], [0.6 0.6 0.6]);
set(h,'facealpha',.5)


%grid minor
set(gca,'xtick',[-140:10:140])
set(gca,'ytick',[-140:10:140])

xlabel('Length [m]')
ylabel('Width [m]')

legend('Speaker coverage area')



