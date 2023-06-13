path = '/home/tachibana/Experiment/03_08/data/280Hz/lstm/280Hz-emg-oneshot/';
cnt = 0;
wa = 0;
for i = 1:20
    acc_path = append(path, 'a.csv');
    pre_path = append(path, 'p',num2str(i),'.csv');
    if isfile(pre_path)
        act = readmatrix(acc_path);
        pre = readmatrix(pre_path);

        a = act(1:end,1:end);
        p = pre(1:end,1:end);
        %{
        for idx = [108 136 216 323 433 482 537 644 675 756 863 979]
            idx_1 = idx - 15;
            idx_2 = idx + 15;
            a = cat(2,a,act(1:end,idx_1:idx_2));
            p = cat(2,p,pre(1:end,idx_1:idx_2));
        end
        %}
        a = a.';
        p = p.';
        plot(p(1:end,1:1),'--','Color','red','LineWidth',2)
        hold on
        plot(p(1:end,2:2),'--','Color','blue','LineWidth',2)
        plot(a(1:end,1:1),'red','LineWidth',2)
        plot(a(1:end,2:2),'blue','LineWidth',2)
        lgd = legend({'predicted Fx','predicted Fy','actual Fx','actual Fy'},'FontSize',20);
        hold off
        acc = 1 - sum(abs(a-p),'all')/sum(abs(a),'all');
        if acc > 0
            cnt = cnt + 1;
            wa = wa + acc;
        end
    end
end
disp(wa/cnt)