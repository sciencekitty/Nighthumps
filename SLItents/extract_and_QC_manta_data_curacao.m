% extract_and_QC_manta_data.m

% Extract manta data from text file, and then QC the data.
% Cover data translated into numerical data. 
% 1 = Coral
% 2 = Algae
% 3 = Sand
% 4 = Ambient

clear all
close all

% folder path where text files are kept
folder = '/Users/Sandi/Documents/Nighthumps/SLItents/raw_tent_text_files/';
% list of text file names for manta data
txtfiles = {'Carmabi052515.txt'
    'Carmabi051715.txt'
    'Carmabi051815.txt'
    'Carmabi051915.txt'
    'Carmabi052015.txt'
    'WaterFactory050715.txt'
    'WaterFactory041415.txt'
    'CCA061615.txt'
    'CuracaoTank117.txt'
    'CuracaoTank316.txt'
    'CuracaoTank44.txt'
    'CuracaoTank34.txt'
    'CuracaoTank513.txt'
    'CuracaoTank314.txt'};

% Trimmed the first 2 hours off the start and end of each dataset to reduce
% variability
for i = 1:length(txtfiles)
    island_name = txtfiles{i};
    island_name = island_name(1:end-4);
    switch txtfiles{i}
        case 'Carmabi052515.txt'
            daterange = [datenum(2015,5,23,21,37,0) datenum(2015,5,25,3,39,0)];
        case 'Carmabi051715.txt'
            daterange = [datenum(2015,5,17,21,04,0) datenum(2015,5,18,8,56,0)];
        case 'Carmabi051815.txt'
            daterange = [datenum(2015,5,18,21,17,0) datenum(2015,5,19,9,56,0)];
        case 'Carmabi051915.txt'
            daterange = [datenum(2015,5,19,19,17,0) datenum(2015,5,20,9,34,0)];
        case 'Carmabi052015.txt'
            daterange = [datenum(2015,5,20,20,17,0) datenum(2015,5,21,7,44,0)];
        case 'WaterFactory050715.txt'
            daterange = [datenum(2015,5,7,11,0,0) datenum(2015,5,12,10,30,0)];
        case 'WaterFactory041415.txt'
            daterange = [datenum(2015,4,14,16,0,0) datenum(2015,4,16,10,0,0)];
        case 'CCA061615.txt'
            daterange = [datenum(2015,6,16,15,36,0) datenum(2015,6,17,15,48,0)];
        case 'CuracaoTank117.txt'
            daterange = [datenum(2015,5,23,21,52,0) datenum(2015,5,24,12,14,0)];
        case 'CuracaoTank316.txt'
            daterange = [datenum(2015,5,10,16,22,0) datenum(2015,5,11,3,30,0)];
        case 'CuracaoTank44.txt'
            daterange = [datenum(2015,4,28,16,59,0) datenum(2015,4,29,7,44,0)];
        case 'CuracaoTank34.txt'
            daterange = [datenum(2015,4,28,15,15,0) datenum(2015,4,29,8,15,0)];
        case 'CuracaoTank513.txt'
            daterange = [datenum(2015,5,7,14,57,0) datenum(2015,5,8,1,18,0)];
        case 'CuracaoTank314.txt'
            daterange = [datenum(2015,5,8,17,30,0) datenum(2015,5,9,7,50,0)];
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
    
    if strcmp(island_name,'CuracaoTank316')==1 || strcmp(island_name,'CuracaoTank44')==1 || strcmp(island_name,'CuracaoTank513')==1
        trex.PSAL(1:length(trex.DOXY),1) = 34.5;
    else
        trex.PSAL = SP_from_C(trex.COND/10000, trex.TC, 10);
    end
    
    trex.DENS = sw_dens(trex.PSAL, trex.TC, 0)/1000;
    
    % presize stats matrices. 

