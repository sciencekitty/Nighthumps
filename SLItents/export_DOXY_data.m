% export_DOXY_data.m
% Exports anaylzed manta DOXY data to txt file and generates summary
% figures

clear all
close all

% folder path where .mat files are kept
folder = '/Users/sandicalhoun/Nighthumps/AnalyzedData';
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

for i = 1:length(analysisfiles)
    load(analysisfiles{i}); 
   
    rows={'Sensor1'
        'Sensor2'
        'Sensor3'
        'Sensor4'
        'Sensor5'
        'Sensor6'};
        
    summary=struct2table(analysis.daily);
    summary.Properties.RowNames=rows;
    filename=[name,'_dailySummary.txt'];
    writetable(summary,filename,'Delimiter','\t','WriteRowNames',1);
    
    prodrate=array2table([(peaks.(name).dDOXYmax);exceltime(datetime(peaks.(name).dDOXYmax_locs,...
        'ConvertFrom','datenum'),'1904')],'VariableNames',rows);
    filename=[name,'_dailyProduction.txt'];
    writetable(prodrate,filename,'Delimiter','\t');
    
    consrate=array2table([(peaks.(name).dDOXYmin);exceltime(datetime(peaks.(name).dDOXYmin_locs,...
        'ConvertFrom','datenum'),'1904')],'VariableNames',rows);
    filename=[name,'_dailyConsumption.txt'];
    writetable(consrate,filename,'Delimiter','\t');


    clearvars -except folder analysisfiles means peaks peaksPAR
             
end

