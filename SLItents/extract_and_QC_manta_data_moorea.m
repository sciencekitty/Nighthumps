% extract_and_QC_manta_data.m

% Extract manta data from text file, and then QC the data.

clear all
close all

% folder path where text files are kept
folder = '/Users/sandicalhoun/Nighthumps/SLItents/raw_tent_text_files/';
% list of text file names for manta data
txtfiles = {'Moorea_9_1_11.txt'
    'Moorea_9_5_11.txt'
    'Moorea_9_8_11.txt'
    'Moorea_9_12_11.txt'
    'Moorea_9_14_11.txt'
    'Moorea_9_17_11.txt'};

for i = 1:length(txtfiles)
    island_name = txtfiles{i};
    island_name = island_name(1:end-10);
    switch txtfiles{i}
        case 'Moorea_9_1_11.txt'
            daterange = [datenum(2011,9,2,9,50,0) datenum(2011,9,4,17,25,0)];
        case 'Moorea_9_5_11.txt'
            daterange = [datenum(2011,10,22,8,0,0) datenum(2013,10,24,11,15,0)];
        case 'Moorea_9_8_11.txt'
            daterange = [datenum(2013,10,30,10,0,0) datenum(2013,11,2,8,0,0)];
        case 'Moorea_9_12_11.txt'
            daterange = [datenum(2013,11,5,10,0,0) datenum(2013,11,8,9,30,0)];
        case 'Moorea_9_14_11.txt'
            daterange = [datenum(2013,10,26,10,30,0) datenum(2013,10,29,9,0,0)];
        case 'Moorea_9_17_11.txt'
            daterange = [datenum(2010,11,4,10,0,0) datenum(2010,11,7,13,55,0)];
    end
    
    trex = manta2mat([folder,txtfiles{i}]);
    
    % Data has 0s in there randomly. change it all to NaNs
    trex.DOXY = trex.O2;
    trex.DOXY(trex.DOXY == 0) = NaN;
    trex.O2satper(trex.O2satper == 0) = NaN;
    
    trex.pH = trex.pHinsitu;
    trex.pH(trex.pH == 0) = NaN;
    trex.ORP(trex.ORP == 0) = NaN;
    trex.VpH(trex.VpH == 0) = NaN;
    trex.COND(trex.COND == 0) = NaN;
    
    % Adjust data to set the mean for each sensor to the mean
    % of sensors 1-6 for the first 30 min.
    baseline = nanmean(nanmean(trex.O2satper(1:6,1:6)));
    adj = baseline - nanmean(trex.O2satper,1);
    trex.O2satper = bsxfun(@plus,trex.O2satper,adj);
    baselinesat=nanmean(trex.O2satper,1);
    
    baseline = nanmean(nanmean(trex.pH(1:6,1:6)));
    adj = baseline - nanmean(trex.pH,1);
    trex.pH = bsxfun(@plus,trex.pH,adj);
    baselineph=nanmean(trex.pH,1);
    
    baseline = nanmean(nanmean(trex.ORP(1:6,1:6)));
    adj = baseline - nanmean(trex.ORP,1);
    trex.ORP = bsxfun(@plus,trex.ORP,adj);
    baselineorp=nanmean(trex.ORP,1);
    
    baseline = nanmean(nanmean(trex.TC(1:6,1:6)));
    adj = baseline - nanmean(trex.TC,1);
    trex.TC = bsxfun(@plus,trex.TC,adj);
    baselinetc=nanmean(trex.TC,1);
    
    baseline = nanmean(nanmean(trex.VpH(1:6,1:6)));
    adj = baseline - nanmean(trex.VpH,1);
    trex.VpH = bsxfun(@plus,trex.VpH,adj);
    baselinevph=nanmean(trex.VpH,1);
    
    baseline = nanmean(nanmean(trex.COND(1:6,1:6)));
    adj = baseline - nanmean(trex.COND,1);
    trex.COND = bsxfun(@plus,trex.COND,adj);
    baselinecond=nanmean(trex.COND,1);
    
    % Calculate salinity from conductivity [uS/cm].
    trex.PSAL = SP_from_C(trex.COND/10000, trex.TC, 10);
    % this salinity is kind of unreliable... big spread, and will introduce
    % error into density calculation... maybe just assume constant
    % salinity?
    
    %trex.PSAL(:) = 34.5; % Arbitrarily chose 34.5. Should adjust to salinity 
    % derived from discrete samples at each site later.
    
    trex.DENS = sw_dens(trex.PSAL, trex.TC, 0)/1000;
    
    % Make 20th O2satper 100%, arbitrarily.
