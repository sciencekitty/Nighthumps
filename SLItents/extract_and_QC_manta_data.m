% extract_and_QC_manta_data.m

% Extract manta data from text file, and then QC the data.



clear all
close all

% folder path where text files are kept
folder = '/Users/sandicalhoun/Nighthumps/SLItents/raw_tent_text_files/';
% list of text file names for manta data
txtfiles = {'flint_manta.txt'
    'vostok_manta.txt'
    'malden_manta.txt'
    'millennium_manta.txt'
    'starbuck_manta.txt'
    'fanning_manta.txt'
    'jarvis_manta.txt'
    'kingman_manta.txt'
    'kiritimati_manta.txt'
    'palmyra_manta.txt'
    'washington_manta.txt'};

for i = 1:length(txtfiles)
    island_name = txtfiles{i};
    island_name = island_name(1:end-10);
    switch txtfiles{i}
        case 'flint_manta.txt'
            daterange = [datenum(2013,10,18,11,0,0) datenum(2013,10,21,8,30,0)];
        case 'vostok_manta.txt'
            daterange = [datenum(2013,10,22,8,0,0) datenum(2013,10,24,11,15,0)];
        case 'malden_manta.txt'
            daterange = [datenum(2013,10,30,10,0,0) datenum(2013,11,2,8,0,0)];
        case 'millennium_manta.txt'
            daterange = [datenum(2013,11,5,10,0,0) datenum(2013,11,8,9,30,0)];
        case 'starbuck_manta.txt'
            daterange = [datenum(2013,10,26,10,30,0) datenum(2013,10,29,9,0,0)];
        case 'fanning_manta.txt'
            daterange = [datenum(2010,11,4,10,0,0) datenum(2010,11,7,13,55,0)];
        case 'jarvis_manta.txt'
            daterange = [datenum(2010,11,12,10,30,0) datenum(2010,11,14,15,0,0)];
        case 'kingman_manta.txt'
            daterange = [datenum(2010,10,30,10,40,0) datenum(2010,11,2,12,20,0)];
        case 'kiritimati_manta.txt'
            daterange = [datenum(2010,11,20,11,5,0) datenum(2010,11,21,11,5,0)];
        case 'palmyra_manta.txt'
            daterange = [datenum(2010,10,25,14,0,0) datenum(2010,10,28,13,15,0)];
        case 'washington_manta.txt'
            daterange = [datenum(2010,11,8,10,45,0) datenum(2010,11,10,12,45,0)];
    end
    
    
    trex = manta2mat([folder,txtfiles{i}]);
    trex.DOXY = trex.O2;
    
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
    for ii = 1:6
        trex.O2satper(:,ii) = trex.O2satper(:,ii) + O2per_offset(ii);
        trex.DOXY(:,ii) = calcO2sat(trex.TC(:,ii),trex.PSAL(:,ii)).*trex.O2satper(:,ii)./100;   
    end
    
    % interpolate onto 5min intervals
    
    manta.SDN = [daterange(1):datenum(0,0,0,0,5,0):daterange(end)]';
    
    
    % presize stats matrices. Means are daily means for sensors 1-6 (columns) across 
    % DOXYmax, DOXYmin, dDOXYmax, and dDOXYmin (rows).
    
    DOXYmax = {1,6};
    DOXYmax_locs = {1,6};
    DOXYmin = {1,6};
    DOXYmin_locs = {1,6};
    dDOXYmax = {1,6};
    dDOXYmax_locs = {1,6};
    dDOXYmin = {1,6};
    dDOXYmin_locs = {1,6};
    means = zeros(1,6);
    stdevs = zeros(1,6);

    
    for ii = 1:6
        iuse = inrange(trex.SDN(:,ii), [manta.SDN(1) manta.SDN(end)]);
        manta.TC(:,ii) = interp1(trex.SDN(iuse,ii), trex.TC(iuse,ii), manta.SDN);
        manta.PSAL(:,ii) = interp1(trex.SDN(iuse,ii), trex.PSAL(iuse,ii), manta.SDN);
        manta.DENS(:,ii) = interp1(trex.SDN(iuse,ii), trex.DENS(iuse,ii), manta.SDN);
        
        % look for non-NaN oxygen data
        inonan = ~isnan(trex.DOXY(:,ii));
        manta.DOXY(:,ii) = interp1(trex.SDN(iuse&inonan,ii), trex.DOXY(iuse&inonan,ii), manta.SDN);
        manta.O2satper(:,ii) = interp1(trex.SDN(iuse&inonan,ii), trex.O2satper(iuse&inonan,ii), manta.SDN);
        
        % low pass filter oxygen data
        %*****smooth data with a low pass filter*****
        n = 5; % filter order
        period = 80;% cutoff period. when 1/period = 1, it is half of the sampling rate (butter)
                    % so that means period = 6 is one hour. 30 hours = 180.
        Wn = 1/(period); % cutoff frequency
        [b,a] = butter(n,Wn);
        
        
        manta.DOXY_lpf(:,ii) = filtfilt(b, a, manta.DOXY(:,ii));
        
        manta.DOXY_runavg(:,ii) = runmean(manta.DOXY(:,ii),3);
        % take derivative.
        manta.dDOXY_lpf(:,ii) = diff(manta.DOXY_lpf(:,ii));
        % recored local maxima and minima of DOXY and dDOXY.
        [steg, locs] = findpeaks(manta.DOXY_lpf(:,ii),'MinPeakDistance',datenum(0,0,0,6,0,0),...
            'MinPeakProminence', 1.0);
        DOXYmax{1,ii} = steg;
        DOXYmax_locs{1,ii} = locs;
        
        mins = -manta.DOXY_lpf(:,ii);
        [steg, locs] = findpeaks(mins,'MinPeakDistance',datenum(0,0,0,6,0,0),...
            'MinPeakProminence', 1.0);
        DOXYmin{1,ii} = -steg;
        DOXYmin_locs{1,ii} = locs;
        
        [steg, locs] = findpeaks(manta.dDOXY_lpf(:,ii),'MinPeakDistance',datenum(0,0,0,6,0,0),...
            'MinPeakProminence', 0.05);
        dDOXYmax{1,ii} = steg;
        dDOXYmax_locs{1,ii} = locs;
        
        mins = -manta.dDOXY_lpf(:,ii);
        [steg, locs] = findpeaks(mins,'MinPeakDistance',datenum(0,0,0,6,0,0),...
            'MinPeakProminence', 0.05);
        dDOXYmin{1,ii} = -steg; 
        dDOXYmin_locs{1,ii} = locs;
        
        means(:,ii) = mean(manta.DOXY(:,ii));
        stdevs(:,ii) = std(manta.DOXY(:,ii));
            
        
    end
    
    peaks.(island_name).('DOXYmax') = (DOXYmax);
    peaks.(island_name).('DOXYmin') = (DOXYmin);
    peaks.(island_name).('dDOXYmax') = (dDOXYmax);
    peaks.(island_name).('dDOXYmin') = (dDOXYmin);
    peaks.(island_name).('DOXYmax_locs') = (DOXYmax_locs);
    peaks.(island_name).('DOXYmin_locs') = (DOXYmin_locs);
    peaks.(island_name).('dDOXYmax_locs') = (dDOXYmax_locs);
    peaks.(island_name).('dDOXYmin_locs') = (dDOXYmin_locs);
    peaks.(island_name).('means') = (means);
    peaks.(island_name).('stdevs') = (stdevs);

   
    plotvar = 'dDOXY_lpf';
    
    fsize = 10;
    lwidth = 2;


    f1 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    plot(manta.SDN(2:end), manta.(plotvar)(:,1:6), 'linewidth', lwidth);
    plot(manta.SDN(dDOXYmax_locs{1}), dDOXYmax{1},'rv','MarkerFaceColor','r');
    plot(manta.SDN(dDOXYmin_locs{1}), dDOXYmin{1},'rs','MarkerFaceColor','b');
    title(island_name, 'fontsize', fsize);
    ylabel('Derivative LPF Oxygen [\mumol kg^-^1 min^-^1]', 'fontsize', fsize);
