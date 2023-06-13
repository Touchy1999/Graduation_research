format long
clearvars
% file path
date = '03_08/8';
hap_filename = append('/home/tachibana/Experiment/',date,'/Haptic030813.csv');
emg_filename = append('/home/tachibana/Experiment/',date,'/EMGRecord23030813.csv');
min_unix_filename = append('/home/tachibana/Experiment/',date,'/min_unix.csv');
max_unix_filename = append('/home/tachibana/Experiment/',date,'/max_unix.csv');
% extract the necessary data
hap = readmatrix(hap_filename);
hap_unix = hap(1:end,1:1);
hap_loc = hap(1:end,2:8);
hap_vel = hap(1:end,9:14);
hap_force = hap(1:end,15:16);
%min_data = readmatrix(min_unix_filename);
%min_unix_time = min_data(1:1,1:end);
max_data = readmatrix(max_unix_filename);
max_unix_time = max_data(1:1,1:end);
electrode = readmatrix(emg_filename);
six_data = electrode(2:end,3:8);
emg_unix = electrode(2:end,9:9);
% make file of the emg/hap/force file
designed_hap_size = 500;
data_size = 1000;
j = 0;
first_break = 0;
for i = 1:30
    start_time = max_unix_time(2*i-1);
    finish_time = max_unix_time(2*i);
    %finish_time-start_time
    temp = find(and(start_time < hap_unix, hap_unix < finish_time));
    if 1 < 2%temp(end)-temp(1)+1 >= designed_hap_size %(prevent upsampling)
        %This is force processing
        j = j + 1;
        start_index = temp(1);
        finish_index = temp(end);

        new_Sig = hap_force(start_index:finish_index,1:end);
        new_Sig = new_Sig.';
        [~, h] = size(new_Sig);

        first_break = first_break + 15;
        last_break = data_size - first_break - h;


        new_start_index = start_index - first_break;
        new_finish_index = finish_index + last_break;
        new_Sig = hap_force(new_start_index:new_finish_index,1:end);
        new_Sig = new_Sig.';
        y_axis_1 = new_Sig(1:1,1:end);
        y_axis_2 = new_Sig(2:2,1:end);
        [~, h] = size(y_axis_1);
        converted_Sig = cat(1,y_axis_1,y_axis_2);
        
        %downed_y_axis_1 = resample(y_axis_1,floor(h*60/281),h);
        %downed_y_axis_2 = resample(y_axis_2,floor(h*60/281),h);
        %converted_Sig = cat(1,downed_y_axis_1,downed_y_axis_2);
        %[~, h] = size(downed_y_axis_1);

        force_folder_name = append('/home/tachibana/Experiment/',date,'/force');
        if not(exist(force_folder_name,'dir'))
            mkdir(force_folder_name)
        end
        writematrix(converted_Sig,append('/home/tachibana/Experiment/',date,'/force/force_',num2str(j+103),'.csv'))



        %This is emg processing
        temp2 = find(and(hap_unix(new_start_index) < emg_unix, emg_unix < hap_unix(new_finish_index)));
        start_index = temp2(1);
        finish_index = temp2(end);

        Emg = six_data(start_index:finish_index,1:end);
        

        fs = 1000;
        [b1,a1] = butter(4, 20/(fs/2),'high');
        Emg = filtfilt(b1,a1,Emg);
        [b2,a2] = butter(4, 450/(fs/2),'low');
        Emg = filtfilt(b2,a2,Emg);
        Emg = abs(Emg);
        [b3,a3] = butter(4, 4/(fs/2),'low');
        Emg = filtfilt(b3,a3,Emg);
        Emg = Emg.';
        %plot(Emg.')
        %legend('1','2','3','4','5','6')

        opt = statset('Maxiter',1000,'Display','final');
        [W,H] = nnmf(Emg,3,'replicates',50,'options',opt,'algorithm','als');


        [w, h2] = size(H);
        ttime = (hap_unix(new_finish_index)-hap_unix(new_start_index))/1000000;
        %h2
        %h
        H_1 = H(1:1,:);
        H_2 = H(2:2,:);
        H_3 = H(3:3,:);
        H_1 = resample(H_1,h,h2);
        H_2 = resample(H_2,h,h2);
        H_3 = resample(H_3,h,h2);
        H = cat(1,H_1,H_2,H_3);
        %size(H)

        emg_folder_name = append('/home/tachibana/Experiment/',date,'/emg');
        if not(exist(emg_folder_name,'dir'))
            mkdir(emg_folder_name)
        end
        writematrix(H,append('/home/tachibana/Experiment/',date,'/emg/emg_',num2str(j+103),'.csv'))
    end
end