%     nanlength = 15;
%     sensors = 1;
% 
%     DOXYmax = NaN(nanlength,sensors);
%     DOXYmax_locs = NaN(nanlength,sensors);
%     DOXYmin = NaN(nanlength,sensors);
%     DOXYmin_locs = NaN(nanlength,sensors);
%     dDOXYmax = NaN(nanlength,sensors);
%     dDOXYmax_locs = NaN(nanlength,sensors);
%     dDOXYmin = NaN(nanlength,sensors);
%     dDOXYmin_locs = NaN(nanlength,sensors);
%     DOXYmeans = zeros(1,sensors);
%     DOXYstdevs = zeros(1,sensors);
% 
%     pHmax = NaN(nanlength,sensors);
%     pHmax_locs = NaN(nanlength,sensors);
%     pHmin = NaN(nanlength,sensors);
%     pHmin_locs = NaN(nanlength,sensors);
%     dpHmax = NaN(nanlength,sensors);
%     dpHmax_locs = NaN(nanlength,sensors);
%     dpHmin = NaN(nanlength,sensors);
%     dpHmin_locs = NaN(nanlength,sensors);
%     pHmeans = zeros(1,sensors);
%     pHstdevs = zeros(1,sensors);
% 
%     ORPmax = NaN(nanlength,sensors);
%     ORPmax_locs = NaN(nanlength,sensors);
%     ORPmin = NaN(nanlength,sensors);
%     ORPmin_locs = NaN(nanlength,sensors);
%     dORPmax = NaN(nanlength,sensors);
%     dORPmax_locs = NaN(nanlength,sensors);
%     dORPmin = NaN(nanlength,sensors);
%     dORPmin_locs = NaN(nanlength,sensors);
%     ORPmeans = zeros(1,sensors);
%     ORPstdevs = zeros(1,sensors);
% 
%     TCmax = NaN(nanlength,sensors);
%     TCmax_locs = NaN(nanlength,sensors);
%     TCmin = NaN(nanlength,sensors);
%     TCmin_locs = NaN(nanlength,sensors);
%     dTCmax = NaN(nanlength,sensors);
%     dTCmax_locs = NaN(nanlength,sensors);
%     dTCmin = NaN(nanlength,sensors);
%     dTCmin_locs = NaN(nanlength,sensors);
%     TCmeans = zeros(1,sensors);
%     TCstdevs = zeros(1,sensors);
%     
%     VpHmax = NaN(nanlength,sensors);
%     VpHmax_locs = NaN(nanlength,sensors);
%     VpHmin = NaN(nanlength,sensors);
%     VpHmin_locs = NaN(nanlength,sensors);
%     dVpHmax = NaN(nanlength,sensors);
%     dVpHmax_locs = NaN(nanlength,sensors);
%     dVpHmin = NaN(nanlength,sensors);
%     dVpHmin_locs = NaN(nanlength,sensors);
%     VpHmeans = zeros(1,sensors);
%     VpHstdevs = zeros(1,sensors);
%     
%     CONDmax = NaN(nanlength,sensors);
%     CONDmax_locs = NaN(nanlength,sensors);
%     CONDmin = NaN(nanlength,sensors);
%     CONDmin_locs = NaN(nanlength,sensors);
%     dCONDmax = NaN(nanlength,sensors);
%     dCONDmax_locs = NaN(nanlength,sensors);
%     dCONDmin = NaN(nanlength,sensors);
%     dCONDmin_locs = NaN(nanlength,sensors);
%     CONDmeans = zeros(1,sensors);
%     CONDstdevs = zeros(1,sensors);
%     
%     PSALmax = NaN(nanlength,sensors);
%     PSALmax_locs = NaN(nanlength,sensors);
%     PSALmin = NaN(nanlength,sensors);
%     PSALmin_locs = NaN(nanlength,sensors);
%     dPSALmax = NaN(nanlength,sensors);
%     dPSALmax_locs = NaN(nanlength,sensors);
%     dPSALmin = NaN(nanlength,sensors);
%     dPSALmin_locs = NaN(nanlength,sensors);
%     PSALmeans = zeros(1,sensors);
%     PSALstdevs = zeros(1,sensors);
%     
%     DENSmax = NaN(nanlength,sensors);
%     DENSmax_locs = NaN(nanlength,sensors);
%     DENSmin = NaN(nanlength,sensors);
%     DENSmin_locs = NaN(nanlength,sensors);
%     dDENSmax = NaN(nanlength,sensors);
%     dDENSmax_locs = NaN(nanlength,sensors);
%     dDENSmin = NaN(nanlength,sensors);
%     dDENSmin_locs = NaN(nanlength,sensors);
%     DENSmeans = zeros(1,sensors);
%     DENSstdevs = zeros(1,sensors);
        
    trex.DOXY = calcO2sat(trex.TC,trex.PSAL).*trex.O2satper./100;   

    
    % interpolate onto 1min, 5min or 15min intervals
    
    if strcmp(island_name,'WaterFactory050715')==1
        manta.SDN = [daterange(1):datenum(0,0,0,0,5,0):daterange(end)]';
    elseif strcmp(island_name,'WaterFactory041415')==1 || strcmp(island_name,'CuracaoTank44')==1 || strcmp(island_name,'CuracaoTank34')==1 
        manta.SDN = [daterange(1):datenum(0,0,0,0,15,0):daterange(end)]';
    else
        manta.SDN = [daterange(1):datenum(0,0,0,0,1,0):daterange(end)]';
    end
   
     
    iuse = inrange(trex.SDN, [manta.SDN(1) manta.SDN(end)]);
    manta.TC = interp1(trex.SDN, trex.TC, manta.SDN);
    manta.PSAL = interp1(trex.SDN(iuse), trex.PSAL(iuse), manta.SDN);
    manta.DENS = interp1(trex.SDN(iuse), trex.DENS(iuse), manta.SDN);
    manta.pH = interp1(trex.SDN(iuse), trex.pH(iuse), manta.SDN);
    manta.ORP = interp1(trex.SDN(iuse), trex.ORP(iuse), manta.SDN);

    % look for non-NaN data
    inonanO = ~isnan(trex.DOXY);
    inonanpH = ~isnan(trex.pH);
    inonanOrp = ~isnan(trex.ORP);
    inonanTC = ~isnan(trex.TC);
    inonanVpH = ~isnan(trex.VpH);
    inonanCOND = ~isnan(trex.COND);
    inonanPSAL = ~isnan(trex.PSAL);
    inonanDENS = ~isnan(trex.DENS);
    
    if strcmp(island_name,'CuracaoTank316')==1 || strcmp(island_name,'CuracaoTank44')==1 || strcmp(island_name,'CuracaoTank513')==1
        totiuse = iuse&inonanO&inonanTC;
    else
        totiuse = iuse&inonanO&inonanpH&inonanOrp&inonanTC&inonanVpH&inonanCOND&inonanPSAL&inonanDENS;
    end

    manta.DOXY = interp1(trex.SDN(totiuse),trex.DOXY(totiuse), manta.SDN);
    manta.O2satper = interp1(trex.SDN(totiuse),trex.O2satper(totiuse), manta.SDN);
    manta.pH = interp1(trex.SDN(totiuse),trex.pH(totiuse), manta.SDN);
    manta.ORP = interp1(trex.SDN(totiuse),trex.ORP(totiuse), manta.SDN);
    manta.TC = interp1(trex.SDN(totiuse),trex.TC(totiuse), manta.SDN);
    manta.VpH = interp1(trex.SDN(totiuse),trex.VpH(totiuse), manta.SDN);
    manta.COND = interp1(trex.SDN(totiuse),trex.COND(totiuse), manta.SDN);
    manta.PSAL = interp1(trex.SDN(totiuse),trex.PSAL(totiuse), manta.SDN);
    manta.DENS = interp1(trex.SDN(totiuse),trex.DENS(totiuse), manta.SDN);

    % low pass filter oxygen data
    %*****smooth data with a low pass filter*****
    n = 5; % filter order
    period = 40;% cutoff period. when 1/period = 1, it is half of the sampling rate (butter)
                % so that means period = sensors is one hour. 30 hours = 180.
    Wn = 1/(period); % cutoff frequency
    [b,a] = butter(n,Wn);


    manta.DOXY_lpf = filtfilt(b, a, manta.DOXY);
    manta.pH_lpf = filtfilt(b, a, manta.pH);
    manta.ORP_lpf = filtfilt(b, a, manta.ORP);
    manta.TC_lpf = filtfilt(b, a, manta.TC);
    manta.VpH_lpf = filtfilt(b, a, manta.VpH);
    manta.COND_lpf = filtfilt(b, a, manta.COND);
    manta.PSAL_lpf = filtfilt(b, a, manta.PSAL);
    manta.DENS_lpf = filtfilt(b, a, manta.DENS);

    % take derivative.
    manta.dDOXY_lpf = diff(manta.DOXY_lpf);
    manta.dpH_lpf = diff(manta.pH_lpf);
    manta.dORP_lpf = diff(manta.ORP_lpf);
    manta.dTC_lpf = diff(manta.TC_lpf);
    manta.dVpH_lpf = diff(manta.VpH_lpf);
    manta.dCOND_lpf = diff(manta.COND_lpf);
    manta.dPSAL_lpf = diff(manta.PSAL_lpf);
    manta.dDENS_lpf = diff(manta.DENS_lpf);
    
