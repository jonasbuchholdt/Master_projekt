clear all

outfilename = 'times_compact.csv';

IN = load('reverb_impulses_absorption_with_sp1_T_30.mat','T_30');
SP1 = IN.T_30;
IN = load('reverb_impulses_absorption_with_sp2_T_30.mat','T_30');
SP2 = IN.T_30;
IN = load('reverb_impulses_absorption_with_sp3_T_30.mat','T_30');
SP3 = IN.T_30;

sum = [SP1;SP2;SP3];

dlmwrite(outfilename,sum);