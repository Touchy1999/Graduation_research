f1 = figure;
f2 = figure;

date = '02_24/2';
electrode_filename = append('/home/tachibana/Experiment/',date,'/EMGRecord23022412.csv');
min_unix_filename = append('/home/tachibana/Experiment/',date,'/min_unix.csv');
max_unix_filename = append('/home/tachibana/Experiment/',date,'/max_unix.csv');

number_of_trial = 15;

electrode = readmatrix(electrode_filename);
six_data = electrode(2:end,3:8);
orig_unix = electrode(2:end,9:9);

%min_data = readmatrix(min_unix_filename);
%min_unix_time = min_data(1:1,1:end);

max_data = readmatrix(max_unix_filename);
max_unix_time = max_data(1:1,1:end);

number_of_base = 3;
for i = 1:number_of_trial
    start_time = max_unix_time(2*i);
    finish_time = max_unix_time(2*i+1);
    finish_time-start_time
    temp = find(and(start_time < orig_unix, orig_unix < finish_time));
    size(temp)
    Sig = six_data(temp(1):temp(end),1:6);

    fs = 1000;
    [b1,a1] = butter(4, 20/(fs/2),'high');
    Sig = filtfilt(b1,a1,Sig);
    [b2,a2] = butter(4, 450/(fs/2),'low');
    Sig = filtfilt(b2,a2,Sig);
    Sig = abs(Sig);
    [b3,a3] = butter(4, 4/(fs/2),'low');
    Sig = filtfilt(b3,a3,Sig);
    Sig = abs(Sig);
    Sig = Sig.';

    %size(Sig)
    
    opt = statset('Maxiter',1000,'Display','final');
    [W,H] = nnmf(Sig,number_of_base,'replicates',50,'options',opt,'algorithm','als');
    W = W.';
    H = H.';
    

    figure(f1);
    subplot(5,6,i);
    bar(W);
    legend('1','2')

    figure(f2);
    subplot(5,6,i);
    plot(H);
    legend('1','2')
    
end