%         
%         % record local maxima and minima of lpf and derivative datasets.
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.DOXY_lpf(:,ii), manta.SDN, nanlength);
%         DOXYmax(:,ii)=varmax;
%         DOXYmax_locs(:,ii)=max_locs;
%         DOXYmin(:,ii)=varmin;
%         DOXYmin_locs(:,ii)=min_locs;        
%         DOXYmeans(:,ii) = mean(manta.DOXY(:,ii));
%         DOXYstdevs(:,ii) = std(manta.DOXY(:,ii));
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.dDOXY_lpf(:,ii), manta.SDN, nanlength);
%         dDOXYmax(:,ii)=varmax;
%         dDOXYmax_locs(:,ii)=max_locs;
%         dDOXYmin(:,ii)=varmin;
%         dDOXYmin_locs(:,ii)=min_locs; 
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.pH_lpf(:,ii), manta.SDN, nanlength);
%         pHmax(:,ii)=varmax;
%         pHmax_locs(:,ii)=max_locs;
%         pHmin(:,ii)=varmin;
%         pHmin_locs(:,ii)=min_locs;        
%         pHmeans(:,ii) = mean(manta.pH(:,ii));
%         pHstdevs(:,ii) = std(manta.pH(:,ii));
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.dpH_lpf(:,ii), manta.SDN, nanlength);
%         dpHmax(:,ii)=varmax;
%         dpHmax_locs(:,ii)=max_locs;
%         dpHmin(:,ii)=varmin;
%         dpHmin_locs(:,ii)=min_locs;
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.ORP_lpf(:,ii), manta.SDN, nanlength);
%         ORPmax(:,ii)=varmax;
%         ORPmax_locs(:,ii)=max_locs;
%         ORPmin(:,ii)=varmin;
%         ORPmin_locs(:,ii)=min_locs;        
%         ORPmeans(:,ii) = mean(manta.ORP(:,ii));
%         ORPstdevs(:,ii) = std(manta.ORP(:,ii));
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.dORP_lpf(:,ii), manta.SDN, nanlength);
%         dORPmax(:,ii)=varmax;
%         dORPmax_locs(:,ii)=max_locs;
%         dORPmin(:,ii)=varmin;
%         dORPmin_locs(:,ii)=min_locs;
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.TC_lpf(:,ii), manta.SDN, nanlength);
%         TCmax(:,ii)=varmax;
%         TCmax_locs(:,ii)=max_locs;
%         TCmin(:,ii)=varmin;
%         TCmin_locs(:,ii)=min_locs;        
%         TCmeans(:,ii) = mean(manta.TC(:,ii));
%         TCstdevs(:,ii) = std(manta.TC(:,ii));
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.dTC_lpf(:,ii), manta.SDN, nanlength);
%         dTCmax(:,ii)=varmax;
%         dTCmax_locs(:,ii)=max_locs;
%         dTCmin(:,ii)=varmin;
%         dTCmin_locs(:,ii)=min_locs;
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.VpH_lpf(:,ii), manta.SDN, nanlength);
%         VpHmax(:,ii)=varmax;
%         VpHmax_locs(:,ii)=max_locs;
%         VpHmin(:,ii)=varmin;
%         VpHmin_locs(:,ii)=min_locs;        
%         VpHmeans(:,ii) = mean(manta.VpH(:,ii));
%         VpHstdevs(:,ii) = std(manta.VpH(:,ii));
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.dVpH_lpf(:,ii), manta.SDN, nanlength);
%         dVpHmax(:,ii)=varmax;
%         dVpHmax_locs(:,ii)=max_locs;
%         dVpHmin(:,ii)=varmin;
%         dVpHmin_locs(:,ii)=min_locs;
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.COND_lpf(:,ii), manta.SDN, nanlength);
%         CONDmax(:,ii)=varmax;
%         CONDmax_locs(:,ii)=max_locs;
%         CONDmin(:,ii)=varmin;
%         CONDmin_locs(:,ii)=min_locs;        
%         CONDmeans(:,ii) = mean(manta.COND(:,ii));
%         CONDstdevs(:,ii) = std(manta.COND(:,ii));
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.dCOND_lpf(:,ii), manta.SDN, nanlength);
%         dCONDmax(:,ii)=varmax;
%         dCONDmax_locs(:,ii)=max_locs;
%         dCONDmin(:,ii)=varmin;
%         dCONDmin_locs(:,ii)=min_locs;
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.PSAL_lpf(:,ii), manta.SDN, nanlength);
%         PSALmax(:,ii)=varmax;
%         PSALmax_locs(:,ii)=max_locs;
%         PSALmin(:,ii)=varmin;
%         PSALmin_locs(:,ii)=min_locs;        
%         PSALmeans(:,ii) = mean(manta.PSAL(:,ii));
%         PSALstdevs(:,ii) = std(manta.PSAL(:,ii));
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.dPSAL_lpf(:,ii), manta.SDN, nanlength);
%         dPSALmax(:,ii)=varmax;
%         dPSALmax_locs(:,ii)=max_locs;
%         dPSALmin(:,ii)=varmin;
%         dPSALmin_locs(:,ii)=min_locs;
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.DENS_lpf(:,ii), manta.SDN, nanlength);
%         DENSmax(:,ii)=varmax;
%         DENSmax_locs(:,ii)=max_locs;
%         DENSmin(:,ii)=varmin;
%         DENSmin_locs(:,ii)=min_locs;        
%         DENSmeans(:,ii) = mean(manta.DENS(:,ii));
%         DENSstdevs(:,ii) = std(manta.DENS(:,ii));
%         
%         [ varmax, max_locs, varmin, min_locs ]...
%             = extract_peaks( manta.dDENS_lpf(:,ii), manta.SDN, nanlength);
%         dDENSmax(:,ii)=varmax;
%         dDENSmax_locs(:,ii)=max_locs;
%         dDENSmin(:,ii)=varmin;
%         dDENSmin_locs(:,ii)=min_locs;

