% This code uses a toolbox to conduct Mann-Whitney-U Test:
% The linnk is here:  https://www.mathworks.com/matlabcentral/fileexchange/25830-mwwtest-x1-x2-

% This code uses two toolbox for data visualization:
% 1) stdshade -- https://www.mathworks.com/matlabcentral/fileexchange/29534-stdshade
% 2) notboxplot -- https://www.mathworks.com/matlabcentral/fileexchange/26508-notboxplot

% This code sometimes uses a toolbox for Correlation Matrix Equality Test (not included in the code):
% The linnk is here:  https://www.mathworks.com/matlabcentral/fileexchange/15171-jennrich-test

%% load the data:
% - Input:
%           pix_per_cm: number of pixels per centimeter
%           ctrl: control group
%           expt: experimental group
% - Data format:
%     frame * #animal: 6000 * N (default)
% Note that the imaging speed is 5 fps

%% downsampling from 6000 frames to 1200 frames, i.e. 1 frame per second
if size(ctrl,1) == 6000
    tmp = reshape(ctrl,[5,1200,size(ctrl,2)]);
else
    tmp = reshape(ctrl,[4,1200,size(ctrl,2)]);
end
tmp = median(tmp);
ctrl = squeeze(tmp);

if size(expt,1) == 6000
    tmp = reshape(expt,[5,1200,size(expt,2)]);
else
    tmp = reshape(expt,[4,1200,size(expt,2)]);
end
tmp = median(tmp);
expt = squeeze(tmp);

%% pre-processing, arrange data by cycles
tmp = reshape(ctrl,[120,10,size(ctrl,2)]);
OFF_ctrl = tmp(1:60,:,:);
ON_ctrl = tmp(61:120,:,:);
mean_ctrl = squeeze(mean(tmp,2));
first5_ctrl = squeeze(mean(tmp(:,1:5,:),2));
last5_ctrl = squeeze(mean(tmp(:,6:10,:),2));

tmp = reshape(expt,[120,10,size(expt,2)]);
OFF_expt = tmp(1:60,:,:);
ON_expt = tmp(61:120,:,:);
mean_expt = squeeze(mean(tmp,2));
first5_expt = squeeze(mean(tmp(:,1:5,:),2));
last5_expt = squeeze(mean(tmp(:,6:10,:),2));


%% average of vertical position
figure
hold on
CIshade(-mean_ctrl'/pix_per_cm,0.5,'black')
CIshade(-mean_expt'/pix_per_cm,0.5,'red')
% CIshade is modified from stdshade, by replacing std with 95% confidence interval: https://www.mathworks.com/matlabcentral/fileexchange/29534-stdshade

x1  = [1,60];
x2 = [60,120];
y = [0,0,-5,-5];
fill([x1,fliplr(x1)],y,'k', 'FaceAlpha', 0.2,'linestyle','none');
fill([x2,fliplr(x2)],y,'b', 'FaceAlpha', 0.2,'linestyle','none');
hold off
axis tight;
ylim([-5,0]);
set(gca,'YTick',[-5 -4 -3 -2 -1 0])
set(gca,'YTickLabel','-5|-4|-3|-2|-1|0')
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 9 9]); set(gcf, 'PaperSize', [9 9]);
title ('Vertical Position');
xlabel('Time (s)'); 
ylabel('Depth (cm)');
nice_plot;box on;

%% initial vertical speed
figure, t = 20;
subplot(2,1,2)
hold on
tmp1 = squeeze(mean(ON_ctrl,2));
tmp1 = tmp1(t,:) - tmp1(1,:);
tmp1 = -tmp1(:)/pix_per_cm/t;

tmp2 = squeeze(mean(ON_expt,2));
tmp2 = tmp2(t,:) - tmp2(1,:);
tmp2 = -tmp2(:)/pix_per_cm/t;

boxplot([tmp1;tmp2],[ones(length(tmp1),1); 2* ones(length(tmp2),1)]);
% alternatively, notboxplot was used: https://www.mathworks.com/matlabcentral/fileexchange/26508-notboxplot
        
