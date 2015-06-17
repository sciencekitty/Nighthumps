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
    
    % isolate data when PAR >= 1 (daytime)
    analysis.DOXY=interp1(manta.SDN, manta.DOXY, par.SDN);
    analysis.pH=interp1(manta.SDN, manta.pH, par.SDN);
    analysis.ORP=interp1(manta.SDN, manta.ORP,par.SDN);
    analysis.TC=interp1(manta.SDN, manta.TC, par.SDN);
    
    isnonan = ~isnan(analysis.DOXY(:,1));
    iuse=inrange(par.PAR,[1 max(par.PAR)]);
    
    analysis.DOXY=analysis.DOXY(iuse&isnonan,:);
    analysis.SDN=par.SDN(iuse&isnonan,:);
    analysis.PAR=par.PAR(iuse&isnonan,:);
    analysis.pH=analysis.pH(iuse&isnonan,:);
    analysis.ORP=analysis.ORP(iuse&isnonan,:);
    analysis.TC=analysis.TC(iuse&isnonan,:);
    
    % Break PAR data into individual days
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
    analysis.day=analysis.day(iuse&isnonan);
    analysis.day(end)=analysis.day(end-1);
    
    % Zero baselines 
    analysis.hrs=[1:length(analysis.PAR)]'*5/60;
    analysis.secs=[1:length(analysis.PAR)]'*5*60;
    base=min(analysis.DOXY);
    for ii=1:length(base)
        analysis.DOXYbase(:,ii)=analysis.DOXY(:,ii)-base(ii);
    end
    
    base=min(analysis.pH);
    for ii=1:length(base)
        analysis.pHbase(:,ii)=analysis.pH(:,ii)-base(ii);
    end
    
    base=min(analysis.ORP);
    for ii=1:length(base)
        analysis.ORPbase(:,ii)=analysis.ORP(:,ii)-base(ii);
    end
    
    base=min(analysis.TC);
    for ii=1:length(base)
        analysis.TCbase(:,ii)=analysis.TC(:,ii)-base(ii);
    end
    
    
    imagename=[name,'_PAR.eps'];
    plotPARdata(par.SDN,par.PAR,name,imagename);
    imagename=[name,'_DOXY.eps'];
    plotDOXYdata(manta.SDN,manta.DOXY,name,imagename);
    
    % Calculate the following values per day:
    %
    % Integrated PAR and DO values for each sensor. Units are
    % umol*s/kg for DOXY and umol/m^2 for PAR. Integral length is converted
    % to seconds to normalize time units. 
    % Ratio of umol oxygen produced to umol PAR absorbed per sensor. Units are 
    % kg per square meter per second.
    % Maximum PAR and DO.
    % Minimum PAR and DO.
    % Mean PAR and DO, with stddev.
    % Slope of the best fit line for DOXY:PAR and the R-squared value.
    
    [~,dayind]=unique(analysis.day);
    dayind=[dayind;length(analysis.day)];
    for ii=1:length(dayind)-1
        daynum=num2str(ii);
        var1=['intPAR',daynum];
        var2=['intDOXY',daynum];
        var3=['ratioDOXY_PAR',daynum];
        var4=['PARmax',daynum];
        var5=['DOXYmax',daynum];
        var6=['PARmin',daynum];
        var7=['DOXYmin',daynum];
        var8=['PARmean',daynum];
        var9=['DOXYmean',daynum];
        var10=['PARstd',daynum];
        var11=['DOXYstd',daynum];
        var12=['slopesDOXY_PAR',daynum];
        var13=['rsqDOXY_PAR',daynum];
        
        var14=['intpH',daynum];
        var15=['pHmax',daynum];
        var16=['pHmin',daynum];
        var17=['pHmean',daynum];
        var18=['pHstd',daynum];
        var19=['ratiopH_PAR',daynum];
        var20=['slopespH_PAR',daynum];
        var21=['rsqpH_PAR',daynum];
        
        var22=['intORP',daynum];
        var23=['ORPmax',daynum];
        var24=['ORPmin',daynum];
        var25=['ORPmean',daynum];
        var26=['ORPstd',daynum];
        var27=['ratioORP_PAR',daynum];
        var28=['slopesORP_PAR',daynum];
        var29=['rsqORP_PAR',daynum];
        
        var30=['intTC',daynum];
        var31=['TCmax',daynum];
        var32=['TCmin',daynum];
        var33=['TCmean',daynum];
        var34=['TCstd',daynum];
        var35=['ratioTC_PAR',daynum];
        var36=['slopesTC_PAR',daynum];
        var37=['rsqTC_PAR',daynum];
            
        % Daily values
        PAR=analysis.PAR(dayind(ii):dayind(ii+1),:);
        DOXYbase=analysis.DOXYbase(dayind(ii):dayind(ii+1),:);
        DOXY=analysis.DOXY(dayind(ii):dayind(ii+1),:);
        pHbase=analysis.pHbase(dayind(ii):dayind(ii+1),:);
        pH=analysis.pH(dayind(ii):dayind(ii+1),:);
        ORPbase=analysis.ORPbase(dayind(ii):dayind(ii+1),:);
        ORP=analysis.ORP(dayind(ii):dayind(ii+1),:);
        TCbase=analysis.TC(dayind(ii):dayind(ii+1),:);
        TC=analysis.TC(dayind(ii):dayind(ii+1),:);
        
        % Trapezoidal numerical integration
        analysis.daily.(var1)=[trapz(analysis.secs(dayind(ii):dayind(ii+1),:),PAR),...
            NaN(1,5)]';
        analysis.daily.(var2)=trapz(analysis.secs(dayind(ii):dayind(ii+1),:),DOXYbase)';
        analysis.daily.(var14)=trapz(analysis.secs(dayind(ii):dayind(ii+1),:),pHbase)';
        analysis.daily.(var22)=trapz(analysis.secs(dayind(ii):dayind(ii+1),:),ORPbase)';
        analysis.daily.(var30)=trapz(analysis.secs(dayind(ii):dayind(ii+1),:),TCbase)';
        
        % Integration ratios
        analysis.daily.(var3)=analysis.daily.(var2)./analysis.daily.(var1)(1,1);
        analysis.daily.(var19)=analysis.daily.(var14)./analysis.daily.(var1)(1,1);
        analysis.daily.(var27)=analysis.daily.(var22)./analysis.daily.(var1)(1,1);
        analysis.daily.(var35)=analysis.daily.(var30)./analysis.daily.(var1)(1,1);
        
        % Max, min, and means
        analysis.daily.(var4)=[max(PAR),NaN(1,5)]';
        analysis.daily.(var5)=max(DOXY)';
        analysis.daily.(var15)=max(pH)';
        analysis.daily.(var23)=max(ORP)';
        analysis.daily.(var31)=max(TC)';
        analysis.daily.(var6)=[min(PAR),NaN(1,5)]';
        analysis.daily.(var7)=min(DOXY)';
        analysis.daily.(var16)=min(pH)';
        analysis.daily.(var24)=min(ORP)';
        analysis.daily.(var32)=min(TC)';
        analysis.daily.(var8)=[mean(PAR),NaN(1,5)]';
        analysis.daily.(var9)=mean(DOXY)';
        analysis.daily.(var17)=mean(pH)';
        analysis.daily.(var25)=mean(ORP)';
        analysis.daily.(var33)=mean(TC)';
        analysis.daily.(var10)=[std(PAR),NaN(1,5)]';
        analysis.daily.(var11)=std(DOXY)';
        analysis.daily.(var18)=std(pH)';
        analysis.daily.(var26)=std(ORP)';
        analysis.daily.(var34)=std(TC)';
        
        % Linear regression
        slopes=zeros(1,6);
        rsqs=zeros(1,6);
        for iii=1:6
            y=analysis.DOXY(dayind(ii):dayind(ii+1),iii);
            x=PAR;
            p=polyfit(x,y,1);
            slope=p(1,1);
            yfit=polyval(p,x);
            r_sq=rsq(yfit,y);
            slopes(1,iii)=slope;
            rsqs(iii)=r_sq;
        end
        analysis.daily.(var12)=slopes';
        analysis.daily.(var13)=rsqs';
        
        for iii=1:6
            y=analysis.pH(dayind(ii):dayind(ii+1),iii);
            x=PAR;
            p=polyfit(x,y,1);
            slope=p(1,1);
            yfit=polyval(p,x);
            r_sq=rsq(yfit,y);
            slopes(1,iii)=slope;
            rsqs(iii)=r_sq;
        end
        analysis.daily.(var20)=slopes';
        analysis.daily.(var21)=rsqs';
        
        for iii=1:6
            y=analysis.ORP(dayind(ii):dayind(ii+1),iii);
            x=PAR;
            p=polyfit(x,y,1);
            slope=p(1,1);
            yfit=polyval(p,x);
            r_sq=rsq(yfit,y);
            slopes(1,iii)=slope;
            rsqs(iii)=r_sq;
        end
        analysis.daily.(var28)=slopes';
        analysis.daily.(var29)=rsqs';
        
        for iii=1:6
            y=analysis.TC(dayind(ii):dayind(ii+1),iii);
            x=PAR;
            p=polyfit(x,y,1);
            slope=p(1,1);
            yfit=polyval(p,x);
            r_sq=rsq(yfit,y);
            slopes(1,iii)=slope;
            rsqs(iii)=r_sq;
        end
        analysis.daily.(var36)=slopes';
        analysis.daily.(var37)=rsqs';

    end
    
