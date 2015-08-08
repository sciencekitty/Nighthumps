% analyze_manta_data.m

% Analyze manta and PAR data to extract nighttime signal and normalize data to DO.

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

for i = 1:length(mantafiles)
    name = mantafiles{i};
    name = name(1:end-4);
    load(mantafiles{i});
    
    % isolate time data from datetime array
    analysis.SDN=manta.SDN;
    Time=datetime(analysis.SDN,'ConvertFrom','datenum');
    inonat=~isnat(Time);
    Y=Time.Year;
    M=Time.Month;
    D=Time.Day;
    for iii=1:size(Time,1)
        for iv=1:size(Time,2);
            if inonat(iii,iv)==1
                Y(iii,iv)=2000;
                M(iii,iv)=1;
                D(iii,iv)=1;
            end
        end
    end
    H=Time.Hour;
    S=Time.Second;
    MI=Time.Minute;
    analysis.hour=datenum(Y,M,D,H,MI,S);
    
    dawn=datenum(2000,1,1,6,0,0);
    dusk=datenum(2000,1,1,18,0,0);
    
    % Set timeframe for nighttime (18:00 to 6:00)
    iuse=~inrange(analysis.hour,[dawn,dusk]);
    
    analysis.nightDOXY=manta.DOXY(iuse,:);
    analysis.nightSDN=manta.SDN(iuse,:);
    analysis.nightpH=manta.pH(iuse,:);
    analysis.nightORP=manta.ORP(iuse,:);
    analysis.nightTC=manta.TC(iuse,:);
    
    % Break data into individual nights
    analysis.night=zeros(size(iuse));
    night=1;
    d=1;
    while d<=length(iuse)-1
        if iuse(d)==true
            analysis.night(d)=night;
        elseif iuse(d)==false&&iuse(d+1)==true
            night=night+1;
            analysis.night(d+1)=night;
        end
        d=d+1;
    end  
    analysis.night=analysis.night(iuse);
    analysis.night(end)=analysis.night(end-1);
    
    % Set timeframe for un-normalized day time 
    iuse=inrange(analysis.hour,[dawn,dusk]);
    
    analysis.dayDOXY=manta.DOXY(iuse,:);
    analysis.daySDN=manta.SDN(iuse,:);
    analysis.daypH=manta.pH(iuse,:);
    analysis.dayORP=manta.ORP(iuse,:);
    analysis.dayTC=manta.TC(iuse,:);
    
    % Break data into individual days
    analysis.day=zeros(size(iuse));
    day=1;
    d=1;
    while d<=length(iuse)-1
        if iuse(d)==true
            analysis.day(d)=day;
        elseif iuse(d)==false&&iuse(d+1)==true
            day=day+1;
            analysis.day(d+1)=day;
        end
        d=d+1;
    end  
    analysis.day=analysis.day(iuse);
    analysis.day(end)=analysis.day(end-1);
    
    % Zero baselines 
    analysis.minute=[1:length(analysis.nightDOXY)]'*5;
    analysis.secs=[1:length(analysis.nightDOXY)]'*5*60;
    
    base=min(analysis.nightDOXY);
    for ii=1:length(base)
        analysis.nightDOXYbase(:,ii)=analysis.nightDOXY(:,ii)-base(ii);
    end
    
    base=min(analysis.dayDOXY);
    for ii=1:length(base)
        analysis.dayDOXYbase(:,ii)=analysis.dayDOXY(:,ii)-base(ii);
    end
    
    base=min(analysis.nightpH);
    for ii=1:length(base)
        analysis.nightpHbase(:,ii)=analysis.nightpH(:,ii)-base(ii);
    end
    
    base=min(analysis.daypH);
    for ii=1:length(base)
        analysis.daypHbase(:,ii)=analysis.daypH(:,ii)-base(ii);
    end
    
    base=min(analysis.nightORP);
    for ii=1:length(base)
        analysis.nightORPbase(:,ii)=analysis.nightORP(:,ii)-base(ii);
    end
    
    base=min(analysis.dayORP);
    for ii=1:length(base)
        analysis.dayORPbase(:,ii)=analysis.dayORP(:,ii)-base(ii);
    end
    
    base=min(analysis.nightTC);
    for ii=1:length(base)
        analysis.nightTCbase(:,ii)=analysis.nightTC(:,ii)-base(ii);
    end
    
    base=min(analysis.dayTC);
    for ii=1:length(base)
        analysis.dayTCbase(:,ii)=analysis.dayTC(:,ii)-base(ii);
    end
    
    
    % Calculate the following values per night:
    %
    % Integrated values for each sensor.  
    % Ratio of oxygen to pH, ORP and TC
    % Maximums.
    % Minimums.
    % Mean with stddev.
    % Slope of the best fit line for DOXY:pH, ORP and TC and the R-squared value.
    
    [~,nightind]=unique(analysis.night);
    nightind=[nightind;length(analysis.night)];
    for ii=1:length(nightind)-1
        nightnum=num2str(ii);
        var2=['intDOXY',nightnum];
        var5=['DOXYmax',nightnum];
        var7=['DOXYmin',nightnum];
        var9=['DOXYmean',nightnum];
        var11=['DOXYstd',nightnum];
        
        var14=['intpH',nightnum];
        var15=['pHmax',nightnum];
        var16=['pHmin',nightnum];
        var17=['pHmean',nightnum];
        var18=['pHstd',nightnum];
        var19=['ratioDOXY_pH',nightnum];
        var20=['slopesDOXY_pH',nightnum];
        var21=['rsqDOXY_pH',nightnum];
        
        var22=['intORP',nightnum];
        var23=['ORPmax',nightnum];
        var24=['ORPmin',nightnum];
        var25=['ORPmean',nightnum];
        var26=['ORPstd',nightnum];
        var27=['ratioDOXY_ORP',nightnum];
        var28=['slopesDOXY_ORP',nightnum];
        var29=['rsqDOXY_ORP',nightnum];
        
        var30=['intTC',nightnum];
        var31=['TCmax',nightnum];
        var32=['TCmin',nightnum];
        var33=['TCmean',nightnum];
        var34=['TCstd',nightnum];
        var35=['ratioDOXY_TC',nightnum];
        var36=['slopesDOXY_TC',nightnum];
        var37=['rsqDOXY_TC',nightnum];
            
        % Daily values
        DOXYbase=analysis.nightDOXYbase(nightind(ii):nightind(ii+1),:);
        DOXY=analysis.nightDOXY(nightind(ii):nightind(ii+1),:);
        pHbase=analysis.nightpHbase(nightind(ii):nightind(ii+1),:);
        pH=analysis.nightpH(nightind(ii):nightind(ii+1),:);
        ORPbase=analysis.nightORPbase(nightind(ii):nightind(ii+1),:);
        ORP=analysis.nightORP(nightind(ii):nightind(ii+1),:);
        TCbase=analysis.nightTC(nightind(ii):nightind(ii+1),:);
        TC=analysis.nightTC(nightind(ii):nightind(ii+1),:);
        
        % Trapezoidal numerical integration
        analysis.nightly.(var2)=trapz(analysis.secs(nightind(ii):nightind(ii+1),:),DOXYbase)';
        analysis.nightly.(var14)=trapz(analysis.secs(nightind(ii):nightind(ii+1),:),pHbase)';
        analysis.nightly.(var22)=trapz(analysis.secs(nightind(ii):nightind(ii+1),:),ORPbase)';
        analysis.nightly.(var30)=trapz(analysis.secs(nightind(ii):nightind(ii+1),:),TCbase)';
        
        % Integration ratios
        analysis.nightly.(var19)=analysis.nightly.(var14)./analysis.nightly.(var2);
        analysis.nightly.(var27)=analysis.nightly.(var22)./analysis.nightly.(var2);
        analysis.nightly.(var35)=analysis.nightly.(var30)./analysis.nightly.(var2);
        
        % Max, min, and means
        analysis.nightly.(var5)=max(DOXY)';
        analysis.nightly.(var15)=max(pH)';
        analysis.nightly.(var23)=max(ORP)';
        analysis.nightly.(var31)=max(TC)';
        analysis.nightly.(var7)=min(DOXY)';
        analysis.nightly.(var16)=min(pH)';
        analysis.nightly.(var24)=min(ORP)';
        analysis.nightly.(var32)=min(TC)';
        analysis.nightly.(var9)=mean(DOXY)';
        analysis.nightly.(var17)=mean(pH)';
        analysis.nightly.(var25)=mean(ORP)';
        analysis.nightly.(var33)=mean(TC)';
        analysis.nightly.(var11)=std(DOXY)';
        analysis.nightly.(var18)=std(pH)';
        analysis.nightly.(var26)=std(ORP)';
        analysis.nightly.(var34)=std(TC)';
        
        % Linear regression
        slopes=zeros(1,6);
        rsqs=zeros(1,6);
        
        for iii=1:6
            x=analysis.nightpH(nightind(ii):nightind(ii+1),iii);
            y=analysis.nightDOXY(nightind(ii):nightind(ii+1),iii);
            p=polyfit(x,y,1);
            slope=p(1,1);
            yfit=polyval(p,x);
            r_sq=rsq(yfit,y);
            slopes(1,iii)=slope;
            rsqs(iii)=r_sq;
        end
        analysis.nightly.(var20)=slopes';
        analysis.nightly.(var21)=rsqs';
        
        for iii=1:6
            x=analysis.nightORP(nightind(ii):nightind(ii+1),iii);
            y=analysis.nightDOXY(nightind(ii):nightind(ii+1),iii);
            p=polyfit(x,y,1);
            slope=p(1,1);
            yfit=polyval(p,x);
            r_sq=rsq(yfit,y);
            slopes(1,iii)=slope;
            rsqs(iii)=r_sq;
        end
        analysis.nightly.(var28)=slopes';
        analysis.nightly.(var29)=rsqs';
        
        for iii=1:6
            x=analysis.nightTC(nightind(ii):nightind(ii+1),iii);
            y=analysis.nightDOXY(nightind(ii):nightind(ii+1),iii);
            p=polyfit(x,y,1);
            slope=p(1,1);
            yfit=polyval(p,x);
            r_sq=rsq(yfit,y);
            slopes(1,iii)=slope;
            rsqs(iii)=r_sq;
        end
        analysis.nightly.(var36)=slopes';
        analysis.nightly.(var37)=rsqs';

    end
    

    f_name = [name,'_analysis_night.mat'];
    
    save(f_name, 'analysis', 'name');
    close all
    
    
    clearvars -except folder mantafiles parfiles
    
    
end
    
    
    
    
    
    
    