%     O2per_offset = 100 - trex.O2satper(20,:);
    
    % presize stats matrices. 

    nanlength = 15;

    DOXYmax = NaN(nanlength,6);
    DOXYmax_locs = NaN(nanlength,6);
    DOXYmin = NaN(nanlength,6);
    DOXYmin_locs = NaN(nanlength,6);
    dDOXYmax = NaN(nanlength,6);
    dDOXYmax_locs = NaN(nanlength,6);
    dDOXYmin = NaN(nanlength,6);
    dDOXYmin_locs = NaN(nanlength,6);
    DOXYmeans = zeros(1,6);
    DOXYstdevs = zeros(1,6);

    pHmax = NaN(nanlength,6);
    pHmax_locs = NaN(nanlength,6);
    pHmin = NaN(nanlength,6);
    pHmin_locs = NaN(nanlength,6);
    dpHmax = NaN(nanlength,6);
    dpHmax_locs = NaN(nanlength,6);
    dpHmin = NaN(nanlength,6);
    dpHmin_locs = NaN(nanlength,6);
    pHmeans = zeros(1,6);
    pHstdevs = zeros(1,6);

    ORPmax = NaN(nanlength,6);
    ORPmax_locs = NaN(nanlength,6);
    ORPmin = NaN(nanlength,6);
    ORPmin_locs = NaN(nanlength,6);
    dORPmax = NaN(nanlength,6);
    dORPmax_locs = NaN(nanlength,6);
    dORPmin = NaN(nanlength,6);
    dORPmin_locs = NaN(nanlength,6);
    ORPmeans = zeros(1,6);
    ORPstdevs = zeros(1,6);

    TCmax = NaN(nanlength,6);
    TCmax_locs = NaN(nanlength,6);
    TCmin = NaN(nanlength,6);
    TCmin_locs = NaN(nanlength,6);
    dTCmax = NaN(nanlength,6);
    dTCmax_locs = NaN(nanlength,6);
    dTCmin = NaN(nanlength,6);
    dTCmin_locs = NaN(nanlength,6);
    TCmeans = zeros(1,6);
    TCstdevs = zeros(1,6);
    
    VpHmax = NaN(nanlength,6);
    VpHmax_locs = NaN(nanlength,6);
    VpHmin = NaN(nanlength,6);
    VpHmin_locs = NaN(nanlength,6);
    dVpHmax = NaN(nanlength,6);
    dVpHmax_locs = NaN(nanlength,6);
    dVpHmin = NaN(nanlength,6);
    dVpHmin_locs = NaN(nanlength,6);
    VpHmeans = zeros(1,6);
    VpHstdevs = zeros(1,6);
    
    CONDmax = NaN(nanlength,6);
    CONDmax_locs = NaN(nanlength,6);
    CONDmin = NaN(nanlength,6);
    CONDmin_locs = NaN(nanlength,6);
    dCONDmax = NaN(nanlength,6);
    dCONDmax_locs = NaN(nanlength,6);
    dCONDmin = NaN(nanlength,6);
    dCONDmin_locs = NaN(nanlength,6);
    CONDmeans = zeros(1,6);
    CONDstdevs = zeros(1,6);
    
    PSALmax = NaN(nanlength,6);
    PSALmax_locs = NaN(nanlength,6);
    PSALmin = NaN(nanlength,6);
    PSALmin_locs = NaN(nanlength,6);
    dPSALmax = NaN(nanlength,6);
    dPSALmax_locs = NaN(nanlength,6);
    dPSALmin = NaN(nanlength,6);
    dPSALmin_locs = NaN(nanlength,6);
    PSALmeans = zeros(1,6);
    PSALstdevs = zeros(1,6);
    
    DENSmax = NaN(nanlength,6);
    DENSmax_locs = NaN(nanlength,6);
    DENSmin = NaN(nanlength,6);
    DENSmin_locs = NaN(nanlength,6);
    dDENSmax = NaN(nanlength,6);
    dDENSmax_locs = NaN(nanlength,6);
    dDENSmin = NaN(nanlength,6);
    dDENSmin_locs = NaN(nanlength,6);
    DENSmeans = zeros(1,6);
    DENSstdevs = zeros(1,6);
        
    for ii = 1:6
        %trex.O2satper(:,ii) = trex.O2satper(:,ii) + O2per_offset(ii);
        trex.DOXY(:,ii) = calcO2sat(trex.TC(:,ii),trex.PSAL(:,ii)).*trex.O2satper(:,ii)./100;   
    end
    
    % interpolate onto 5min intervals
    
    manta.SDN = [daterange(1):datenum(0,0,0,0,5,0):daterange(end)]';
     
    for ii = 1:6
        iuse = inrange(trex.SDN(:,ii), [manta.SDN(1) manta.SDN(end)]);
        manta.TC(:,ii) = interp1(trex.SDN(iuse,ii), trex.TC(iuse,ii), manta.SDN);
        manta.PSAL(:,ii) = interp1(trex.SDN(iuse,ii), trex.PSAL(iuse,ii), manta.SDN);
        manta.DENS(:,ii) = interp1(trex.SDN(iuse,ii), trex.DENS(iuse,ii), manta.SDN);
        manta.pH(:,ii) = interp1(trex.SDN(iuse,ii), trex.pH(iuse,ii), manta.SDN);
        manta.ORP(:,ii) = interp1(trex.SDN(iuse,ii), trex.ORP(iuse,ii), manta.SDN);
        
        % look for non-NaN data
        inonanO = ~isnan(trex.DOXY(:,ii));
        inonanpH = ~isnan(trex.pH(:,ii));
        inonanOrp = ~isnan(trex.ORP(:,ii));
        inonanTC = ~isnan(trex.TC(:,ii));
        inonanVpH = ~isnan(trex.VpH(:,ii));
        inonanCOND = ~isnan(trex.COND(:,ii));
        inonanPSAL = ~isnan(trex.PSAL(:,ii));
        inonanDENS = ~isnan(trex.DENS(:,ii));
        
        totiuse = iuse&inonanO&inonanpH&inonanOrp&inonanTC&inonanVpH&inonanCOND&inonanPSAL&inonanDENS;
        if strcmp(txtfiles{i},'palmyra_manta.txt')==1
            totiuse = iuse&inonanO&inonanpH&inonanOrp&inonanTC&inonanCOND&inonanPSAL&inonanDENS;
        end
        
        manta.DOXY(:,ii) = interp1(trex.SDN(totiuse,ii),trex.DOXY(totiuse,ii), manta.SDN);
        manta.O2satper(:,ii) = interp1(trex.SDN(totiuse,ii),trex.O2satper(totiuse,ii), manta.SDN);
        manta.pH(:,ii) = interp1(trex.SDN(totiuse,ii),trex.pH(totiuse,ii), manta.SDN);
        manta.ORP(:,ii) = interp1(trex.SDN(totiuse,ii),trex.ORP(totiuse,ii), manta.SDN);
        manta.TC(:,ii) = interp1(trex.SDN(totiuse,ii),trex.TC(totiuse,ii), manta.SDN);
        manta.VpH(:,ii) = interp1(trex.SDN(totiuse,ii),trex.VpH(totiuse,ii), manta.SDN);
        manta.COND(:,ii) = interp1(trex.SDN(totiuse,ii),trex.COND(totiuse,ii), manta.SDN);
        manta.PSAL(:,ii) = interp1(trex.SDN(totiuse,ii),trex.PSAL(totiuse,ii), manta.SDN);
        manta.DENS(:,ii) = interp1(trex.SDN(totiuse,ii),trex.DENS(totiuse,ii), manta.SDN);
        
        
        % low pass filter oxygen data
        %*****smooth data with a low pass filter*****
        n = 5; % filter order
        period = 40;% cutoff period. when 1/period = 1, it is half of the sampling rate (butter)
                    % so that means period = 6 is one hour. 30 hours = 180.
        Wn = 1/(period); % cutoff frequency
        [b,a] = butter(n,Wn);
        
        
        manta.DOXY_lpf(:,ii) = filtfilt(b, a, manta.DOXY(:,ii));
        manta.pH_lpf(:,ii) = filtfilt(b, a, manta.pH(:,ii));
        manta.ORP_lpf(:,ii) = filtfilt(b, a, manta.ORP(:,ii));
        manta.TC_lpf(:,ii) = filtfilt(b, a, manta.TC(:,ii));
        manta.VpH_lpf(:,ii) = filtfilt(b, a, manta.VpH(:,ii));
        manta.COND_lpf(:,ii) = filtfilt(b, a, manta.COND(:,ii));
        manta.PSAL_lpf(:,ii) = filtfilt(b, a, manta.PSAL(:,ii));
        manta.DENS_lpf(:,ii) = filtfilt(b, a, manta.DENS(:,ii));
        
        % take derivative.
        manta.dDOXY_lpf(:,ii) = diff(manta.DOXY_lpf(:,ii));
        manta.dpH_lpf(:,ii) = diff(manta.pH_lpf(:,ii));
        manta.dORP_lpf(:,ii) = diff(manta.ORP_lpf(:,ii));
        manta.dTC_lpf(:,ii) = diff(manta.TC_lpf(:,ii));
        manta.dVpH_lpf(:,ii) = diff(manta.VpH_lpf(:,ii));
        manta.dCOND_lpf(:,ii) = diff(manta.COND_lpf(:,ii));
        manta.dPSAL_lpf(:,ii) = diff(manta.PSAL_lpf(:,ii));
        manta.dDENS_lpf(:,ii) = diff(manta.DENS_lpf(:,ii));
        
        % record local maxima and minima of lpf and derivative datasets.
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.DOXY_lpf(:,ii), manta.SDN, nanlength);
        DOXYmax(:,ii)=varmax;
        DOXYmax_locs(:,ii)=max_locs;
        DOXYmin(:,ii)=varmin;
        DOXYmin_locs(:,ii)=min_locs;        
        DOXYmeans(:,ii) = mean(manta.DOXY(:,ii));
        DOXYstdevs(:,ii) = std(manta.DOXY(:,ii));
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.dDOXY_lpf(:,ii), manta.SDN, nanlength);
        dDOXYmax(:,ii)=varmax;
        dDOXYmax_locs(:,ii)=max_locs;
        dDOXYmin(:,ii)=varmin;
        dDOXYmin_locs(:,ii)=min_locs; 
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.pH_lpf(:,ii), manta.SDN, nanlength);
        pHmax(:,ii)=varmax;
        pHmax_locs(:,ii)=max_locs;
        pHmin(:,ii)=varmin;
        pHmin_locs(:,ii)=min_locs;        
        pHmeans(:,ii) = mean(manta.pH(:,ii));
        pHstdevs(:,ii) = std(manta.pH(:,ii));
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.dpH_lpf(:,ii), manta.SDN, nanlength);
        dpHmax(:,ii)=varmax;
        dpHmax_locs(:,ii)=max_locs;
        dpHmin(:,ii)=varmin;
        dpHmin_locs(:,ii)=min_locs;
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.ORP_lpf(:,ii), manta.SDN, nanlength);
        ORPmax(:,ii)=varmax;
        ORPmax_locs(:,ii)=max_locs;
        ORPmin(:,ii)=varmin;
        ORPmin_locs(:,ii)=min_locs;        
        ORPmeans(:,ii) = mean(manta.ORP(:,ii));
        ORPstdevs(:,ii) = std(manta.ORP(:,ii));
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.dORP_lpf(:,ii), manta.SDN, nanlength);
        dORPmax(:,ii)=varmax;
        dORPmax_locs(:,ii)=max_locs;
        dORPmin(:,ii)=varmin;
        dORPmin_locs(:,ii)=min_locs;
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.TC_lpf(:,ii), manta.SDN, nanlength);
        TCmax(:,ii)=varmax;
        TCmax_locs(:,ii)=max_locs;
        TCmin(:,ii)=varmin;
        TCmin_locs(:,ii)=min_locs;        
        TCmeans(:,ii) = mean(manta.TC(:,ii));
        TCstdevs(:,ii) = std(manta.TC(:,ii));
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.dTC_lpf(:,ii), manta.SDN, nanlength);
        dTCmax(:,ii)=varmax;
        dTCmax_locs(:,ii)=max_locs;
        dTCmin(:,ii)=varmin;
        dTCmin_locs(:,ii)=min_locs;
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.VpH_lpf(:,ii), manta.SDN, nanlength);
        VpHmax(:,ii)=varmax;
        VpHmax_locs(:,ii)=max_locs;
        VpHmin(:,ii)=varmin;
        VpHmin_locs(:,ii)=min_locs;        
        VpHmeans(:,ii) = mean(manta.VpH(:,ii));
        VpHstdevs(:,ii) = std(manta.VpH(:,ii));
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.dVpH_lpf(:,ii), manta.SDN, nanlength);
        dVpHmax(:,ii)=varmax;
        dVpHmax_locs(:,ii)=max_locs;
        dVpHmin(:,ii)=varmin;
        dVpHmin_locs(:,ii)=min_locs;
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.COND_lpf(:,ii), manta.SDN, nanlength);
        CONDmax(:,ii)=varmax;
        CONDmax_locs(:,ii)=max_locs;
        CONDmin(:,ii)=varmin;
        CONDmin_locs(:,ii)=min_locs;        
        CONDmeans(:,ii) = mean(manta.COND(:,ii));
        CONDstdevs(:,ii) = std(manta.COND(:,ii));
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.dCOND_lpf(:,ii), manta.SDN, nanlength);
        dCONDmax(:,ii)=varmax;
        dCONDmax_locs(:,ii)=max_locs;
        dCONDmin(:,ii)=varmin;
        dCONDmin_locs(:,ii)=min_locs;
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.PSAL_lpf(:,ii), manta.SDN, nanlength);
        PSALmax(:,ii)=varmax;
        PSALmax_locs(:,ii)=max_locs;
        PSALmin(:,ii)=varmin;
        PSALmin_locs(:,ii)=min_locs;        
        PSALmeans(:,ii) = mean(manta.PSAL(:,ii));
        PSALstdevs(:,ii) = std(manta.PSAL(:,ii));
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.dPSAL_lpf(:,ii), manta.SDN, nanlength);
        dPSALmax(:,ii)=varmax;
        dPSALmax_locs(:,ii)=max_locs;
        dPSALmin(:,ii)=varmin;
        dPSALmin_locs(:,ii)=min_locs;
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.DENS_lpf(:,ii), manta.SDN, nanlength);
        DENSmax(:,ii)=varmax;
        DENSmax_locs(:,ii)=max_locs;
        DENSmin(:,ii)=varmin;
        DENSmin_locs(:,ii)=min_locs;        
        DENSmeans(:,ii) = mean(manta.DENS(:,ii));
        DENSstdevs(:,ii) = std(manta.DENS(:,ii));
        
        [ varmax, max_locs, varmin, min_locs ]...
            = extract_peaks( manta.dDENS_lpf(:,ii), manta.SDN, nanlength);
        dDENSmax(:,ii)=varmax;
        dDENSmax_locs(:,ii)=max_locs;
        dDENSmin(:,ii)=varmin;
        dDENSmin_locs(:,ii)=min_locs;

    end
    
    peaks.(island_name).('DOXYmax') = (DOXYmax);
    peaks.(island_name).('DOXYmin') = (DOXYmin);
    peaks.(island_name).('dDOXYmax') = (dDOXYmax);
    peaks.(island_name).('dDOXYmin') = (dDOXYmin);
    peaks.(island_name).('DOXYmax_locs') = (DOXYmax_locs);
    peaks.(island_name).('DOXYmin_locs') = (DOXYmin_locs);
    peaks.(island_name).('dDOXYmax_locs') = (dDOXYmax_locs);
    peaks.(island_name).('dDOXYmin_locs') = (dDOXYmin_locs);
    peaks.(island_name).('DOXYmeans') = (DOXYmeans);
    peaks.(island_name).('DOXYstdevs') = (DOXYstdevs);
    
    peaks.(island_name).('pHmax') = (pHmax);
    peaks.(island_name).('pHmin') = (pHmin);
    peaks.(island_name).('dpHmax') = (dpHmax);
    peaks.(island_name).('dpHmin') = (dpHmin);
    peaks.(island_name).('pHmax_locs') = (pHmax_locs);
    peaks.(island_name).('pHmin_locs') = (pHmin_locs);
    peaks.(island_name).('dpHmax_locs') = (dpHmax_locs);
    peaks.(island_name).('dpHmin_locs') = (dpHmin_locs);
    peaks.(island_name).('pHmeans') = (pHmeans);
    peaks.(island_name).('pHstdevs') = (pHstdevs);
    
    peaks.(island_name).('ORPmax') = (ORPmax);
    peaks.(island_name).('ORPmin') = (ORPmin);
    peaks.(island_name).('dORPmax') = (dORPmax);
    peaks.(island_name).('dORPmin') = (dORPmin);
    peaks.(island_name).('ORPmax_locs') = (ORPmax_locs);
    peaks.(island_name).('ORPmin_locs') = (ORPmin_locs);
    peaks.(island_name).('dORPmax_locs') = (dORPmax_locs);
    peaks.(island_name).('dORPmin_locs') = (dORPmin_locs);
    peaks.(island_name).('ORPmeans') = (ORPmeans);
    peaks.(island_name).('ORPstdevs') = (ORPstdevs);
    
    peaks.(island_name).('TCmax') = (TCmax);
    peaks.(island_name).('TCmin') = (TCmin);
    peaks.(island_name).('dTCmax') = (dTCmax);
    peaks.(island_name).('dTCmin') = (dTCmin);
    peaks.(island_name).('TCmax_locs') = (TCmax_locs);
    peaks.(island_name).('TCmin_locs') = (TCmin_locs);
    peaks.(island_name).('dTCmax_locs') = (dTCmax_locs);
    peaks.(island_name).('dTCmin_locs') = (dTCmin_locs);
    peaks.(island_name).('TCmeans') = (TCmeans);
    peaks.(island_name).('TCstdevs') = (TCstdevs);
    
    peaks.(island_name).('VpHmax') = (VpHmax);
    peaks.(island_name).('VpHmin') = (VpHmin);
    peaks.(island_name).('dVpHmax') = (dVpHmax);
    peaks.(island_name).('dVpHmin') = (dVpHmin);
    peaks.(island_name).('VpHmax_locs') = (VpHmax_locs);
    peaks.(island_name).('VpHmin_locs') = (VpHmin_locs);
    peaks.(island_name).('dVpHmax_locs') = (dVpHmax_locs);
    peaks.(island_name).('dVpHmin_locs') = (dVpHmin_locs);
    peaks.(island_name).('VpHmeans') = (VpHmeans);
    peaks.(island_name).('VpHstdevs') = (VpHstdevs);
    
    peaks.(island_name).('CONDmax') = (CONDmax);
    peaks.(island_name).('CONDmin') = (CONDmin);
    peaks.(island_name).('dCONDmax') = (dCONDmax);
    peaks.(island_name).('dCONDmin') = (dCONDmin);
    peaks.(island_name).('CONDmax_locs') = (CONDmax_locs);
    peaks.(island_name).('CONDmin_locs') = (CONDmin_locs);
    peaks.(island_name).('dCONDmax_locs') = (dCONDmax_locs);
    peaks.(island_name).('dCONDmin_locs') = (dCONDmin_locs);
    peaks.(island_name).('CONDmeans') = (CONDmeans);
    peaks.(island_name).('CONDstdevs') = (CONDstdevs);
    
    peaks.(island_name).('PSALmax') = (PSALmax);
    peaks.(island_name).('PSALmin') = (PSALmin);
    peaks.(island_name).('dPSALmax') = (dPSALmax);
    peaks.(island_name).('dPSALmin') = (dPSALmin);
    peaks.(island_name).('PSALmax_locs') = (PSALmax_locs);
    peaks.(island_name).('PSALmin_locs') = (PSALmin_locs);
    peaks.(island_name).('dPSALmax_locs') = (dPSALmax_locs);
    peaks.(island_name).('dPSALmin_locs') = (dPSALmin_locs);
    peaks.(island_name).('PSALmeans') = (PSALmeans);
    peaks.(island_name).('PSALstdevs') = (PSALstdevs);
    
    peaks.(island_name).('DENSmax') = (DENSmax);
    peaks.(island_name).('DENSmin') = (DENSmin);
    peaks.(island_name).('dDENSmax') = (dDENSmax);
    peaks.(island_name).('dDENSmin') = (dDENSmin);
    peaks.(island_name).('DENSmax_locs') = (DENSmax_locs);
    peaks.(island_name).('DENSmin_locs') = (DENSmin_locs);
    peaks.(island_name).('dDENSmax_locs') = (dDENSmax_locs);
    peaks.(island_name).('dDENSmin_locs') = (dDENSmin_locs);
    peaks.(island_name).('DENSmeans') = (DENSmeans);
    peaks.(island_name).('DENSstdevs') = (DENSstdevs);

    plotvar = 'dDOXY_lpf';
    
    fsize = 10;
    lwidth = 2;


    f1 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    plot(manta.SDN(2:end), manta.(plotvar)(:,1:6), 'linewidth', lwidth);
    plot(dDOXYmax_locs(:), dDOXYmax(:),'rv','MarkerFaceColor','r');
    plot(dDOXYmin_locs(:), dDOXYmin(:),'rs','MarkerFaceColor','b');
    title(island_name, 'fontsize', fsize);
    ylabel('Derivative LPF Oxygen [\mumol kg^-^1 min^-^1]', 'fontsize', fsize);
