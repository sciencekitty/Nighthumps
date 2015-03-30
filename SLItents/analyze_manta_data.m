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
    analysis.hrs=[1:length(analysis.PAR)]'*5/60;
    analysis.secs=[1:length(analysis.PAR)]'*5*60;
    base=min(analysis.DOXY);
    for ii=1:length(base)
        analysis.DOXYbase(:,ii)=analysis.DOXY(:,ii)-base(ii);
    end
    
    plotPARdata(analysis.hrs,analysis.PAR,name,'test.png');
    plotDOXYdata(analysis.hrs,analysis.DOXYbase,name,'test2.png');
    
    % Calculate the integrated PAR and DO values for each sensor. Units are
    % umol*s/kg for DOXY and umol/m^2 for PAR. Integral length is converted
    % to seconds to normalize time units.
    analysis.intPAR=trapz(analysis.secs,analysis.PAR);
    analysis.intDOXY=trapz(analysis.secs,analysis.DOXYbase);
    
    % Calculate the ratio of umol PAR absorbed to umol oxygen
    % released. Future analyses could compare benthic cover to this ratio.
    % Units are kg per sqare meter per second.
    analysis.ratio=analysis.intPAR./analysis.intDOXY;
   
    % Plot examples of intergrated areas.
    f1 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    area(analysis.hrs, analysis.PAR);
    title(name);
    xlabel('Hours');
    ylabel('PAR [\mumol photons m^-^2 s^-^1]');
    filename=[name,'_PAR_area'];
    saveas(f1, filename, 'png');
    
    f2 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    title(name);
    
    area(analysis.hrs, analysis.DOXYbase(:,6), 'FaceColor', [0,0.2,0.2]);
    area(analysis.hrs, analysis.DOXYbase(:,5), 'FaceColor', [0,0.3,0.3]);
    area(analysis.hrs, analysis.DOXYbase(:,4), 'FaceColor', [0,0.4,0.4]);
    area(analysis.hrs, analysis.DOXYbase(:,3), 'FaceColor', [0,0.6,0.6]);
    area(analysis.hrs, analysis.DOXYbase(:,2), 'FaceColor', [0,0.8,0.8]);
    area(analysis.hrs, analysis.DOXYbase(:,1), 'FaceColor', [0,1,1]);

    ylabel('Oxygen [\mumol kg^-^1]');
    xlabel('Hours');
    legend('Sensor 6', 'Sensor 5', 'Sensor 4', 'Sensor 3', 'Sensor 2', 'Sensor 1');
    filename=[name,'_DOXY_areas'];
    saveas(f2, filename, 'png');
    
%     f3 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
%     hold on
%     title(name);
%     
%     [ax,p1,s1]=plotyy(analysis.index, analysis.PAR, analysis.index, analysis.DOXYbase(:,6),...
%         'area', 'area');
%     p1.FaceColor=[1,1,0];
%     s1.FaceColor=[0,0.2,0.2];
%     s1.FaceAlpha=0.5;
% %     area(analysis.index, analysis.DOXYbase(:,6), 'FaceColor', [0,0.2,0.2]);
%     area(analysis.index, analysis.DOXYbase(:,5), 'FaceColor', [0,0.3,0.3]);
%     area(analysis.index, analysis.DOXYbase(:,4), 'FaceColor', [0,0.4,0.4]);
%     area(analysis.index, analysis.DOXYbase(:,3), 'FaceColor', [0,0.6,0.6]);
%     area(analysis.index, analysis.DOXYbase(:,2), 'FaceColor', [0,0.8,0.8]);
%     area(analysis.index, analysis.DOXYbase(:,1), 'FaceColor', [0,1,1]);
% 
%     legend('PAR', 'Sensor 6', 'Sensor 5', 'Sensor 4', 'Sensor 3', 'Sensor 2', 'Sensor 1');
%     filename=[name,'_DOXY-PAR_areas'];
%     saveas(f3, filename, 'png');
%     
    f_name = [name,'_analysis.mat'];
    
    save(f_name, 'analysis', 'name');
    close all
    
    
    clearvars -except folder mantafiles parfiles
    
    
end
    
    
    
    
    
    
    