%     ylim([150 220]);
    ylim([-2.0 2.0]);
    datetick('x', 'HH:MM');
    legend('1', '2', '3', '4', '5', '6','peaks','troughs','Location','eastoutside');
    set(gca, 'fontsize', fsize);
    
    plotname = [island_name,'_',plotvar,'.png'];
    saveas(f1, plotname);
    %movefile(plotname, 'plots', 'f');
    
    plotvar = 'DOXY_lpf';
    
    f2 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    plot(manta.SDN(1:end), manta.(plotvar)(:,1:6), 'linewidth', lwidth);
    plot(manta.SDN(DOXYmax_locs{1}), DOXYmax{1},'rv','MarkerFaceColor','r');
    plot(manta.SDN(DOXYmin_locs{1}), DOXYmin{1},'rs','MarkerFaceColor','b');
    title(island_name, 'fontsize', fsize);
    ylabel('LPF Oxygen [\mumol kg^-^1]', 'fontsize', fsize);
    ylim([140 220]);
%     ylim([-0.6 0.6]);
    datetick('x', 'HH:MM');
    legend('1', '2', '3', '4', '5', '6', 'peaks', 'troughs','Location','eastoutside');
    set(gca, 'fontsize', fsize);
    
    plotname = [island_name,'_',plotvar,'.png'];
    saveas(f2, plotname);

 
    f_name = [island_name,'.mat'];
    
    save(f_name, 'manta', 'island_name');
    close all
    
    
    clearvars -except folder txtfiles peaks
    
    
end

save('peaks.mat','peaks');





