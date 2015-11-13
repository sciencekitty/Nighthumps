% exoport_all_data.m

% Exports data from analyze_manta_data_PARbased.m and
% analyze_manta_data_TIMEbased.m for upload to the master tent data
% spreadsheet. 

clear all
close all

% folder path where .mat files are kept
folder = '/Users/Sandi/Documents/Nighthumps';
% list of file names for analysis data
PARanalysisfiles = {'flint_analysis_PARbased.mat'
    'vostok_analysis_PARbased.mat'
    'malden_analysis_PARbased.mat'
    'millennium_analysis_PARbased.mat'
    'starbuck_analysis_PARbased.mat'
    'fanning_analysis_PARbased.mat'
    'jarvis_analysis_PARbased.mat'
    'kingman_analysis_PARbased.mat'
    'palmyra_analysis_PARbased.mat'
    'washington_analysis_PARbased.mat'};

TIMEanalysisfiles = {'flint_analysis_TIMEbased.mat'
    'vostok_analysis_TIMEbased.mat'
    'malden_analysis_TIMEbased.mat'
    'millennium_analysis_TIMEbased.mat'
    'starbuck_analysis_TIMEbased.mat'
    'fanning_analysis_TIMEbased.mat'
    'jarvis_analysis_TIMEbased.mat'
    'kingman_analysis_TIMEbased.mat'
    'palmyra_analysis_TIMEbased.mat'
    'washington_analysis_TIMEbased.mat'};

vars={'DOXY'
    'pH'
    'ORP'
    'TC'
    'COND'
    'PSAL'
    };