%     areas=cell(1,7);
%     areas{1}='PAR';
%     intPAR=trapz(analysis.secs,analysis.PAR);
%     intDOXY=trapz(analysis.secs,analysis.DOXYbase);
%     intRatio=intDOXY./intPAR;
%     
%     for ii=1:6
%         areas{ii+1}=['Sensor ',num2str(ii),', O_2:PAR ',num2str(intRatio(ii))];
%     end
% 
%     
%    % Plot PAR and DOXY overlaid
%    f1 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
%    hold on
%    [Ax,PAR,DOXYbase]=plotyy(analysis.hrs,analysis.PAR, [analysis.hrs,analysis.hrs,analysis.hrs,analysis.hrs,...
%        analysis.hrs,analysis.hrs], [analysis.DOXYbase(:,1),analysis.DOXYbase(:,2),analysis.DOXYbase(:,3),...
%        analysis.DOXYbase(:,4),analysis.DOXYbase(:,5),analysis.DOXYbase(:,6)], 'area', 'plot');
%    title(name);
%    xlabel('Elapsed Daylight Hours');
%    ylabel(Ax(1), 'PAR [\mumol photons m^-^2 s^-^1]');
%    ylabel(Ax(2), 'Oxygen [\mumol kg^-^1]');
%    ylim(Ax(1), [0, 1400]);
%    ylim(Ax(2),[0 70]);
%    legend(areas, 'Box', 'off');
%    filename=[name,'_DOXY-PAR_overlay.eps'];
%    saveas(f1, filename, 'epsc');
%    
%    % Plot oxygen to PAR linear regression for each sensor
%    linereg=zeros(6,2);
%    yfit=zeros(size(analysis.DOXY));
%    sensor=cell(1,6);
%    for ii=1:6
%        linereg(ii,:)=polyfit(analysis.PAR,analysis.DOXY(:,ii),1);
%        yfit(:,ii)=polyval(linereg(ii,:),analysis.PAR);
%        r_sq=rsq(yfit(:,ii),analysis.DOXY(:,ii));
%        sensor{ii}=['Sensor ',num2str(ii), ' (R^2 = ',num2str(r_sq),'); m = ',...
%            num2str(linereg(ii,1))];
%       
%    end
%    
%    f2 = figure('units', 'inch', 'position', [1 1 8 8], 'visible', 'off');
%    hold on
%    plot(analysis.PAR,yfit);
%    scatter(analysis.PAR, analysis.DOXY(:,1), 'Marker','.');
%    scatter(analysis.PAR, analysis.DOXY(:,2), 'Marker','.');
%    scatter(analysis.PAR, analysis.DOXY(:,3), 'Marker','.');
%    scatter(analysis.PAR, analysis.DOXY(:,4), 'Marker','.');
%    scatter(analysis.PAR, analysis.DOXY(:,5), 'Marker','.');
%    scatter(analysis.PAR, analysis.DOXY(:,6), 'Marker','.');
%    xlabel('PAR [\mumol photons m^-^2 s^-^1]');
%    ylabel('Oxygen [\mumol kg^-^1]');
%    title(name);
%    legend(sensor, 'Box', 'off', 'Location', 'southeast');
%    filename=[name,'_linreg.eps'];
%    saveas(f2, filename, 'epsc');

    f_name = [name,'_analysis_day.mat'];
    
    save(f_name, 'analysis', 'name');
    close all
    
    
    clearvars -except folder mantafiles parfiles
    
    
end
    
    
    
    
    
    
    