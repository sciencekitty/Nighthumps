% extract_and_QC_manta_data.m
% Extract manta data from text file, and then QC the data.

clear all
close all

% folder path where text files are kept
folder = '/Users/sandicalhoun/Documents/MATLAB/NLItents/raw_tent_text_files/';
% list of text file names for manta data
txtfiles = {'flint_manta.txt'
    'vostok_manta.txt'
    'malden_manta.txt'
    'millenium_manta.txt'
    'starbuck_manta.txt'};

% txtfiles = {'starbuck_manta.txt'};

for i = 1:length(txtfiles)
    island_name = txtfiles{i};
    island_name = island_name(1:end-10);
%     switch txtfiles{i}
%         case 'flint_manta.txt'
%             daterange = [datenum(2013,10,18,11,0,0) datenum(2013,10,21,8,30,0)];
%         case 'vostok_manta.txt'
%             daterange = [datenum(2013,10,22,8,0,0) datenum(2013,10,24,11,15,0)];
%         case 'malden_manta.txt'
%             daterange = [datenum(2013,10,30,10,0,0) datenum(2013,11,2,8,0,0)];
%         case 'millenium_manta.txt'
%             daterange = [datenum(2013,11,5,10,0,0) datenum(2013,11,8,9,30,0)];
%         case 'starbuck_manta.txt'
%             daterange = [datenum(2013,10,26,10,30,0) datenum(2013,10,29,9,0,0)];
%     end
    
    filepath = [folder,txtfiles{i}];
    [trex,SDNend] = manta2matMOD(filepath);
    trex.DOXY = trex.O2;
    trex.PSAL = trex.COND;
    
    % Oxygen has 0s in there randomly. change it all to NaNs
    trex.DOXY(trex.DOXY == 0) = NaN;
    trex.O2satper(trex.O2satper == 0) = NaN;
    
    % Calculate salinity from conductivity [uS/cm].
    trex.PSAL = SP_from_C(trex.COND/10000, trex.TC, 10);
    % this salinity is kind of unreliable... big spread, and will introduce
    % error into density calculation... maybe just assume constant
    % salinity?
    
    trex.PSAL(:) = 34.5; % Arbitrarily chose 34.5. Should adjust to salinity 
    % derived from discrete samples at each site later.
    
    trex.DENS = sw_dens(trex.PSAL, trex.TC, 0)/1000;
    
    % Make 20th O2satper 100%, arbitrarily.
    O2per_offset = 100 - trex.O2satper(20,:);
    for ii = 1:8
        trex.O2satper(:,ii) = trex.O2satper(:,ii) + O2per_offset(ii);
        trex.DOXY(:,ii) = calcO2sat(trex.TC(:,ii),trex.PSAL(:,ii)).*trex.O2satper(:,ii)./100;   
    end
    
    % interpolate onto 5min intervals
    
%      manta.SDN = [daterange(1):datenum(0,0,0,0,5,0):daterange(end)]';
    
    % presize stats matrix
    stats.(island_name) = NaN(6,10);
    
    manta.SDN = trex.SDN(1:SDNend,1);
    
    for ii = 1:6
        
        manta.TC(:,ii) = trex.TC(1:SDNend,ii);
        manta.PSAL(:,ii) = trex.PSAL(1:SDNend,ii);
        manta.DENS(:,ii) = trex.DENS(1:SDNend,ii);
        manta.pH(:,ii) = trex.pHinsitu(1:SDNend,ii);
        manta.DOXY(:,ii) = trex.DOXY(1:SDNend,ii);
        manta.O2satper(:,ii) = trex.O2satper(1:SDNend,ii);
        
%         iuse = inrange(trex.SDN(:,ii), [manta.SDN(1) manta.SDN(end)]);
%         manta.TC(:,ii) = interp1(trex.SDN(iuse,ii), trex.TC(iuse,ii), manta.SDN);
%         manta.PSAL(:,ii) = interp1(trex.SDN(iuse,ii), trex.PSAL(iuse,ii), manta.SDN);
%         manta.DENS(:,ii) = interp1(trex.SDN(iuse,ii), trex.DENS(iuse,ii), manta.SDN);
%         manta.pH(:,ii) = interp1(trex.SDN(iuse,ii), trex.pHinsitu(iuse,ii), manta.SDN);
        
        % look for non-NaN oxygen data