%     ylim([150 220]);
    ylim([-2.0 2.0]);
    datetick('x', 'HH:MM');
    legend('1', '2', '3', '4', '5', '6','peaks','troughs','Location','eastoutside');
    set(gca, 'fontsize', fsize);
    
    plotname = [island_name,'_',plotvar,'.eps'];
    saveas(f1, plotname, 'epsc');
    
    plotvar = 'DOXY_lpf';
    
    f2 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    plot(manta.SDN(1:end), manta.(plotvar)(:,1:6), 'linewidth', lwidth);
    plot(DOXYmax_locs(:), DOXYmax(:),'rv','MarkerFaceColor','r');
    plot(DOXYmin_locs(:), DOXYmin(:),'rs','MarkerFaceColor','b');
    title(island_name, 'fontsize', fsize);
    ylabel('LPF Oxygen [\mumol kg^-^1 min^-^1]', 'fontsize', fsize);
%     ylim([150 220]);
%     ylim([-2.0 2.0]);
    datetick('x', 'HH:MM');
    legend('1', '2', '3', '4', '5', '6','peaks','troughs','Location','eastoutside');
    set(gca, 'fontsize', fsize);
    
    plotname = [island_name,'_',plotvar,'.eps'];
    saveas(f2, plotname, 'epsc');
    
    plotvar = 'VpH_lpf';
    
    f3 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    plot(manta.SDN(1:end), manta.(plotvar)(:,1:6), 'linewidth', lwidth);
    plot(VpHmax_locs(:), VpHmax(:),'rv','MarkerFaceColor','r');
    plot(VpHmin_locs(:), VpHmin(:),'rs','MarkerFaceColor','b');
    title(island_name, 'fontsize', fsize);
    ylabel('LPF VpH', 'fontsize', fsize);
