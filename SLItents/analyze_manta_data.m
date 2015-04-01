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
    
    imagename=[name,'_PAR.png'];
    plotPARdata(par.SDN,par.PAR,name,imagename);
    imagename=[name,'_DOXY.png'];
    plotDOXYdata(manta.SDN,manta.DOXY,name,imagename);
    
    % Calculate the integrated PAR and DO values for each sensor. Units are
    % umol*s/kg for DOXY and umol/m^2 for PAR. Integral length is converted
    % to seconds to normalize time units.
    analysis.intPAR=trapz(analysis.secs,analysis.PAR);
    analysis.intDOXY=trapz(analysis.secs,analysis.DOXYbase);
    
    % Calculate the ratio of umol PAR absorbed to umol oxygen
    % released. Future analyses could compare benthic cover to this ratio.
    % Units are kg per sqare meter per second.
    analysis.ratio=analysis.intPAR./analysis.intDOXY;
    
    % Plot PAR and DOXY overlaid
   f1 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
   hold on
   [Ax,PAR,DOXY]=plotyy(analysis.hrs,analysis.PAR, [analysis.hrs,analysis.hrs,analysis.hrs,analysis.hrs,...
       analysis.hrs,analysis.hrs], [analysis.DOXYbase(:,1),analysis.DOXYbase(:,2),analysis.DOXYbase(:,3),...
       analysis.DOXYbase(:,4),analysis.DOXYbase(:,5),analysis.DOXYbase(:,6)], 'area', 'plot');
   title(name);
   xlabel('Hours');
   ylabel(Ax(1), 'PAR [\mumol photons m^-^2 s^-^1]');
   ylabel(Ax(2), 'Oxygen [\mumol kg^-^1]');
   ylim(Ax(1), [0, 1400]);
   ylim(Ax(2),[0 70]);
   
   legend('PAR', 'Sensor 1', 'Sensor 2', 'Sensor 3', 'Sensor 4', 'Sensor 5', 'Sensor 6');
   filename=[name,'_DOXY-PAR_overlay.png'];
   saveas(f1, filename, 'png');
   
   % Plot PAR to oxygen ratios
   f2 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
   hold on
   bar(analysis.ratio);
   xlabel('Sensor');
   ylabel('\mumol Photons Absorbed [m^-^2] to Produce 1.0 \mumol Oxygen [kg^-^1]');
   title(name);
   filename=[name,'_PAR:DOXY.png'];
   saveas(f2, filename, 'png');

    f_name = [name,'_analysis.mat'];
    
    save(f_name, 'analysis', 'name');
    close all
    
    
    clearvars -except folder mantafiles parfiles
    
    
end
    
    
    
    
    
    
    