%         inonan = ~isnan(trex.DOXY(:,ii));
%         manta.DOXY(:,ii) = interp1(trex.SDN(inonan,ii), trex.DOXY(inonan,ii), manta.SDN);
%         manta.O2satper(:,ii) = interp1(trex.SDN(inonan,ii), trex.O2satper(inonan,ii), manta.SDN);
        
        
        % low pass filter oxygen data
        %*****smooth data with a low pass filter*****
        n1 = 5; % filter order
        n2 = 5;
        period1 = 80;% cutoff period. when 1/period = 1, it is half of the sampling rate (butter)
        period2 = 24;% so that means period = 6 is one hour. 30 hours = 180
                   
        Wn1 = 1/period1; % cutoff frequency
        Wn2 = 1/period2;
        
        [b,a] = butter(n1,Wn1);
        [d,c] = butter(n2,Wn2);
        
        
        manta.DOXY_lpf(:,ii) = filtfilt(b, a, manta.DOXY(:,ii));
        
        manta.DOXY_runavg(:,ii) = runmean(manta.DOXY(:,ii),3);
        % take derivative.
        manta.dDOXY_lpf(:,ii) = diff(manta.DOXY_lpf(:,ii));
        % recored peak heights of dDOXY.
        steg = findpeaks(manta.DOXY_lpf(:,ii),'MINPEAKHEIGHT',0.02);
        stats.(island_name)(ii,1:length(steg)) = steg;
    
        % set baseline for all DO readings to the global min for all sensors
        [baseline,ij] = min2(manta.DOXY);
        adj=min2(manta.DOXY(:,ii))-baseline;
        adj2 = zeros(size(manta.DOXY));
        adj2(:,ii)=manta.DOXY(:,ii)-adj;
        
        %average all adjusted DO sensor data
        manta.DOXY_ave=mean(adj2,2);
    
        %normalize DO reading by two methods
        base = mean(manta.DOXY);
  
        manta.DOXY_norm=manta.DOXY(:,ii)/base(ii);
        stdev=std(manta.DOXY(:,ii));
        manta.DOXY_norm2=(manta.DOXY(:,ii)-base(ii))/stdev;
    end
    
    %average all normalized DO sensor data
    manta.DOXY_NormAVE=mean(manta.DOXY_norm,2);
    manta.DOXY_Norm2AVE=mean(manta.DOXY_norm2,2);
    
            
    %Subtract lpf O2 signal from raw signal
    manta.DOXY_AVElpf = filtfilt(b, a, manta.DOXY_ave);
    manta.diffDOXY_ave = manta.DOXY_ave - manta.DOXY_AVElpf;
    manta.diffDOXY_AVElpf = filtfilt(d, c, manta.diffDOXY_ave);
    
    manta.DOXY_NormAVElpf = filtfilt(b, a, manta.DOXY_NormAVE);
    manta.diffDOXY_NormAVE = manta.DOXY_NormAVE - manta.DOXY_NormAVElpf;
    manta.diffDOXY_NormAVElpf = filtfilt(d, c, manta.diffDOXY_NormAVE);
    
    manta.DOXY_Norm2AVElpf = filtfilt(b, a, manta.DOXY_Norm2AVE);
    manta.diffDOXY_Norm2AVE = manta.DOXY_Norm2AVE - manta.DOXY_Norm2AVElpf;
    manta.diffDOXY_Norm2AVElpf = filtfilt(d, c, manta.diffDOXY_Norm2AVE);
    
    
        
%     f1 = figure;
%     hold
%     plot(manta.SDN, manta.DOXY_ave);
%     plot(manta.SDN, manta.DOXY_AVElpf);
%     plot(manta.SDN, manta.diffDOXY_ave);
%     plot(manta.SDN, manta.diffDOXY_AVElpf);
%     title(island_name);
%     ylabel('Baseline Adjusted DOXY');
%     datetick('x', 'mm/dd');
%     filename=[island_name,'_baseline'];
%     saveas(f1, filename, 'png');
%     
%     f2 = figure;
%     hold
%     plot(manta.SDN, manta.DOXY_NormAVE);
%     plot(manta.SDN, manta.DOXY_NormAVElpf);
%     plot(manta.SDN, manta.diffDOXY_NormAVE);
%     plot(manta.SDN, manta.diffDOXY_NormAVElpf);
%     title(island_name);
%     ylabel('Mean Normalized DOXY');
%     datetick('x', 'mm/dd');
%     filename=[island_name,'_norm'];
%     saveas(f2, filename, 'png');
%     
%     f3 = figure;
%     hold
%     plot(manta.SDN, manta.DOXY_Norm2AVE);
%     plot(manta.SDN, manta.DOXY_Norm2AVElpf);
%     plot(manta.SDN, manta.diffDOXY_Norm2AVE);
%     plot(manta.SDN, manta.diffDOXY_Norm2AVElpf);
%     title(island_name);
%     ylabel('Mean and StDev Normalized DOXY');
%     datetick('x', 'mm/dd');
%     filename=[island_name,'_norm2'];
%     saveas(f3, filename, 'png');
   
%     plotvar = {'diffDOXY_lpf'
%         'DOXY' 
%         'DOXY_lpf'
%         'diffDOXY'
%         };   
%     
%     for p = 1:length(plotvar)
%         ymax = ceil(max2(manta.(plotvar{p})));
%         ymin = floor(min2(manta.(plotvar{p})));
%         plotTentData(plotvar{p}, manta, island_name, ymax, ymin);
%     end
%     
%     ymax = ceil(max2(manta.AVE));
%     ymin = floor(min2(manta.AVE));
%     plotTentDataPAR(manta.AVE,manta,island_name,ymax,ymin);
    
% 
%     figure
%     plot(manta.SDN, manta.DOXY_lpf);
%     title(txtfiles{i});
%     ylabel('Filtered Oxygen');
% %     ylim([150 220]);
%     datetick('x', 'mm/dd');
%     
%     pause

    plotvar = 'dDOXY_lpf';
    
    fsize = 25;
    lwidth = 2;


    f1 = figure('units', 'inch', 'position', [1 1 12 8], 'visible', 'off');
    plot(manta.SDN(2:end), manta.(plotvar)(:,1:6), 'linewidth', lwidth);
    title(island_name, 'fontsize', fsize);
    ylabel('Derivative LPF Oxygen [\mumol/kg]', 'fontsize', fsize);
%     ylim([150 220]);
    ylim([-0.6 0.6]);
    datetick('x', 'mm/dd');
    legend('1', '2', '3', '4', '5', '6');
    set(gca, 'fontsize', fsize);
    
    plotname = [island_name,'_',plotvar,'MOD.png'];
    saveas(f1, plotname);
    
    %now find peaks in derivative plot.
 
    f_name = [island_name,'MOD.mat'];
    
    save(f_name, 'manta', 'island_name');
    close all
    
    
    clearvars -except folder txtfiles stats
    
    
end