%     ylim([150 220]);
    %ylim([-2.0 2.0]);
    datetick('x', 'HH:MM');
    legend('1', '2', '3', '4', '5', '6','peaks','troughs','Location','eastoutside');
    set(gca, 'fontsize', fsize);
    
    plotname = [island_name,'_',plotvar,'.eps'];
    saveas(f3, plotname, 'epsc');
    
    plotvar = 'pH_lpf';
    
    f4 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    plot(manta.SDN(1:end), manta.(plotvar)(:,1:6), 'linewidth', lwidth);
    plot(pHmax_locs(:), pHmax(:),'rv','MarkerFaceColor','r');
    plot(pHmin_locs(:), pHmin(:),'rs','MarkerFaceColor','b');
    title(island_name, 'fontsize', fsize);
    ylabel('LPF pH', 'fontsize', fsize);
%     ylim([150 220]);
%     ylim([-2.0 2.0]);
    datetick('x', 'HH:MM');
    legend('1', '2', '3', '4', '5', '6','peaks','troughs','Location','eastoutside');
    set(gca, 'fontsize', fsize);
    
    plotname = [island_name,'_',plotvar,'.eps'];
    saveas(f4, plotname, 'epsc');
    
    plotvar = 'ORP_lpf';
    
    f5 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    plot(manta.SDN(1:end), manta.(plotvar)(:,1:6), 'linewidth', lwidth);
    plot(ORPmax_locs(:), ORPmax(:),'rv','MarkerFaceColor','r');
    plot(ORPmin_locs(:), ORPmin(:),'rs','MarkerFaceColor','b');
    title(island_name, 'fontsize', fsize);
    ylabel('LPF ORP', 'fontsize', fsize);
