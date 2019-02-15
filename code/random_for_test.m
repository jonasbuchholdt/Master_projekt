clear all
close all
clc

conds = ["Air" "Bone" "Air" "Bone"];
condlst = 1:4;
LstSpace = 1:10;
Tst = 'Test run:';
Fam = 'Familiarisation';
Lnr = 'List number:';
Con = 'Conductor:';

FamNum = randi([1 3],1,1);

condlst = datasample(condlst,4,'Replace',false);
T1Con = conds(condlst(1));
T2Con = conds(condlst(2));
T3Con = conds(condlst(3));
T4Con = conds(condlst(4));

TList = datasample(LstSpace,4,'Replace',false);

disp(Fam)
disp([Lnr int2str(FamNum)])
disp(' ')
disp([Tst int2str(1)])
disp([Con T1Con])
disp([Lnr int2str(TList(1))])
disp(' ')
disp([Tst int2str(2)])
disp([Con T2Con])
disp([Lnr int2str(TList(2))])
disp(' ')
disp([Tst int2str(3)])
disp([Con T3Con])
disp([Lnr int2str(TList(3))])
disp(' ')
disp([Tst int2str(4)])
disp([Con T4Con])
disp([Lnr int2str(TList(4))])