ylim([-0.1,0.3]);set(gca,'YTick',[-0.1,0,0.1,0.2,0.3 ]);
xlim([0.5,2.5]);grid on;box on;
axis square;
set(gca,'XTick',[1 2 ])
set(gca,'XTickLabel','ctrl|expt')
ylabel('Initial Vertical Speed (cm/s)');
title('ON');nice_plot;

subplot(2,1,1)
hold on
tmp1 = squeeze(mean(OFF_ctrl,2));
tmp1 = tmp1(t,:) - tmp1(1,:);
tmp1 = -tmp1(:)/pix_per_cm/t;

tmp2 = squeeze(mean(OFF_expt,2));
tmp2 = tmp2(t,:) - tmp2(1,:);
tmp2 = -tmp2(:)/pix_per_cm/t;

boxplot([tmp1;tmp2],[ones(length(tmp1),1); 2* ones(length(tmp2),1)]);
% alternatively, notboxplot was used: https://www.mathworks.com/matlabcentral/fileexchange/26508-notboxplot

ylim([-0.3,0.1]);set(gca,'YTick',[-0.3,-0.2,-0.1,0,0.1]);
xlim([0.5,2.5]);
set(gca,'XTick',[1 2]);grid on;box on;
set(gca,'XTickLabel','ctrl|expt')
ylabel('Initial Vertical Speed (cm/s)');
title('OFF');nice_plot;
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 12 20]); set(gcf, 'PaperSize', [12 20]);
nice_plot;box on;
axis square;
%% correlation coefficient, plot & stats
r = corrcoef(ctrl);
[x,idx1] = sort(mean(r),'descend');
[r_ctrl,p_ctrl] = corrcoef(ctrl(:,idx1));

r = corrcoef(expt);
[x,idx2] = sort(mean(r),'descend');
[r_expt,p_expt] = corrcoef(expt(:,idx2));


% correlation coefficient heatmap
figure,
subplot(2,1,1)
imagesc(r_ctrl), colormap(jet),caxis([0,1]),title('ctrl')
subplot(2,1,2)
imagesc(r_expt), colormap(jet),caxis([0,1]),title('expt')

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 5 10]); set(gcf, 'PaperSize', [5 10]); 

disp('******************************************************************')
fprintf('median_r_expt = %0.4f\n',median(triu2vec(r_expt)));
fprintf('median_r_ctrl = %0.4f\n',median(triu2vec(r_ctrl)));
disp('Correlation coefficient by MMW Test');
disp('ctrl VS expt')
STATS=mwwtest(triu2vec(r_ctrl),triu2vec(r_expt));
disp('******************************************************************')

%% stats for vertical speed
tmp = squeeze(mean(OFF_ctrl,2));
tmp = tmp(t,:) - tmp(1,:);
speed1 = -tmp(:)/pix_per_cm/t;

tmp = squeeze(mean(OFF_expt,2));
tmp = tmp(t,:) - tmp(1,:);
speed4 = -tmp(:)/pix_per_cm/t;

disp('******************************************************************')
disp('------------OFF---------------')
disp('ctrl VS expt')
STATS=mwwtest(speed1,speed4);
fprintf('mean_ctrl = %0.4f\n',mean(speed1));
fprintf('mean_expt = %0.4f\n',mean(speed4));

fprintf('std_ctrl = %0.4f\n',std(speed1));
fprintf('std_expt = %0.4f\n',std(speed4));



tmp = squeeze(mean(ON_ctrl,2));
tmp = tmp(t,:) - tmp(1,:);
speed1 = -tmp(:)/pix_per_cm/t;

tmp = squeeze(mean(ON_expt,2));
tmp = tmp(t,:) - tmp(1,:);
speed4 = -tmp(:)/pix_per_cm/t;

disp('------------ON---------------')
disp('ctrl VS expt')
STATS=mwwtest(speed1,speed4);





