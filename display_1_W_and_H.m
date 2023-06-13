f1 = figure;
f2 = figure;
f3 = figure;
f4 = figure;
date = '01_28/4';
electrode_filename = append('/home/tachibana/Experiment/',date,'/EMGRecord23012812.csv');
min_unix_filename = append('/home/tachibana/Experiment/',date,'/min_unix.csv');
max_unix_filename = append('/home/tachibana/Experiment/',date,'/max_unix.csv');



electrode = readmatrix(electrode_filename);
six_data = electrode(2:end,3:8);
orig_unix = electrode(2:end,9:9);

min_data = readmatrix(min_unix_filename);
min_unix_time = min_data(1:1,1:end);

max_data = readmatrix(max_unix_filename);
max_unix_time = max_data(1:1,1:end);


number_of_base = 1;
i = 5;
start_time = max_unix_time(2*i-1);
finish_time = min_unix_time(2*i-1);
temp = find(and(start_time < orig_unix, orig_unix < finish_time));
Sig = six_data(temp(1):temp(end),1:6);
figure(f1)
plot(Sig)
title(['処理前の筋電データ(屈曲)'],FontSize=35)
xlabel('Time Step',FontSize=25)
ylabel('Muscle Raw Data',FontSize=25)
lgd = legend(':muscle 1',':muscle 2',':muscle 3',':muscle 4',':muscle 5',':muscle 6');
lgd.FontSize = 20;

fs = 1000;
[b1,a1] = butter(4, 20/(fs/2),'high');
Sig = filtfilt(b1,a1,Sig);
[b2,a2] = butter(4, 450/(fs/2),'low');
Sig = filtfilt(b2,a2,Sig);
Sig = abs(Sig);
[b3,a3] = butter(4, 4/(fs/2),'low');
Sig = filtfilt(b3,a3,Sig);
Sig = abs(Sig);
figure(f2)
plot(Sig)
title('処理後の筋電データ(屈曲)',FontSize=35)
xlabel('Time Step',FontSize=25)
ylabel('Muscle Synergy',FontSize=25)
lgd = legend(':muscle 1',':muscle 2',':muscle 3',':muscle 4',':muscle 5',':muscle 6');
lgd.FontSize = 20;

Sig = Sig.';

opt = statset('Maxiter',1000,'Display','final');
[W,H] = nnmf(Sig,number_of_base,'replicates',100,'options',opt,'algorithm','als');
W = W.';
H = H.';

H = rescale(H);

H_1 = H(1:end,1:1);
%H_2 = H(1:end,2:2);

figure(f3)
plot(H_1,"red")
%hold on
%plot(H_2,"blue")
%hold off
lgd = legend(': synergy 1',': synergy 2');
lgd.FontSize = 20;
xlabel('Time Step', 'FontSize', 20)
ylabel('Weight coefficients [-]', 'FontSize', 20)


W = rescale(W);
W_1 = W(1:1,1:6);
%W_2 = W(2:2,1:6);
x = 1:1:6;

figure(f4)
name = {'上腕二頭筋';'上腕三頭筋';'長掌筋';'長橈側手根伸筋';'回外筋付近';'橈側手根屈筋'};
figure(f4)
%subplot(2,1,1)
bar(x,W_1,"red")
lgd1 = legend('Synergy 1');
lgd1.FontSize = 20;
ylabel('Activation level [-]', 'FontSize', 20);
set(gca,'xticklabel',name)
set(gca,'fontsize',20)

%{
subplot(2,1,2)
bar(x,W_2,"blue")
lgd1 = legend('Synergy 2');
lgd1.FontSize = 20;
ylabel('Activation level [-]', 'FontSize', 20);
set(gca,'xticklabel',name)
set(gca,'fontsize',20)
%}

   