%     ylim([150 220]);
%     ylim([-2.0 2.0]);
    datetick('x', 'HH:MM');
    legend('1', '2', '3', '4', '5', '6','peaks','troughs','Location','eastoutside');
    set(gca, 'fontsize', fsize);
    
    plotname = [island_name,'_',plotvar,'.eps'];
    saveas(f5, plotname, 'epsc');
    
    plotvar = 'PSAL_lpf';
    
    f5 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    plot(manta.SDN(1:end), manta.(plotvar)(:,1:6), 'linewidth', lwidth);
    plot(PSALmax_locs(:), PSALmax(:),'rv','MarkerFaceColor','r');
    plot(PSALmin_locs(:), PSALmin(:),'rs','MarkerFaceColor','b');
    title(island_name, 'fontsize', fsize);
    ylabel('LPF Salinity', 'fontsize', fsize);
%     ylim([150 220]);
%     ylim([-2.0 2.0]);
    datetick('x', 'HH:MM');
    legend('1', '2', '3', '4', '5', '6','peaks','troughs','Location','eastoutside');
    set(gca, 'fontsize', fsize);
    
    plotname = [island_name,'_',plotvar,'.eps'];
    saveas(f5, plotname, 'epsc');
    
    plotvar = 'COND_lpf';
    
    f6 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    plot(manta.SDN(1:end), manta.(plotvar)(:,1:6), 'linewidth', lwidth);
    plot(CONDmax_locs(:), CONDmax(:),'rv','MarkerFaceColor','r');
    plot(CONDmin_locs(:), CONDmin(:),'rs','MarkerFaceColor','b');
    title(island_name, 'fontsize', fsize);
    ylabel('LPF Conductivity', 'fontsize', fsize);
