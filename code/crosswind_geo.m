
%%






clear 
v = 10;
wind = pi/2;
c = 343;
step = 90;
speaker_dis = 20;
%dis = 0.029;

front = [0; 1];
point_l = [0; 0];
%direction(:,1) = [-0.9; 0.1]
direction(:,1) = [-0.707; 0.707]
direction(:,1) = 1/norm(direction(:,1),2)*direction(:,1)
leng_l(1) = norm(direction(:,1),2)

theta(1) = sign(direction(1,1))*acos((direction(:,1)'*[0 1]')/(norm(direction(:,1))*1)); %asin((dis)/(1));
for i=1:step  
    d(:,i) = [v*(1/(c+v*sin(theta(i))))*sin(wind); v*(1/(c+v*sin(theta(i))))*cos(wind)]; 
    p(:,i) = (d(:,i)'*(-direction(:,i)))/norm(direction(:,i))^2*(-direction(:,i));
    e(:,i) = d(:,i)-p(:,i);
    ang = asin(norm(e(:,i)));
    le = cos(ang);
    b = direction(:,i)*le;
    direction(:,i+1) = b+e(:,i);
    leng_l(i+1) = norm(direction(:,i+1),2);
    theta(i+1) = sign(direction(1,i+1))*acos((direction(:,i+1)'*front)/(norm(direction(:,i+1))*1));
    dis(:,i) = ((direction(:,i+1)'*front)/(norm(front)^2))*(front); 
    point_l(:,i+1) = point_l(:,i)+direction(:,i+1);
end

point_r = [0; 0];
%direction(:,1) = [0.9; 0.1]
direction(:,1) = [0.707; 0.707]
direction(:,1) = 1/norm(direction(:,1),2)*direction(:,1)
leng_r(1) = norm(direction(:,1),2)

theta(1) = sign(direction(1,1))*acos((direction(:,1)'*[0 1]')/(norm(direction(:,1))*1)); %asin((dis)/(1));
for i=1:step
    
    d(:,i) = [v*(1/(c+v*sin(theta(i))))*sin(wind); v*(1/(c+v*sin(theta(i))))*cos(wind)]; 
    p(:,i) = (d(:,i)'*(-direction(:,i)))/norm(direction(:,i))^2*(-direction(:,i));
    e(:,i) = d(:,i)-p(:,i);
    ang = asin(norm(e(:,i)));
    le = cos(ang);
    b = direction(:,i)*le;
    direction(:,i+1) = b+e(:,i);   
    leng_r(i+1) = norm(direction(:,i+1),2);
    theta(i+1) = sign(direction(1,i+1))*acos((direction(:,i+1)'*front)/(norm(direction(:,i+1))*1));
    dis(:,i) = ((direction(:,i+1)'*front)/(norm(front)^2))*(front); 
    point_r(:,i+1) = point_r(:,i)+direction(:,i+1);
    if point_r(1,i+1) >= abs(point_l(1,step+1))
        break
    end
end

sum(dis(2,:))

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

legend('Speaker coverage area','Location','northwest')



