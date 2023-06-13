format long
date = '03_08/8';
filename = append('/home/tachibana/Experiment/',date,'/Haptic030813.csv');
Sig = readmatrix(filename);
unix_time = Sig(1:end,1:1);
x = Sig(1:end,2:2);
y = Sig(1:end,3:3);
z = Sig(1:end,4:4);

judge = y;


[pks,locs] = findpeaks(judge,unix_time);
findpeaks(judge,unix_time,'MinPeakDistance',5000000);
%text(locs+.02,pks,num2str((1:numel(pks))'))
[x_pos,~] = getpts
writematrix(x_pos.',append('/home/tachibana/Experiment/',date,'/max_unix.csv'))