%PAR based analysis export
for i = 1:length(PARanalysisfiles)
    load(PARanalysisfiles{i});
    
    % Get separate days to concatenate under eachother
    [~,dayind]=unique(analysis.day.day);
    dayind=[dayind;length(analysis.day.day)];
    
    % Set header names for exported columns
    exportHeaders = cell(1,4);
    exportHeaders{1}='Sunrise';
    exportHeaders{2}='Sunset';
    exportHeaders{3}='Daytime_Minutes';
    exportHeaders{4}='Nighttime_Minutes';
    
    exportDay=zeros(6*(length(dayind)-1),8*length(vars)+5);
    dayHeaders=cell(1,8*length(vars)+5);
    idx=1;
    dayminutes=zeros(1,length(dayind)-1);
    
    % Get daytime data matrix
    for ii=1:length(dayind)-1
        daynum=num2str(ii);
        vdx=1;
        var0=['day',daynum,'minutes'];
        var9=['PARmax',daynum];
        var10=['PARmin',daynum];
        var11=['PARmean',daynum];
        var12=['PARstd',daynum];
        var13=['intPAR',daynum];
            
        dayminutes(1,ii)=analysis.day.(var0);
        exportDay(idx:idx+5,vdx)=analysis.day.(var9)';
        dayHeaders{vdx}=[var9(1:end-1),'_Day'];
        vdx=vdx+1;
        exportDay(idx:idx+5,vdx)=analysis.day.(var10)';
        dayHeaders{vdx}=[var10(1:end-1),'_Day'];
        vdx=vdx+1;
        exportDay(idx:idx+5,vdx)=analysis.day.(var11)';
        dayHeaders{vdx}=[var11(1:end-1),'_Day'];
        vdx=vdx+1;
        exportDay(idx:idx+5,vdx)=analysis.day.(var12)';
        dayHeaders{vdx}=[var12(1:end-1),'_Day'];
        vdx=vdx+1;
        exportDay(idx:idx+5,vdx)=analysis.day.(var13)';
        dayHeaders{vdx}=[var13(1:end-1),'_Day'];
        vdx=vdx+1;
        
        for iii=1:length(vars) 
            var1=[vars{iii},'max',daynum];
            var2=[vars{iii},'min',daynum];
            var3=[vars{iii},'mean',daynum];
            var4=[vars{iii},'std',daynum];
            var5=['int',vars{iii},daynum];
            var6=['ratioPAR_',vars{iii},daynum];
            var7=['slopesPAR_',vars{iii},daynum];
            var8=['rsqPAR_',vars{iii},daynum];

            exportDay(idx:idx+5,vdx)=analysis.day.(var1)';
            dayHeaders{vdx}=[var1(1:end-1),'_Day'];
            vdx=vdx+1;
            exportDay(idx:idx+5,vdx)=analysis.day.(var2)';
            dayHeaders{vdx}=[var2(1:end-1),'_Day'];
            vdx=vdx+1;
            exportDay(idx:idx+5,vdx)=analysis.day.(var3)';
            dayHeaders{vdx}=[var3(1:end-1),'_Day'];
            vdx=vdx+1;
            exportDay(idx:idx+5,vdx)=analysis.day.(var4)';
            dayHeaders{vdx}=[var4(1:end-1),'_Day'];
            vdx=vdx+1;
            exportDay(idx:idx+5,vdx)=analysis.day.(var5)';
            dayHeaders{vdx}=[var5(1:end-1),'_Day'];
            vdx=vdx+1;
            exportDay(idx:idx+5,vdx)=analysis.day.(var6)';
            dayHeaders{vdx}=[var6(1:end-1),'_Day'];
            vdx=vdx+1;
            exportDay(idx:idx+5,vdx)=analysis.day.(var7)';
            dayHeaders{vdx}=[var7(1:end-1),'_Day'];
            vdx=vdx+1;
            exportDay(idx:idx+5,vdx)=analysis.day.(var8)';
            dayHeaders{vdx}=[var8(1:end-1),'_Day'];
            vdx=vdx+1;
        end
        idx=idx+6;
    end
    
    % Get separate nights to concatenate under eachother
    [~,nightind]=unique(analysis.night.night);
    nightind=[nightind;length(analysis.night.night)];
    
    exportNight=zeros(6*(length(dayind)-1),8*length(vars));
    nightHeaders=cell(1,8*length(vars));
    idx=1;
    nightminutes=zeros(1,length(dayind)-1);
    
    % Get nighttime data matrix
    for ii=1:length(nightind)-1
        nightnum=num2str(ii);
        vdx=1;
        var0=['night',nightnum,'minutes'];
        nightminutes(1,ii)=analysis.night.(var0);
        
        for iii=1:length(vars) 
            var1=[vars{iii},'max',nightnum];
            var2=[vars{iii},'min',nightnum];
            var3=[vars{iii},'mean',nightnum];
            var4=[vars{iii},'std',nightnum];
            var5=['int',vars{iii},nightnum];
            var6=['ratioDOXY_',vars{iii},nightnum];
            var7=['slopesDOXY_',vars{iii},nightnum];
            var8=['rsqDOXY_',vars{iii},nightnum];
            
            exportNight(idx:idx+5,vdx)=analysis.night.(var1)';
            nightHeaders{vdx}=[var1(1:end-1),'_Night'];
            vdx=vdx+1;
            exportNight(idx:idx+5,vdx)=analysis.night.(var2)';
            nightHeaders{vdx}=[var2(1:end-1),'_Night'];
            vdx=vdx+1;
            exportNight(idx:idx+5,vdx)=analysis.night.(var3)';
            nightHeaders{vdx}=[var3(1:end-1),'_Night'];
            vdx=vdx+1;
            exportNight(idx:idx+5,vdx)=analysis.night.(var4)';
            nightHeaders{vdx}=[var4(1:end-1),'_Night'];
            vdx=vdx+1;
            exportNight(idx:idx+5,vdx)=analysis.night.(var5)';
            nightHeaders{vdx}=[var5(1:end-1),'_Night'];
            vdx=vdx+1;
            exportNight(idx:idx+5,vdx)=analysis.night.(var6)';
            nightHeaders{vdx}=[var6(1:end-1),'_Night'];
            vdx=vdx+1;
            exportNight(idx:idx+5,vdx)=analysis.night.(var7)';
            nightHeaders{vdx}=[var7(1:end-1),'_Night'];
            vdx=vdx+1;
            exportNight(idx:idx+5,vdx)=analysis.night.(var8)';
            nightHeaders{vdx}=[var8(1:end-1),'_Night'];
            vdx=vdx+1;
        end
        idx=idx+6;
        
    end
    
    exportHeaders=[exportHeaders,dayHeaders,nightHeaders];

    rise=zeros(length(exportDay(:,1)),1);
    set=zeros(length(exportDay(:,1)),1);
    daymin=zeros(length(exportDay(:,1)),1);
    nitmin=zeros(length(exportDay(:,1)),1);
    idx=1;
    for ii=1:length(dayind)-1
        for iii=1:6
        rise(idx,1)=analysis.day.sunrise(ii,1);
        set(idx,1)=analysis.night.sunset(ii,1);
        daymin(idx,1)=dayminutes(1,ii);
        nitmin(idx,1)=nightminutes(1,ii);
        idx=idx+1;
        end
    end
    rise=exceltime(datetime(rise,'ConvertFrom','datenum'),'1900');
    set=exceltime(datetime(set,'ConvertFrom','datenum'),'1900');
    
    exportMat=array2table([rise,set,daymin,nitmin,exportDay,exportNight]);
    exportMat.Properties.VariableNames=exportHeaders;
    filename=[name,'_PARanalysis.txt'];
    writetable(exportMat,filename);
    
    
   
    clearvars -except vars PARanalysisfiles TIMEanalysisfiles
       
