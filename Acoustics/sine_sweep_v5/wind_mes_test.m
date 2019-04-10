close;
clear;

if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
%%
port = seriallist;
s=serial(port(5),'InputBufferSize',512,'Baudrate',115200); 
s.ReadAsyncMode = 'manual';
s.Terminator = 'LF';
i=0; salti=0;
dat = [];

%%
tic;             

tic
k=1;

fopen(s)
record(s,'on')
while(toc<10)
  data(:,k)=strsplit(fscanf(s),'\t');
  k=k+1;
end
record(s,'off')

tic
while(toc<20)
  data(:,k)=strsplit(fscanf(s),'\t');
  k=k+1;
end
fclose(s)
%%
while(toc<10)
    fopen(s)
  data(:,k)=strsplit(fscanf(s),'\t'); 
  k=k+1
  fclose(s)
end
%%
tic;
k=1;
while(toc<4)
   thisline(k,:) = strsplit(fscanf(s),'\t');
   k=k+1;
end

  

       %%
       
                            
%%
                      

weather = str2double(dat);
wind_speed = kron(weather(:,1), ones(L,1))*0.75;
wind_direction = kron(weather(:,2), ones(L,1))/1024*359;
temp = kron(weather(:,3), ones(L,1));
humidity = kron(weather(:,4), ones(L,1));

                      