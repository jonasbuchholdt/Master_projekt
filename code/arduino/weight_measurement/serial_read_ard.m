

%close;
%clear;

if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
%%
port = seriallist;
s = serial(port(6));
s.baudrate = 9600;
out = [];
%fprintf(s,'*IDN?')


%% zero weight
fopen(s)
tic
count = 1;
while toc<30   
    out(1,count) = str2double(fscanf(s));
    count = count +1;
end
data(1) = mean(out(1,2:end)); 
fclose(s)

%% small weight
fopen(s)
tic
count = 1;
while toc<30   
    out(2,count) = str2double(fscanf(s));
    count = count +1;
end
data(2) = mean(out(2,2:end)); 
fclose(s)

%% medium small weight
fopen(s)
tic
count = 1;
while toc<30   
    out(3,count) = str2double(fscanf(s));
    count = count +1;
end
data(3) = mean(out(3,2:end)); 
fclose(s)

%% big small weight
fopen(s)
tic
count = 1;
while toc<30   
    out(4,count) = str2double(fscanf(s));
    count = count +1;
end
data(4) = mean(out(4,2:end)); 
fclose(s)

%% big weight
fopen(s)
tic
count = 1;
while toc<30   
    out(5,count) = str2double(fscanf(s));
    count = count +1;
end
data(5) = mean(out(5,2:end)); 
fclose(s)

%% more big weight
fopen(s)
tic
count = 1;
while toc<30   
    out(6,count) = str2double(fscanf(s));
    count = count +1;
end
data(6) = mean(out(6,2:end)); 
fclose(s)

%% slope calculation

weight(1) = 0;
weight(2) = 75.3;
weight(3)   =118;
weight(4)   =156.4;
weight(5)   =194.1;
weight(6) = 226.7;

%slope = ( (weight(2) - weight(1)) / (data(2) - data(1)))
p = polyfit(data(2:6),weight(2:6),1)


%% do weighting
fopen(s)
tic
count = 1;
while toc<20   
    out(7,count) = str2double(fscanf(s));
    count = count +1;
end
result = polyval(p,mean(out(7,2:160))); 
fclose(s)
newton = result/1000*9.81
%% close
delete(s)
clear s