end

%TIME based analysis export
for i = 1:length(TIMEanalysisfiles)
    load(TIMEanalysisfiles{i});
    
    % Get separate days to concatenate under eachother
    [~,dayind]=unique(analysis2.day.day);
    dayind=[dayind;length(analysis2.day.day)];
    
    % Set header names for exported columns
    exportHeaders = cell(1,4);
    exportHeaders{1}='Sunrise';
    exportHeaders{2}='Sunset';
    exportHeaders{3}='Daytime_Minutes';
    exportHeaders{4}='Nighttime_Minutes';
    
    exportDay=zeros(6*(length(dayind)-1),8*length(vars));
    dayHeaders=cell(1,8*length(vars));
    idx=1;
    dayminutes=zeros(1,length(dayind)-1);
    
    % Get daytime data matrix
    for ii=1:length(dayind)-1
        daynum=num2str(ii);
        vdx=1;
        var0=['day',daynum,'minutes'];
        var9=['PARmax',daynum];
        var10=['PARmin',daynum];
        var11=['PARmean',daynum];
        var12=['PARstd',daynum];
        var13=['intPAR',daynum];
        
        dayminutes(1,ii)=analysis2.day.(var0);
        exportDay(idx:idx+5,vdx)=analysis2.day.(var9)';
        dayHeaders{vdx}=[var9(1:end-1),'_Day'];
        vdx=vdx+1;
        exportDay(idx:idx+5,vdx)=analysis2.day.(var10)';
        dayHeaders{vdx}=[var10(1:end-1),'_Day'];
        vdx=vdx+1;
        exportDay(idx:idx+5,vdx)=analysis2.day.(var11)';
        dayHeaders{vdx}=[var11(1:end-1),'_Day'];
        vdx=vdx+1;
        exportDay(idx:idx+5,vdx)=analysis2.day.(var12)';
        dayHeaders{vdx}=[var12(1:end-1),'_Day'];
        vdx=vdx+1;
        exportDay(idx:idx+5,vdx)=analysis2.day.(var13)';
        dayHeaders{vdx}=[var13(1:end-1),'_Day'];
        vdx=vdx+1;
        
        for iii=1:length(vars) 
            var1=[vars{iii},'max',daynum];
            var2=[vars{iii},'min',daynum];
            var3=[vars{iii},'mean',daynum];
            var4=[vars{iii},'std',daynum];
            var5=['int',vars{iii},daynum];
            var6=['ratioPAR_',vars{iii},daynum];
            var7=['slopesPAR_',vars{iii},daynum];
            var8=['rsqPAR_',vars{iii},daynum];
            
            exportDay(idx:idx+5,vdx)=analysis2.day.(var1)';
            dayHeaders{vdx}=[var1(1:end-1),'_Day'];
            vdx=vdx+1;
            exportDay(idx:idx+5,vdx)=analysis2.day.(var2)';
            dayHeaders{vdx}=[var2(1:end-1),'_Day'];
            vdx=vdx+1;
            exportDay(idx:idx+5,vdx)=analysis2.day.(var3)';
            dayHeaders{vdx}=[var3(1:end-1),'_Day'];
            vdx=vdx+1;
            exportDay(idx:idx+5,vdx)=analysis2.day.(var4)';
            dayHeaders{vdx}=[var4(1:end-1),'_Day'];
            vdx=vdx+1;
            exportDay(idx:idx+5,vdx)=analysis2.day.(var5)';
            dayHeaders{vdx}=[var5(1:end-1),'_Day'];
            vdx=vdx+1;
            exportDay(idx:idx+5,vdx)=analysis2.day.(var6)';
            dayHeaders{vdx}=[var6(1:end-1),'_Day'];
            vdx=vdx+1;
            exportDay(idx:idx+5,vdx)=analysis2.day.(var7)';
            dayHeaders{vdx}=[var7(1:end-1),'_Day'];
            vdx=vdx+1;
            exportDay(idx:idx+5,vdx)=analysis2.day.(var8)';
            dayHeaders{vdx}=[var8(1:end-1),'_Day'];
            vdx=vdx+1;
        end
        idx=idx+6;
    end
    
    % Get separate nights to concatenate under eachother
    [~,nightind]=unique(analysis2.night.night);
    nightind=[nightind;length(analysis2.night.night)];
    
    exportNight=zeros(6*(length(dayind)-1),8*length(vars));
    nightHeaders=cell(1,8*length(vars));
    idx=1;
    nightminutes=zeros(1,length(dayind)-1);
    
    % Get nighttime data matrix
    for ii=1:length(nightind)-1
        nightnum=num2str(ii);
        vdx=1;
        var0=['night',nightnum,'minutes'];
        nightminutes(1,ii)=analysis2.night.(var0);
        
        for iii=1:length(vars) 
            var1=[vars{iii},'max',nightnum];
            var2=[vars{iii},'min',nightnum];
            var3=[vars{iii},'mean',nightnum];
            var4=[vars{iii},'std',nightnum];
            var5=['int',vars{iii},nightnum];
            var6=['ratioDOXY_',vars{iii},nightnum];
            var7=['slopesDOXY_',vars{iii},nightnum];
            var8=['rsqDOXY_',vars{iii},nightnum];
            
            exportNight(idx:idx+5,vdx)=analysis2.night.(var1)';
            nightHeaders{vdx}=[var1(1:end-1),'_Night'];
            vdx=vdx+1;
            exportNight(idx:idx+5,vdx)=analysis2.night.(var2)';
            nightHeaders{vdx}=[var2(1:end-1),'_Night'];
            vdx=vdx+1;
            exportNight(idx:idx+5,vdx)=analysis2.night.(var3)';
            nightHeaders{vdx}=[var3(1:end-1),'_Night'];
            vdx=vdx+1;
            exportNight(idx:idx+5,vdx)=analysis2.night.(var4)';
            nightHeaders{vdx}=[var4(1:end-1),'_Night'];
            vdx=vdx+1;
            exportNight(idx:idx+5,vdx)=analysis2.night.(var5)';
            nightHeaders{vdx}=[var5(1:end-1),'_Night'];
            vdx=vdx+1;
            exportNight(idx:idx+5,vdx)=analysis2.night.(var6)';
            nightHeaders{vdx}=[var6(1:end-1),'_Night'];
            vdx=vdx+1;
            exportNight(idx:idx+5,vdx)=analysis2.night.(var7)';
            nightHeaders{vdx}=[var7(1:end-1),'_Night'];
            vdx=vdx+1;
            exportNight(idx:idx+5,vdx)=analysis2.night.(var8)';
            nightHeaders{vdx}=[var8(1:end-1),'_Night'];
            vdx=vdx+1;
        end
        idx=idx+6;
        
    end
    
    exportHeaders=[exportHeaders,dayHeaders,nightHeaders];

    rise=zeros(length(exportDay(:,1)),1);
    set=zeros(length(exportDay(:,1)),1);
    daymin=zeros(length(exportDay(:,1)),1);
    nitmin=zeros(length(exportDay(:,1)),1);
    idx=1;
    for ii=1:length(dayind)-1
        for iii=1:6
        rise(idx,1)=analysis2.day.sunrise(ii,1);
        set(idx,1)=analysis2.night.sunset(ii,1);
        daymin(idx,1)=dayminutes(1,ii);
        nitmin(idx,1)=nightminutes(1,ii);
        idx=idx+1;
        end
    end
    rise=exceltime(datetime(rise,'ConvertFrom','datenum'),'1900');
    set=exceltime(datetime(set,'ConvertFrom','datenum'),'1900');
    
    exportMat=array2table([rise,set,daymin,nitmin,exportDay,exportNight]);
    exportMat.Properties.VariableNames=exportHeaders;
    filename=[name,'_TIMEanalysis.txt'];
    writetable(exportMat,filename);
    
    
   
    clearvars -except vars PARanalysisfiles TIMEanalysisfiles
       
end

    
    
    




