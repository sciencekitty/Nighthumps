% analyze_manta_data_TIMEbased.m

% Analyze manta data using days based on average sunrise and sunset time
% determined by PAR data. analyse_manta_data_PARbased.m must be run first.

clear all
close all

% folder path where .mat files are kept
folder = '/Users/Sandi/Documents/Nighthumps';
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
analysisfiles = {'flint_analysis_PARbased.mat'
    'vostok_analysis_PARbased.mat'
    'malden_analysis_PARbased.mat'
    'millennium_analysis_PARbased.mat'
    'starbuck_analysis_PARbased.mat'
    'fanning_analysis_PARbased.mat'
    'jarvis_analysis_PARbased.mat'
    'kingman_analysis_PARbased.mat'
    'palmyra_analysis_PARbased.mat'
    'washington_analysis_PARbased.mat'};

vars={'DOXY'
    'pH'
    'ORP'
    'TC'
    'COND'
    'PSAL'
    };


for i = 1:length(mantafiles)
    load(mantafiles{i});
    load(analysisfiles{i});
    
    % Interpolate variables onto PAR datetime scale. Leave this step out if
    % not using PAR to determine day and night times. Use
    % analysis.(vars{ii})=manta.(vars{ii}); instead
    for ii = 1:length(vars)
        analysis2.(vars{ii})= manta.(vars{ii});
    end
    
    analysis2.SDN=manta.SDN;
    analysis2.hour=stripTime(manta.SDN);
    
    sunrise = stripTime(analysis.day.sunrise(2:end));
    stdsunrise = std(sunrise);
    sunrise = mean(sunrise);
    sunset = stripTime(analysis.night.sunset(2:end-1));
    stdsunset = std(sunset);
    sunset = mean(sunset);
    
    % Isolate data between sunrise and sunset (daytime)
    iuse=inrange(analysis2.hour,[sunrise sunset]);
    analysis2.day.SDN=manta.SDN(iuse);
    
    for ii = 1:length(vars)
        analysis2.day.(vars{ii})=analysis2.(vars{ii})(iuse,:);
        % Set baseline to zero for integration.
        base=min(analysis2.day.(vars{ii}));
        basevar=[vars{ii},'base'];
            for iii=1:length(base)
                analysis2.day.(basevar)(:,iii)=analysis2.day.(vars{ii})(:,iii)-base(iii);
            end
    end
    
    % Get vector for individual days
    analysis2.day.day=zeros(size(iuse));
    day=1;
    d=1;
    while d<length(iuse)
        if iuse(d)==true
            analysis2.day.day(d)=day;
        elseif iuse(d)==false&&iuse(d+1)==true
            day=day+1;
            analysis2.day.day(d+1)=day;
        end
        d=d+1;
    end  
    analysis2.day.day=analysis2.day.day(iuse);
    analysis2.day.day(end)=analysis2.day.day(end-1);
    
    % isolate data between sunset and sunrise (nighttime)
    analysis2.night.SDN=manta.SDN(~iuse);
    
    for ii = 1:length(vars)
        analysis2.night.(vars{ii})=analysis2.(vars{ii})(~iuse,:);
        % Set baseline to zero for integration.
        base=min(analysis2.night.(vars{ii}));
        basevar=[vars{ii},'base'];
            for iii=1:length(base)
                analysis2.night.(basevar)(:,iii)=analysis2.night.(vars{ii})(:,iii)-base(iii);
            end
    end
    
    % Get vector for individual nights
    analysis2.night.night=zeros(size(iuse));
    night=1;
    d=1;
    while d<length(iuse)
        if ~iuse(d)==true
            analysis2.night.night(d)=night;
        elseif ~iuse(d)==false&&~iuse(d+1)==true
            night=night+1;
            analysis2.night.night(d+1)=night;
        end
        d=d+1;
    end  
    analysis2.night.night=analysis2.night.night(~iuse);
    analysis2.night.night(end)=analysis2.night.night(end-1);
    
    % Get vector of minutes and seconds for day and night times.
    analysis2.day.minutes=[0:length(analysis2.day.SDN)]'*5;
    analysis2.night.minutes=[0:length(analysis2.night.SDN)]'*5;
    analysis2.day.secs=[0:length(analysis2.day.SDN)]'*5*60;
    analysis2.night.secs=[0:length(analysis2.night.SDN)]'*5*60;
    
    % Calculate the following values per day:
    %
    % Integrated values for each variable for each sensor. Integral length is converted
    % to seconds to normalize time units. 
    % Ratio of variable to oxygen per sensor. 
    % Maximum
    % Minimum
    % Mean, with stddev.
    % Slope of the best fit line for (var):DOXY and the R-squared value
    
    [~,dayind]=unique(analysis2.day.day);
    analysis2.day.sunrise=analysis2.day.SDN(dayind);
    dayind=[dayind;length(analysis2.day.day)];
    
    for ii=1:length(dayind)-1
        daynum=num2str(ii);
        dayminutes=['day',daynum,'minutes'];
        analysis2.day.(dayminutes)=analysis2.day.minutes(dayind(ii+1))-analysis2.day.minutes(dayind(ii));
        
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
            DOXY=analysis2.day.DOXY(dayind(ii):dayind(ii+1),:);
            basename=[vars{iii},'base'];
            basevar=analysis2.day.(basename)(dayind(ii):dayind(ii+1),:);
            var=analysis2.day.(vars{iii})(dayind(ii):dayind(ii+1),:);
            
            % Max, min, and means
            analysis2.day.(var1)=max(var);
            analysis2.day.(var2)=min(var);
            analysis2.day.(var3)=mean(var);
            analysis2.day.(var4)=std(var);

            % Trapezoidal numerical integration
            analysis2.day.(var5)=trapz(analysis2.day.secs(dayind(ii):dayind(ii+1),:),basevar);

            % Integration ratios
            var0=['intDOXY',daynum];
            analysis2.day.(var6)=analysis2.day.(var5)./analysis2.day.(var0)(1,1);

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
            analysis2.day.(var7)=slopes';
            analysis2.day.(var8)=rsqs';
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
    
    [~,nightind]=unique(analysis2.night.night);
    nightind=[nightind;length(analysis2.night.night)];
    analysis2.night.sunset=analysis2.night.SDN(nightind);
    
    for ii=1:length(nightind)-1
        nightnum=num2str(ii);
        nightminutes=['night',nightnum,'minutes'];
        analysis2.night.(nightminutes)=analysis2.night.minutes(nightind(ii+1))-analysis2.night.minutes(nightind(ii));
        
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
            DOXY=analysis2.night.DOXY(nightind(ii):nightind(ii+1),:);
            basename=[vars{iii},'base'];
            basevar=analysis2.night.(basename)(nightind(ii):nightind(ii+1),:);
            var=analysis2.night.(vars{iii})(nightind(ii):nightind(ii+1),:);
            secs=analysis2.night.secs(nightind(ii):nightind(ii+1),:);
            
            % Max, min, and means
            analysis2.night.(var1)=max(var);
            analysis2.night.(var2)=min(var);
            analysis2.night.(var3)=mean(var);
            analysis2.night.(var4)=std(var);

            % Trapezoidal numerical integration
            analysis2.night.(var5)=trapz(secs,basevar);

            % Integration ratios
            var0=['intDOXY',nightnum];
            analysis2.night.(var6)=analysis2.night.(var5)./analysis2.night.(var0);

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
            analysis2.night.(var7)=slopes';
            analysis2.night.(var8)=rsqs';
        end
    end

    f_name = [name,'_analysis_TIMEbased.mat'];
    
    save(f_name, 'analysis2', 'name', 'sunrise', 'sunset', 'stdsunrise', 'stdsunset');
    
    close all
    
    clearvars -except folder mantafiles analysisfiles vars
    
    
end
    
    
    
    
    
    
    