



%%
clear 

% 1k 2k 4k 8k 16k

deg_x = [0 0 0 0 0     10 10 10 10 10  20 20 20 20 20  30 30 30 30 30]
%deg_x = [ 3 3 3 3 3    13 13 13 13 13  23 23 23 23 23  33 33 33 33 33]

% all data 
speed_5_6 = [                              -2.50 1.41 3.10 5.28 7.93     -4.06 -4.39 -1.89 -0.29 0.39     -6.62 -7.95 -7.98 -10.93 -9.50];
speed_6_7 = [9.62 17.67 9.76 10.75 13.40   -0.39 4.82 6.77 5.38 5.44    -0.84 -2.32 -3.13 -4.67 -5.68    -4.98 -10.22 -11.60 -14.99 -12.14];  
speed_7_8 = [8.74 8.19 9.24 12.66 12.39     2.56 7.39 11.68 8.90 7.83   -1.96 -1.16 -4.91 -4.16 -1.52    -4.63 -12.21 -11.61 -17.48 -11.25] ;   
speed_8_10= [7.28 9.06 8.48 11.59 14.42    2.04 2.43 4.18 5.75 8.19    -0.59 -0.57 -3.55 -6.02 -4.41    -5.07 -13.06 -15.90 -15.60 -11.15];

% 1k data 
speed_5_6 = [        -2.50    -4.06     -6.62 ];
speed_6_7 = [9.62    -0.39    -0.84     -4.98 ];  
speed_7_8 = [8.74     2.56    -1.96     -4.63 ];   
speed_8_10= [7.28     2.04    -0.59     -5.07 ];

% 2k data
speed_5_6 = [         1.41    -4.39    -7.95];
speed_6_7 = [ 17.67   4.82    -2.32    -10.22];  
speed_7_8 = [ 8.19    7.39    -1.16    -12.21];   
speed_8_10= [ 9.06    2.43    -0.57    -13.06];

% 4k data
speed_5_6 = [         3.10    -1.89    -7.98];
speed_6_7 = [ 9.76    6.77    -3.13    -11.60];  
speed_7_8 = [ 9.24    11.68   -4.91    -11.61];   
speed_8_10= [ 8.48    4.18    -3.55    -15.90];

% 8k data
speed_5_6 = [          5.28    -0.29    -10.93];
speed_6_7 = [ 10.75    5.38    -4.67    -14.99];  
speed_7_8 = [ 12.66    8.90    -4.16    -17.48];   
speed_8_10= [ 11.59    5.75    -6.02    -15.60];


% 16k data 
speed_5_6 = [         7.93      0.39    -9.50];
speed_6_7 = [ 13.40   5.44     -5.68    -12.14];  
speed_7_8 = [ 12.39   7.83     -1.52    -11.25];   
speed_8_10= [ 14.42   8.19     -4.41    -11.15];

%%
clear 
%deg_x = [ 0 0 0 0 0    10 10 10 10 10  20 20 20 20 20  30 30 30 30 30]
    %deg_x       = [0      10   20    30];
    
    
% 8k data
speed_5_6 = [          5.28    -0.29    -10.93];
speed_6_7 = [ 10.75    5.38    -4.67    -14.99];  
speed_7_8 = [ 12.66    8.90    -4.16    -17.48];   
speed_8_10= [ 11.59    5.75    -6.02    -15.60];   


dat = speed_8_10;
deg_x = [0 10 20 30];


    scatter(deg_x,dat,25,'*') 
    P = polyfit(deg_x,dat,1);
    x = [0:1:31];
    yfit = polyval(P,x)
    hold on;
    grid on
    plot(x,yfit);
    set(gca,'Ytick',-20:1:20)
    set(gca,'xtick',-1:1:31)
    ylabel('Difference [dB]')
    xlabel('angle [deg]')
    
   %5-6  13 or
   
  %5-6  15
  %6-7  16
  %7-8  16
  %8-10 14.5
  
   %8-9  13
  %9-10 19.5
%%
  figure(1)

data_0  = [ 9.62  17.67 9.76  10.75  13.40  8.74  8.19   9.24   12.66  12.39  7.28  9.06   8.48   11.59  14.42];
data_10 = [-2.50  1.41  3.10  5.28   7.93  -0.39  4.82   6.77   5.38   5.44   2.56  7.39   11.68  8.90   7.83   2.04  2.43   4.18   5.75   8.19];
data_20 = [-4.06 -4.39 -1.89 -0.29   0.39  -0.84 -2.32  -3.13  -4.67  -5.68  -1.96 -1.16  -4.91  -4.16  -1.52  -0.59 -0.57  -3.55  -6.02  -4.41];
data_30 = [-6.62 -7.95 -7.98 -10.93 -9.50  -4.98 -10.22 -11.60 -14.99 -12.14 -4.63 -12.21 -11.61 -17.48 -11.25 -5.07 -13.06 -15.90 -15.60 -11.15];
xf = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
xs = [10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10];
xt = [20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20];
xl = [30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30];


%boxplot([data_0 data_10 data_20 data_30],[xf xs xt xl],'positions',[0,10,20,30]);


dum0 = [-2 -1]
dum0d = [-100 -100]
dum1 = [1 2 3 4 5 6 7 8 9];
dum1d = [-100 -100 -100 -100 -100 -100 -100 -100 -100];
dum2 = [11 12 13 14 15 16 17 18 19];
dum2d = [-100 -100 -100 -100 -100 -100 -100 -100 -100];
dum3 = [21 22 23 24 25 26 27 28 29];
dum3d = [-100 -100 -100 -100 -100 -100 -100 -100 -100];
dum4 = [31 32]
dum4d = [-100 -100]

boxplot([data_0 dum1d data_10 dum2d data_20 dum3d data_30],[xf dum1 xs dum2 xt dum3 xl]) 
hold on
grid on
axis([0 32 -20 20])
    set(gca,'Ytick',-20:1:20)
    %set(gca,'xtick',-2:1:32)
    ylabel('Difference [dB]')
    xlabel('angle [deg]')  
    
  
  
  
  
  
  
  
    
