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

vars={'DOXY'
    'pH'
    'ORP'
    'TC'
    'COND'
    'PSAL'
    };


for i = 1:length(mantafiles)
    name = parfiles{i};
    name = name(1:end-8);
    load(mantafiles{i});
    load(parfiles{i});
    
    % Interpolate variables onto PAR datetime scale. Leave this step out if
    % not using PAR to determine day and night times. Use
    % analysis.(vars{ii})=manta.(vars{ii}); instead
    for ii = 1:length(vars)
        analysis.(vars{ii})=interp1(manta.SDN, manta.(vars{ii}), par.SDN);
    end
    
    % Exclude NaN data from interpolation. This is manta data that is
    % outside the PAR measurement timeframe.
    isnonan = ~isnan(analysis.DOXY(:,1));
    
    % Isolate data when PAR >= 1 (daytime)
    iuse=inrange(par.PAR,[1 max(par.PAR)]);
    analysis.day.PAR=par.PAR(iuse&isnonan);
    analysis.day.SDN=par.SDN(iuse&isnonan);
    
    for ii = 1:length(vars)
        analysis.day.(vars{ii})=analysis.(vars{ii})(iuse&isnonan,:);
        % Set baseline to zero for integration.
        base=min(analysis.day.(vars{ii}));
        basevar=[vars{ii},'base'];
            for iii=1:length(base)
                analysis.day.(basevar)(:,ii)=analysis.day.(vars{ii})(:,iii)-base(iii);
            end
    end
    
    % Get vector for individual days
    analysis.day.day=zeros(size(iuse));
    day=1;
    d=1;
    while d<length(iuse)
        if iuse(d)==true
            analysis.day.day(d)=day;
        elseif iuse(d)==false&&iuse(d+1)==true
            day=day+1;
            analysis.day.day(d+1)=day;
        end
        d=d+1;
    end  
    analysis.day.day=analysis.day.day(iuse&isnonan);
    analysis.day.day(end)=analysis.day.day(end-1);
    
    % isolate data when PAR < 1 (nighttime)
    iuse=inrange(par.PAR,[min(par.PAR) 1], 'includeleft');
    analysis.night.PAR=par.PAR(iuse&isnonan);
    analysis.night.SDN=par.SDN(iuse&isnonan);
    
    for ii = 1:length(vars)
        analysis.night.(vars{ii})=analysis.(vars{ii})(iuse&isnonan,:);
        % Set baseline to zero for integration.
        base=min(analysis.night.(vars{ii}));
        basevar=[vars{ii},'base'];
            for iii=1:length(base)
                analysis.night.(basevar)(:,ii)=analysis.night.(vars{ii})(:,iii)-base(iii);
            end
    end
    
    % Get vector for individual nights
    analysis.night.night=zeros(size(iuse));
    night=1;
    d=1;
    while d<length(iuse)
        if iuse(d)==true
            analysis.night.night(d)=night;
        elseif iuse(d)==false&&iuse(d+1)==true
            night=night+1;
            analysis.night.night(d+1)=night;
        end
        d=d+1;
    end  
    analysis.night.night=analysis.night.night(iuse&isnonan);
    analysis.night.night(end)=analysis.night.night(end-1);
    
    % Get vector of minutes and seconds for day and night times.
    analysis.day.minutes=[0:length(analysis.day.SDN)]'*5;
    analysis.night.minutes=[0:length(analysis.night.SDN)]'*5;
    analysis.day.secs=[0:length(analysis.day.SDN)]'*5*60;
    analysis.night.secs=[0:length(analysis.night.SDN)]'*5*60;

    % Plot PAR and DOXY data for reference.
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
    % Slope of the best fit line for DOXY:PAR and the R-squared value
    
    [~,dayind]=unique(analysis.day.day);
    analysis.day.sunrise=analysis.day.SDN(dayind);
    dayind=[dayind;length(analysis.day.day)];
    
    for ii=1:length(dayind)-1
        daynum=num2str(ii);
        dayminutes=['day',daynum,'minutes'];
        analysis.day.(dayminutes)=analysis.day.minutes(dayind(ii+1))-analysis.day.minutes(dayind(ii));
        
        for iii=1:length(vars) 
            var1=[vars{iii},'max',daynum];
            var2=[vars{iii},'min',daynum];
            var3=[vars{iii},'mean',daynum];
            var4=[vars{iii},'std',daynum];
            var5=['int',vars{iii},daynum];
            var6=['ratioPAR_',vars{iii},daynum];
            var7=['slopesPAR_',vars{iii},daynum];
            var8=['rsqPAR_',vars{iii},daynum];
            
            % Daily values
            PAR=analysis.day.PAR(dayind(ii):dayind(ii+1),:);
            var=analysis.day.(vars{iii})(dayind(ii):dayind(ii+1),:);
            
            % Max, min, and means
            var0=['PARmax',daynum];
            analysis.day.(var0)=[max(PAR),NaN(1,5)]';
            var0=['PARmin',daynum];
            analysis.day.(var0)=[min(PAR),NaN(1,5)]';
            var0=['PARmean',daynum];
            analysis.day.(var0)=[mean(PAR),NaN(1,5)]';
            var0=['PARstd',daynum];
            analysis.day.(var0)=[std(PAR),NaN(1,5)]';
            
            analysis.day.(var1)=max(var);
            analysis.day.(var2)=min(var);
            analysis.day.(var3)=mean(var);
            analysis.day.(var4)=std(var);

            % Trapezoidal numerical integration
            var0=['intPAR',daynum];
            analysis.day.(var0)=[trapz(analysis.day.secs(dayind(ii):dayind(ii+1),1),PAR),...
                NaN(1,5)]';
            analysis.day.(var5)=trapz(analysis.day.secs(dayind(ii):dayind(ii+1),:),var);

            % Integration ratios
            analysis.day.(var6)=analysis.day.(var5)./analysis.day.(var0)(1,1);

            % Linear regression
            slopes=zeros(1,6);
            rsqs=zeros(1,6);
            for iv=1:6
                y=var(:,iv);
                x=PAR;
                p=polyfit(x,y,1);
                slope=p(1,1);
                yfit=polyval(p,x);
                r_sq=rsq(yfit,y);
                slopes(1,iv)=slope;
                rsqs(iv)=r_sq;
            end
            analysis.day.(var7)=slopes';
            analysis.day.(var8)=rsqs';
        end
    end
    
    % Calculate the following values per night:
    %
    % Integrated values for each variable for each sensor. Integral length is converted
    % to seconds to normalize time units. 
    % Ratio of variable to oxygen per sensor. 
    % Maximum
    % Minimum
    % Mean, with stddev.
    % Slope of the best fit line for (var):DOXY and the R-squared value
    
    [~,nightind]=unique(analysis.night.night);
    nightind=[nightind;length(analysis.night.night)];
    analysis.night.sunset=analysis.night.SDN(nightind);
    
    for ii=1:length(nightind)-1
        nightnum=num2str(ii);
        nightminutes=['night',nightnum,'minutes'];
        analysis.night.(nightminutes)=analysis.night.minutes(nightind(ii+1))-analysis.night.minutes(nightind(ii));
        
        for iii=1:length(vars) 
            var1=[vars{iii},'max',nightnum];
            var2=[vars{iii},'min',nightnum];
            var3=[vars{iii},'mean',nightnum];
            var4=[vars{iii},'std',nightnum];
            var5=['int',vars{iii},nightnum];
            var6=['ratioDOXY_',vars{iii},nightnum];
            var7=['slopesDOXY_',vars{iii},nightnum];
            var8=['rsqDOXY_',vars{iii},nightnum];
            
            % Daily values
            DOXY=analysis.night.DOXY(nightind(ii):nightind(ii+1),:);
            var=analysis.night.(vars{iii})(nightind(ii):nightind(ii+1),:);
            
            % Max, min, and means
            analysis.night.(var1)=max(var);
            analysis.night.(var2)=min(var);
            analysis.night.(var3)=mean(var);
            analysis.night.(var4)=std(var);

            % Trapezoidal numerical integration
            analysis.night.(var5)=trapz(analysis.night.secs(nightind(ii):nightind(ii+1),:),var);

            % Integration ratios
            var0=['intDOXY',nightnum];
            analysis.night.(var6)=analysis.night.(var5)./analysis.night.(var0);

            % Linear regression
            slopes=zeros(1,6);
            rsqs=zeros(1,6);
            for iv=1:6
                y=var(:,iv);
                x=DOXY(:,iv);
                p=polyfit(x,y,1);
                slope=p(1,1);
                yfit=polyval(p,x);
                r_sq=rsq(yfit,y);
                slopes(1,iv)=slope;
                rsqs(iv)=r_sq;
            end
            analysis.night.(var7)=slopes';
            analysis.night.(var8)=rsqs';
        end
    end

    f_name = [name,'_analysis_PARbased.mat'];
    
    save(f_name, 'analysis', 'name');
    
    close all
    
    clearvars -except folder mantafiles parfiles vars
    
    
end
    
    
    
    
    
    
    