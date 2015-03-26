% analyze_manta_data.m

% Analyze manta and PAR data to normalize DO to PAR.

clear all
close all

% folder path where .mat files are kept
folder = '/Users/sandicalhoun/Nighthumps/AnalyzedData';
% list of file names for manta data
mantafiles = {'flint.mat'
    'vostok.mat'
    'malden.mat'
    'millenium.mat'
    'starbuck.mat'};
% list of file names for PAR data
parfiles = {'flint_PAR.mat'
    'vostok_PAR.mat'
    'malden_PAR.mat'
    'millennium_PAR.mat'
    'starbuck_PAR.mat'};

for i = 1:length(mantafiles)
    name = mantafiles{i};
    name = name(1:end-4);
    load(mantafiles{i});
    load(parfiles{i});
    
    % isolate DO and PAR data when PAR >= 1 (daytime)
    analysis.DOXY=interp1(manta.SDN, manta.DOXY, par.SDN);
    isnonan = ~isnan(analysis.DOXY(:,1));
    iuse=inrange(par.PAR,[1 max(par.PAR)]);
    analysis.DOXY=analysis.DOXY(iuse&isnonan,:);
    analysis.SDN=par.SDN(iuse&isnonan,:);
    analysis.PAR=par.PAR(iuse&isnonan,:);
    
    % Shift DO to zero baseline 
    analysis.index=[1:length(analysis.PAR)]';
    mins=min(analysis.DOXY);
    for ii=1:length(mins)
        analysis.DOXYbase(:,ii)=analysis.DOXY(:,ii)-mins(ii);
    end
    
%     plotname=[name,'DOXYanalysis.png'];
%     plotDOXYdata(analysis.index, analysis.DOXYbase, name, plotname);
%     plotname=[name,'PARanalysis.png'];
%     plotPARdata(analysis.index, analysis.PAR, name, plotname);
    
    analysis.intPAR=trapz(analysis.PAR);
    analysis.intDOXY=trapz(analysis.DOXYbase);
    analysis.ratio=analysis.intPAR./analysis.intDOXY;
   
    f1 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    area(analysis.index, analysis.PAR);
    title(name);
    ylabel('PAR [\mumol photons m^-^2 s^-^1]');
    filename=[name,'_PAR_area'];
    saveas(f1, filename, 'png');
    
    f2 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    title(name);
    
    area(analysis.index, analysis.DOXYbase(:,6), 'FaceColor', [0,0.2,0.2]);
    area(analysis.index, analysis.DOXYbase(:,5), 'FaceColor', [0,0.3,0.3]);
    area(analysis.index, analysis.DOXYbase(:,4), 'FaceColor', [0,0.4,0.4]);
    area(analysis.index, analysis.DOXYbase(:,3), 'FaceColor', [0,0.6,0.6]);
    area(analysis.index, analysis.DOXYbase(:,2), 'FaceColor', [0,0.8,0.8]);
    area(analysis.index, analysis.DOXYbase(:,1), 'FaceColor', [0,1,1]);

    ylabel('Oxygen [\mumol kg^-^1]');
    legend('Sensor 6', 'Sensor 5', 'Sensor 4', 'Sensor 3', 'Sensor 2', 'Sensor 1');
    filename=[name,'_DOXY_areas'];
    saveas(f2, filename, 'png');
    
    f_name = [name,'_analysis.mat'];
    
    save(f_name, 'analysis', 'name');
    close all
    
    
    clearvars -except folder mantafiles parfiles
    
    
end
    
    
    
    
    
    
    