%     
%     peaks.(island_name).('DOXYmax') = (DOXYmax);
%     peaks.(island_name).('DOXYmin') = (DOXYmin);
%     peaks.(island_name).('dDOXYmax') = (dDOXYmax);
%     peaks.(island_name).('dDOXYmin') = (dDOXYmin);
%     peaks.(island_name).('DOXYmax_locs') = (DOXYmax_locs);
%     peaks.(island_name).('DOXYmin_locs') = (DOXYmin_locs);
%     peaks.(island_name).('dDOXYmax_locs') = (dDOXYmax_locs);
%     peaks.(island_name).('dDOXYmin_locs') = (dDOXYmin_locs);
%     peaks.(island_name).('DOXYmeans') = (DOXYmeans);
%     peaks.(island_name).('DOXYstdevs') = (DOXYstdevs);
%     
%     peaks.(island_name).('pHmax') = (pHmax);
%     peaks.(island_name).('pHmin') = (pHmin);
%     peaks.(island_name).('dpHmax') = (dpHmax);
%     peaks.(island_name).('dpHmin') = (dpHmin);
%     peaks.(island_name).('pHmax_locs') = (pHmax_locs);
%     peaks.(island_name).('pHmin_locs') = (pHmin_locs);
%     peaks.(island_name).('dpHmax_locs') = (dpHmax_locs);
%     peaks.(island_name).('dpHmin_locs') = (dpHmin_locs);
%     peaks.(island_name).('pHmeans') = (pHmeans);
%     peaks.(island_name).('pHstdevs') = (pHstdevs);
%     
%     peaks.(island_name).('ORPmax') = (ORPmax);
%     peaks.(island_name).('ORPmin') = (ORPmin);
%     peaks.(island_name).('dORPmax') = (dORPmax);
%     peaks.(island_name).('dORPmin') = (dORPmin);
%     peaks.(island_name).('ORPmax_locs') = (ORPmax_locs);
%     peaks.(island_name).('ORPmin_locs') = (ORPmin_locs);
%     peaks.(island_name).('dORPmax_locs') = (dORPmax_locs);
%     peaks.(island_name).('dORPmin_locs') = (dORPmin_locs);
%     peaks.(island_name).('ORPmeans') = (ORPmeans);
%     peaks.(island_name).('ORPstdevs') = (ORPstdevs);
%     
%     peaks.(island_name).('TCmax') = (TCmax);
%     peaks.(island_name).('TCmin') = (TCmin);
%     peaks.(island_name).('dTCmax') = (dTCmax);
%     peaks.(island_name).('dTCmin') = (dTCmin);
%     peaks.(island_name).('TCmax_locs') = (TCmax_locs);
%     peaks.(island_name).('TCmin_locs') = (TCmin_locs);
%     peaks.(island_name).('dTCmax_locs') = (dTCmax_locs);
%     peaks.(island_name).('dTCmin_locs') = (dTCmin_locs);
%     peaks.(island_name).('TCmeans') = (TCmeans);
%     peaks.(island_name).('TCstdevs') = (TCstdevs);
%     
%     peaks.(island_name).('VpHmax') = (VpHmax);
%     peaks.(island_name).('VpHmin') = (VpHmin);
%     peaks.(island_name).('dVpHmax') = (dVpHmax);
%     peaks.(island_name).('dVpHmin') = (dVpHmin);
%     peaks.(island_name).('VpHmax_locs') = (VpHmax_locs);
%     peaks.(island_name).('VpHmin_locs') = (VpHmin_locs);
%     peaks.(island_name).('dVpHmax_locs') = (dVpHmax_locs);
%     peaks.(island_name).('dVpHmin_locs') = (dVpHmin_locs);
%     peaks.(island_name).('VpHmeans') = (VpHmeans);
%     peaks.(island_name).('VpHstdevs') = (VpHstdevs);
%     
%     peaks.(island_name).('CONDmax') = (CONDmax);
%     peaks.(island_name).('CONDmin') = (CONDmin);
%     peaks.(island_name).('dCONDmax') = (dCONDmax);
%     peaks.(island_name).('dCONDmin') = (dCONDmin);
%     peaks.(island_name).('CONDmax_locs') = (CONDmax_locs);
%     peaks.(island_name).('CONDmin_locs') = (CONDmin_locs);
%     peaks.(island_name).('dCONDmax_locs') = (dCONDmax_locs);
%     peaks.(island_name).('dCONDmin_locs') = (dCONDmin_locs);
%     peaks.(island_name).('CONDmeans') = (CONDmeans);
%     peaks.(island_name).('CONDstdevs') = (CONDstdevs);
%     
%     peaks.(island_name).('PSALmax') = (PSALmax);
%     peaks.(island_name).('PSALmin') = (PSALmin);
%     peaks.(island_name).('dPSALmax') = (dPSALmax);
%     peaks.(island_name).('dPSALmin') = (dPSALmin);
%     peaks.(island_name).('PSALmax_locs') = (PSALmax_locs);
%     peaks.(island_name).('PSALmin_locs') = (PSALmin_locs);
%     peaks.(island_name).('dPSALmax_locs') = (dPSALmax_locs);
%     peaks.(island_name).('dPSALmin_locs') = (dPSALmin_locs);
%     peaks.(island_name).('PSALmeans') = (PSALmeans);
%     peaks.(island_name).('PSALstdevs') = (PSALstdevs);
%     
%     peaks.(island_name).('DENSmax') = (DENSmax);
%     peaks.(island_name).('DENSmin') = (DENSmin);
%     peaks.(island_name).('dDENSmax') = (dDENSmax);
%     peaks.(island_name).('dDENSmin') = (dDENSmin);
%     peaks.(island_name).('DENSmax_locs') = (DENSmax_locs);
%     peaks.(island_name).('DENSmin_locs') = (DENSmin_locs);
%     peaks.(island_name).('dDENSmax_locs') = (dDENSmax_locs);
%     peaks.(island_name).('dDENSmin_locs') = (dDENSmin_locs);
%     peaks.(island_name).('DENSmeans') = (DENSmeans);
%     peaks.(island_name).('DENSstdevs') = (DENSstdevs);

fsize = 10;
lwidth = 2;

f1 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
hold on
plot(manta.SDN, manta.DOXY_lpf, 'linewidth', lwidth);
title(island_name, 'fontsize', fsize);
ylabel('Oxygen [\mumol kg^-^1 min^-^1]', 'fontsize', fsize);
datetick('x', 'HH:MM');
set(gca, 'fontsize', fsize, 'XTickLabelRotation', 45);

plotname = [island_name,'-DOXY.eps'];
saveas(f1, plotname, 'epsc');

f2 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
hold on
plot(manta.SDN, manta.TC_lpf, 'linewidth', lwidth);
title(island_name, 'fontsize', fsize);
ylabel('Temperature', 'fontsize', fsize);
datetick('x', 'HH:MM');
set(gca, 'fontsize', fsize, 'XTickLabelRotation', 45);

plotname = [island_name,'-TC.eps'];
saveas(f2, plotname, 'epsc');

f_name = [island_name,'.mat'];

save(f_name, 'manta', 'island_name');
close all

clearvars -except folder txtfiles

end


% save('peaks.mat','peaks');





