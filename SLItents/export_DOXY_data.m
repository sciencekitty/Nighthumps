% export_DOXY_data.m
% Exports anaylzed manta DOXY data to txt file and generates summary
% figures

clear all
close all

% folder path where .mat files are kept
folder = '/Users/sandicalhoun/Nighthumps/';
% list of file names for analyzed data
analysisfiles={'flint_analysis.mat'
    'vostok_analysis.mat'
    'malden_analysis.mat'
    'millennium_analysis.mat'
    'starbuck_analysis.mat'
    'fanning_analysis.mat'
    'jarvis_analysis.mat'
    'kingman_analysis.mat'
    'palmyra_analysis.mat'
    'washington_analysis.mat'};

load('peaks.mat');
load('peaksPAR.mat');

for i = 1:length(analysisfiles)
    load(analysisfiles{i});
    
    % pre-size summary matrix for export. Row vars are
    % meanDOXYmax, stdDOXYmax, meanDOXYmin, stdDOXYmin, meanDDOXYmax,
    % stdDDOXYmax, meanDDOXYmin, stdDDOXYmin, meanDOXY, stdDOXY, meanPARmax, 
    % stdPARmax, meanPAR, stdPAR, intDOXY, intPAR, PAR/DOXY
    summary=zeros(17,6);
    
    for ii=1:6
        summary(1,ii)=mean(cell2mat(peaks.(name).DOXYmax(:,ii)));
        summary(2,ii)=std(cell2mat(peaks.(name).DOXYmax(:,ii)));
        summary(3,ii)=mean(cell2mat(peaks.(name).DOXYmin(:,ii)));
        summary(4,ii)=std(cell2mat(peaks.(name).DOXYmin(:,ii)));
        summary(5,ii)=mean(cell2mat(peaks.(name).dDOXYmax(:,ii)));
        summary(6,ii)=std(cell2mat(peaks.(name).dDOXYmax(:,ii)));
        summary(7,ii)=mean(cell2mat(peaks.(name).dDOXYmin(:,ii)));
        summary(8,ii)=std(cell2mat(peaks.(name).dDOXYmin(:,ii)));
        summary(9,ii)=peaks.(name).means(:,ii);
        summary(10,ii)=peaks.(name).stdevs(:,ii);
        summary(11,ii)=mean(peaksPAR.(name).PARmax);
        summary(12,ii)=std(peaksPAR.(name).PARmax);
        summary(13,ii)=peaksPAR.(name).means;
        summary(14,ii)=peaksPAR.(name).stdevs;
        summary(15,ii)=analysis.intDOXY(:,ii);
        summary(16,ii)=analysis.intPAR;
        summary(17,ii)=analysis.ratio(:,ii);
    end
    
    means.(name).meanDOXY=mean(summary(9,:));
    means.(name).stdDOXY=std(summary(9,:));
    means.(name).meanPAR=mean(summary(13,:));
    means.(name).stdPAR=std(summary(13,:));
    means.(name).meanRatio=mean(summary(17,:));
    means.(name).stdRatio=std(summary(17,:));
    
    rows={'Average Daily Max DO [umol kg^-1]'
        'Stddev (Average Daily Max DO)'
        'Average Daily Min DO [umol kg^-1]'
        'Stddev (Average Daily Min DO)'
        'Average Daily Production Rate [umol kg^-1 min^-1]'
        'Stddev (Average Daily Production Rate)'
        'Average Daily Consumption Rate [umol kg^-1 min^-1]'
        'Stddev (Average Daily Consumption Rate)'
        'Average Total DO [umol kg^-1]'
        'Stddev (Average Timeseries DO)'
        'Average Daily Max PAR [umol photons m^-2 s^-1]'
        'Stddev (Average Daily Max PAR)'
        'Average Total PAR [umol photons m^-2 s^-1]'
        'Stddev (Average Total PAR)'
        'Inegrated DO [umol*sec kg^-1]'
        'Integrated PAR [umol photons m^-2]'
        'umol Photons Absorbed [m^-2] to Produce 1.0 umol Oxygen [kg^-1]'};
    
    vars={'Sensor1'
        'Sensor2'
        'Sensor3'
        'Sensor4'
        'Sensor5'
        'Sensor6'};
        
    summary=array2table(summary,'RowNames',rows,'VariableNames',vars);
    filename=[name,'_summary.txt'];
    writetable(summary,filename,'Delimiter','\t','WriteRowNames',1);
    clearvars -except folder analysisfiles means peaks peaksPAR
             
end

xnames={'flint'
    'vostok'
    'malden'
    'millennium'
    'starbuck'
    'fanning'
    'jarvis'
    'kingman'
    'palmyra'
    'washington'};

stats=zeros(6,length(xnames));

for i=1:length(xnames)
    stats(1,i)=means.(xnames{i}).meanDOXY;
    stats(2,i)=means.(xnames{i}).stdDOXY;
    stats(3,i)=means.(xnames{i}).meanPAR;
    stats(4,i)=means.(xnames{i}).stdPAR;
    stats(5,i)=means.(xnames{i}).meanRatio;
    stats(6,i)=means.(xnames{i}).stdRatio;
end

f1 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
hold on
stem(stats(1,:),'filled','LineStyle','-.');
errorbar(stats(1,:),stats(2,:),'LineStyle','none','Marker','o');
set(gca,'XTickLabel',xnames,'XTick', [1:10], 'XTickLabelRotation', 45,...
    'YGrid', 'on');
ylim([170 210]);
ylabel('Oxygen [\mumol kg^-^1]');
title('Mean DO per Island');
filename=['TotalmeanDOXY.png'];
saveas(f1, filename, 'png');

f2 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
hold on
stem(stats(3,:),'filled','LineStyle','-.');
errorbar(stats(3,:),stats(4,:),'LineStyle','none','Marker','o');
set(gca,'XTickLabel',xnames,'XTick', [1:10], 'XTickLabelRotation', 45,...
    'YGrid', 'on');
ylim([100 350]);
ylabel('PAR [\mumol photons m^-^2 s^-^1]');
title('Mean PAR per Island');
filename=['TotalmeanPAR.png'];
saveas(f2, filename, 'png');

f3 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
hold on
stem(stats(5,:),'filled','LineStyle','-.');
errorbar(stats(5,:),stats(6,:),'LineStyle','none','Marker','o');
set(gca,'XTickLabel',xnames,'XTick', [1:10], 'XTickLabelRotation', 45,...
    'YGrid', 'on');
ylabel('\mumol Photons Absorbed [m^-^2] to Produce 1.0 \mumol Oxygen [kg^-^1]');
title('Average PAR to Oxygen Ratio per Island');
filename=['TotalPAR-DOXYmax.png'];
saveas(f3, filename, 'png');

save('means.mat','means');
