

% This code uses a toolbox provided by this paper: 
% Mukamel, E. A., Nimmerjahn, A. & Schnitzer, M. J. Automated analysis of cellular signals from large-scale calcium imaging data. Neuron 63, 747?760 (2009).
% Link of the toolbox: https://www.mathworks.com/matlabcentral/fileexchange/25405-emukamel-cellsort


clear;close all;clc;
% Input
date = 'fish1_trial1';
test = 'Combined Stacks'; % name of a multi-tiff file, which represents the time series of brain imagesc
data_path = '/Volumes/Seagate Backup Plus Drive/20141106/' ;
%data_path = 'G:\20141106\fish3_trial2\';
stimulus = 'rrbbrb'; % squence of the colors (blue or red)of the light stimuli
%stimulus = 'kkkk'; % no light
recording_time = 15; % minutes

folder = [data_path date '/' test];
fn = [data_path date '/' test '.tif']; % directory of the multi-tiff file
f0 = imread([data_path date '/AVG_' test '.tif']);
%%%%%%%%%%%%%mkdir(folder)
cd(folder);
nPC = 60;
%[mixedsig, mixedfilters, CovEvals, covtrace, movm, movtm] = CellsortPCA(fn, [], nPC, [], [], []);
 
[PCuse] = CellsortChoosePCs(fn, mixedfilters);
subfolder = [data_path date '/' test '/' num2str(PCuse(1)) '-' num2str(PCuse(end))];
%%%%%%%%%%%%%mkdir(subfolder)
 
%%%%%%%%%%%%%saveas(gcf,[subfolder '/Choose PC.tif']),clf
CellsortPlotPCspectrum(fn, CovEvals, PCuse);
 
%%%%%%%%%%%%%saveas(gcf,[subfolder '/PC spectrum.tif']),clf
mu = 0;
[ica_sig, ica_filters, ica_A, numiter] = CellsortICA(mixedsig,mixedfilters, CovEvals, PCuse, mu, [], [], [], []);
 
CellsortICAplot('series', ica_filters, ica_sig, f0, [], 1, 1, 1, [], [], []);colormap(jet);
 
%%%%%%%%%%%%%saveas(gcf,[subfolder '/ICs.tif']),clf
[ica_segments, segmentlabel, segcentroid] = CellsortSegmentation(ica_filters, 5, [], [], 1);
 
cell_sig = CellsortApplyFilter(fn, ica_segments);
[spmat, spt, spc] = CellsortFindspikes(ica_sig, 3, 1, 0, 1);
% save([ subfolder '/ica_cell_sig.mat'], 'cell_sig','ica_sig','segcentroid', 'segmentlabel','recording_time','stimulus','subfolder','activity_idx','match_p');
close all;

roi_mask = ica_segments>0;
subsubfolder = [ subfolder '/roi_mask'];
%%%%%%%%%%%%%mkdir(subsubfolder);
for i = 1:size(ica_segments,1)
    imwrite(squeeze(roi_mask(i,:,:)),[ subsubfolder '/roi_mask' num2str(i) '.tif']);
end

%% determine the evoked response by comparing with stimulus templates
time_axis = linspace(0,recording_time,length(movtm));
[activity_template, activity_color]= blue_red_stimulus_template(recording_time,stimulus,time_axis);
[activity_idx match_p] = corr(ica_sig',activity_template');
save([ subfolder '/ica_cell_sig.mat'], 'cell_sig','ica_sig','segcentroid', 'segmentlabel','recording_time','stimulus','subfolder','activity_idx','match_p');

for i = 1:length(PCuse)
figure,
I = squeeze(ica_filters(i,:,:));
imshow(I);
colormap(gray);%colorbar;
axis off;axis image;
%cbfreeze;freezeColors;
imwrite(I*20,[subfolder '/' test '_gray_' num2str(i) '.tif']),
close;



set(gcf,'units','pixel');
figure('Color',[1 1 1],'PaperSize',[300 5000],'Position',[0 0 300 500]);
% plot(time_axis,zscore(ica_sig(i,:)),'k','LineWidth',1.5),axis tight;
% hold on;
% for ii = 1:length(stimulus);
%     x1  = [2*ii-1,2*ii]-1/length(movtm);
%     y = [-2,-2,10,10];
%     fill([x1,fliplr(x1)],y,stimulus(ii), 'FaceAlpha', 0.2,'linestyle','none');
% end
% ylim([-2,10])
% hold off;
% 
% %%%%%%%%%%%%%%%%%------------------------------------------------
% figure(gcf),
% temp = input('What is the color?','s');
% clf,
% %%%%%%%%%%%%%%%%%%%%%%%%-------------------------------------------------

[max_match,idx] = max(activity_idx(i,:));
if max_match > 0.5 && match_p(i,idx) < 0.05
    temp = activity_color(idx);
else
    temp = 'k';
end

plot(time_axis,zscore(ica_sig(i,:)),temp,'LineWidth',1.5),axis tight;
hold on;
for ii = 1:length(stimulus);
    x1  = [2*ii-1,2*ii]-1/length(movtm);
    y = [-2,-2,10,10];
    fill([x1,fliplr(x1)],y,stimulus(ii), 'FaceAlpha', 0.2,'linestyle','none');
end


ylim([-2,10])
hold off;box on;

% set(gcf, 'PaperUnits', 'centimeters');
% set(gcf, 'PaperPosition', [0 0 9 3]); %x_width=10cm y_width=15cm
% %%%%%%%%%%%%%saveas(gcf,[subfolder '/' test '_ICsignal_' num2str(i) '.eps'],'eps2c'),
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 18 6]); 
set(gcf, 'PaperSize', [18 6]);
nice_plot;pause;
%%%%%%%%%%%%%saveas(gcf,[subfolder '/' test '_ICsignal_' num2str(i) '.pdf']);

close
end

%% plot activity of ROIs found by ICA.
figure,
y = size(cell_sig,1);
imagesc(time_axis,1:y,zscore(cell_sig')');
caxis([-3,3]),colorbar,
hold on,
for ii = 1:length(stimulus);
    x1  = 2*ii-1;x2  = 2*ii;
    line([x1 x1],[0.5 y], 'linewidth', 1.5,'color',stimulus(ii));
    line([x2 x2],[0.5 y], 'linewidth', 1.5,'color',stimulus(ii),'linestyle','-.');
end
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 18 6]); %x_width=1 
nice_plot;
%%%%%%%%%%%%%saveas(gcf,[subfolder '/' test '_Cell_signal.eps'],'epsc'),