%     ylim([150 220]);
%     ylim([-2.0 2.0]);
    datetick('x', 'HH:MM');
    legend('1', '2', '3', '4', '5', '6','peaks','troughs','Location','eastoutside');
    set(gca, 'fontsize', fsize);
    
    plotname = [island_name,'_',plotvar,'.eps'];
    saveas(f6, plotname, 'epsc');
    
    plotvar = 'TC_lpf';
    
    f6 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    plot(manta.SDN(1:end), manta.(plotvar)(:,1:6), 'linewidth', lwidth);
    plot(TCmax_locs(:), TCmax(:),'rv','MarkerFaceColor','r');
    plot(TCmin_locs(:), TCmin(:),'rs','MarkerFaceColor','b');
    title(island_name, 'fontsize', fsize);
    ylabel('LPF Temperature', 'fontsize', fsize);
%     ylim([150 220]);
%     ylim([-2.0 2.0]);
    datetick('x', 'HH:MM');
    legend('1', '2', '3', '4', '5', '6','peaks','troughs','Location','eastoutside');
    set(gca, 'fontsize', fsize);
    
    plotname = [island_name,'_',plotvar,'.eps'];
    saveas(f6, plotname, 'epsc');
    
    plotvar = 'DENS_lpf';
    
    f6 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
    hold on
    plot(manta.SDN(1:end), manta.(plotvar)(:,1:6), 'linewidth', lwidth);
    plot(DENSmax_locs(:), DENSmax(:),'rv','MarkerFaceColor','r');
    plot(DENSmin_locs(:), DENSmin(:),'rs','MarkerFaceColor','b');
    title(island_name, 'fontsize', fsize);
    ylabel('LPF Density', 'fontsize', fsize);
%     ylim([150 220]);
%     ylim([-2.0 2.0]);
    datetick('x', 'HH:MM');
    legend('1', '2', '3', '4', '5', '6','peaks','troughs','Location','eastoutside');
    set(gca, 'fontsize', fsize);
    
    plotname = [island_name,'_',plotvar,'.eps'];
    saveas(f6, plotname, 'epsc');

    f_name = [island_name,'.mat'];
    
    baselineDO = mean(manta.DOXY);
    
    save(f_name, 'manta', 'island_name', 'baselinesat', 'baselineDO');
    close all
    
    
    clearvars -except folder txtfiles peaks
    
    
end

save('peaks.mat','peaks');





