% Export_manta_data.m

% Exports csv file of qc-ed manta data for downstream export.

clear all
close all

% folder path where .mat files are kept
folder = '/Users/sandicalhoun/Nighthumps/AnalyzedData';
% list of file names for manta data
mantafiles = {'flint.mat'
    'vostok.mat'
    'malden.mat'
    'millennium.mat'
    'starbuck.mat'
    'fanning.mat'
    'jarvis.mat'
    'kingman.mat'
    'palmyra.mat'
    'washington.mat'};
% list of file names for PAR data
parfiles = {'flint_PAR.mat'
    'vostok_PAR.mat'
    'malden_PAR.mat'
    'millennium_PAR.mat'
    'starbuck_PAR.mat'
    'fanning_PAR.mat'
    'jarvis_PAR.mat'
    'kingman_PAR.mat'
    'palmyra_PAR.mat'
    'washington_PAR.mat'};

for i = 1:length(mantafiles)
    name = parfiles{i};
    name = name(1:end-8);
    load(mantafiles{i});
    load(parfiles{i});
   
    export.DOXY=interp1(manta.SDN, manta.DOXY, par.SDN);
    export.O2satper=interp1(manta.SDN, manta.O2satper, par.SDN);
    export.TC=interp1(manta.SDN, manta.TC, par.SDN);
    
    % isolate data when PAR >= 1 (daytime)
    isnonan = ~isnan(export.DOXY(:,1));
    iuse=inrange(par.PAR,[1 max(par.PAR)]);
    export.day.DOXY=export.DOXY(iuse&isnonan,:);
    export.day.SDN=par.SDN(iuse&isnonan,:);
    export.day.PAR=par.PAR(iuse&isnonan,:);
    
    isnonan = ~isnan(export.O2satper(:,1));
    export.day.O2satper=export.O2satper(iuse&isnonan,:);
    
    isnonan = ~isnan(export.TC(:,1));
    export.day.TC=export.TC(iuse&isnonan,:);
    
    dayDOXY=array2table(export.day.DOXY);
    filename=[name,'_dayDOXY.txt'];
    writetable(dayDOXY,filename,'Delimiter','\t');
    
    daySDN=array2table(export.day.SDN);
    filename=[name,'_daySDN.txt'];
    writetable(daySDN,filename,'Delimiter','\t');
    
    dayO2satper=array2table(export.day.O2satper);
    filename=[name,'_dayO2satper.txt'];
    writetable(dayO2satper,filename,'Delimiter','\t');
    
    dayTC=array2table(export.day.TC);
    filename=[name,'_dayTC.txt'];
    writetable(dayTC,filename,'Delimiter','\t');
    
    % isolate data when PAR < 1 (night time)
    isnonan = ~isnan(export.DOXY(:,1));
    iuse=inrange(par.PAR,[min(par.PAR) 1], 'includeleft');
    export.night.DOXY=export.DOXY(iuse&isnonan,:);
    export.night.SDN=par.SDN(iuse&isnonan,:);
    export.night.PAR=par.PAR(iuse&isnonan,:);
    
    isnonan = ~isnan(export.O2satper(:,1));
    export.night.O2satper=export.O2satper(iuse&isnonan,:);
    
    isnonan = ~isnan(export.TC(:,1));
    export.night.TC=export.TC(iuse&isnonan,:);
    
    nightDOXY=array2table(export.night.DOXY);
    filename=[name,'_nightDOXY.txt'];
    writetable(nightDOXY,filename,'Delimiter','\t');
    
    nightSDN=array2table(export.night.SDN);
    filename=[name,'_nightSDN.txt'];
    writetable(nightSDN,filename,'Delimiter','\t');
    
    nightO2satper=array2table(export.night.O2satper);
    filename=[name,'_nightO2satper.txt'];
    writetable(nightO2satper,filename,'Delimiter','\t');
    
    nightTC=array2table(export.night.TC);
    filename=[name,'_nightTC.txt'];
    writetable(nightTC,filename,'Delimiter','\t');
    
    f_name=[name,'_export.m'];
    save(f_name,'export');
    clearvars -except mantafiles parfiles
    
end
    
 
    
    
    
    
    