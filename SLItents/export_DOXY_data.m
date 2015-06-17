% export_DOXY_data.m
% Exports anaylzed manta data to txt files and generates summary figures.

clear all
close all

% folder path where .mat files are kept
folder = '/Users/sandicalhoun/Nighthumps/AnalyzedData';
% list of file names for analyzed data
analysisfilesDay={'flint_analysis_day.mat'
    'vostok_analysis_day.mat'
    'millennium_analysis_day.mat'
    'starbuck_analysis_day.mat'
    'malden_analysis_day.mat'
    'jarvis_analysis_day.mat'
    'fanning_analysis_day.mat'
    'washington_analysis_day.mat'
    'palmyra_analysis_day.mat'
    'kingman_analysis_day.mat'};

load('peaks.mat');

vars={'DOXY'
    'pH'
    'ORP'
    'TC'};

for i=1:length(vars)
    var1=[vars{i},'mean'];
    var2=[vars{i},'std'];
    var3=['int',vars{i}];
    var4=['ratio',vars{i},'_PAR'];
    var5=['slopes',vars{i},'_PAR'];
    var6=['rsq',vars{i},'_PAR'];
    Max=[vars{i},'max'];
    Min=[vars{i},'min'];
    max_locs=[vars{i},'max_locs'];
    min_locs=[vars{i},'min_locs'];
    dmax=['d',vars{i},'max'];
    dmax_locs=['d',vars{i},'max_locs'];
    dmin=['d',vars{i},'min'];
    dmin_locs=['d',vars{i},'min_locs'];
    island={};
    latitude=-12;

    for ii = 1:length(analysisfilesDay)
        load(analysisfilesDay{ii});

        daynum=max(analysis.day);
        daylat=zeros(daynum,1);

        switch analysisfilesDay{ii}
            case 'flint_analysis_day.mat'
%                 latitude=-11.26;
            case 'vostok_analysis_day.mat'
%                 latitude=-10.06;
            case 'millennium_analysis_day.mat'
%                 latitude=-9.57;
                daynum=daynum-1;
            case 'starbuck_analysis_day.mat'
%                 latitude=-5.37;
                daynum=daynum-1;
            case 'malden_analysis_day.mat'
%                 latitude=-4.01;
                daynum=daynum-1;
            case 'jarvis_analysis_day.mat'
%                 latitude=-0.22;
            case 'fanning_analysis_day.mat'
%                 latitude=3.52;
            case 'washington_analysis_day.mat'
%                 latitude=4.43;
            case 'palmyra_analysis_day.mat'
%                 latitude=5.52;
            case 'kingman_analysis_day.mat'
%                 latitude=6.24;
        end
        
        daylat(1,1)=latitude;
        for iii=2:daynum
            daylat(iii,1)=daylat(iii-1,1)+0.5;
        end
        
        daylat(daylat == 0) = NaN;
        inonan = ~isnan(daylat);
        daylat=daylat(inonan);
        
        latitude=max(daylat)+2;
        
        dayfigs.(name).daylat=zeros(daynum,6);
        
        for iii=1:6
            dayfigs.(name).daylat(:,iii)=daylat;
        end
        
        means=zeros(daynum,6);
        sds=zeros(daynum,6);
        ints=zeros(daynum,6);
        ratios=zeros(daynum,6);
        slopes=zeros(daynum,6);
        rsqs=zeros(daynum,6);

        for iii=1:daynum
            num=num2str(iii);
            varA=[vars{i},'mean',num];
            varB=[vars{i},'std',num];
            varC=['int',vars{i},num];
            varD=['ratio',vars{i},'_PAR',num];
            varE=['slopes',vars{i},'_PAR',num];
            varF=['rsq',vars{i},'_PAR',num];

            means(iii,:)=analysis.daily.(varA)';
            sds(iii,:)=analysis.daily.(varB)';
            ints(iii,:)=analysis.daily.(varC)';
            ratios(iii,:)=analysis.daily.(varD)';
            slopes(iii,:)=analysis.daily.(varE)';
            rsqs(iii,:)=analysis.daily.(varF)';
            
        end

        dayfigs.(name).(var1)=means;
        dayfigs.(name).(var2)=sds;
        dayfigs.(name).(var3)=ints;
        dayfigs.(name).(var4)=ratios;
        dayfigs.(name).(var5)=slopes;
        dayfigs.(name).(var6)=rsqs;

        rows={'Sensor1'
            'Sensor2'
            'Sensor3'
            'Sensor4'
            'Sensor5'
            'Sensor6'};

        summary=struct2table(analysis.daily);
        summary.Properties.RowNames=rows;
        filename=[name,'_dailySummary.txt'];
        writetable(summary,filename,'Delimiter','\t','WriteRowNames',1);
        
        peakslat(1,1)=latitude;
        for iii=2:length(peaks.(name).(dmax)(:,1))
            peakslat(iii,1)=peakslat(iii-1,1)+0.5;
        end
        dayfigs.(name).peakslat=zeros(length(peakslat),6);
        for iii=1:6
            dayfigs.(name).peakslat(:,iii)=peakslat;
        end

        incrate=array2table([peaks.(name).(dmax);exceltime(datetime(peaks.(name).(dmax_locs),...
            'ConvertFrom','datenum'),'1904')],'VariableNames',rows);
        filename=[name,'_',dmax,'.txt'];
        writetable(incrate,filename,'Delimiter','\t');
        dayfigs.(name).(dmax)=peaks.(name).(dmax);
        Date=datetime(peaks.(name).(dmax_locs),'ConvertFrom','datenum');
        inonat=~isnat(Date);
        Y=Date.Year;
        M=Date.Month;
        D=Date.Day;
        for iii=1:size(Date,1)
            for iv=1:size(Date,2);
                if inonat(iii,iv)==1
                    Y(iii,iv)=2000;
                    M(iii,iv)=1;
                    D(iii,iv)=1;
                end
            end
        end
        H=Date.Hour;
        S=Date.Second;
        MI=Date.Minute;
        dayfigs.(name).(dmax_locs)=datenum(Y,M,D,H,MI,S);
        

        decrate=array2table([peaks.(name).(dmin);exceltime(datetime(peaks.(name).(dmin_locs),...
            'ConvertFrom','datenum'),'1904')],'VariableNames',rows);
        filename=[name,'_',dmin,'.txt'];
        writetable(decrate,filename,'Delimiter','\t');
        dayfigs.(name).(dmin)=peaks.(name).(dmin);
        Date=datetime(peaks.(name).(dmin_locs),'ConvertFrom','datenum');
        inonat=~isnat(Date);
        Y=Date.Year;
        M=Date.Month;
        D=Date.Day;
        for iii=1:size(Date,1)
            for iv=1:size(Date,2);
                if inonat(iii,iv)==1
                    Y(iii,iv)=2000;
                    M(iii,iv)=1;
                    D(iii,iv)=1;
                end
            end
        end
        H=Date.Hour;
        S=Date.Second;
        MI=Date.Minute;
        dayfigs.(name).(dmin_locs)=datenum(Y,M,D,H,MI,S);
        
        maxes=array2table([peaks.(name).(Max);exceltime(datetime(peaks.(name).(max_locs),...
            'ConvertFrom','datenum'),'1904')],'VariableNames',rows);
        filename=[name,'_',Max,'.txt'];
        writetable(maxes,filename,'Delimiter','\t');
        dayfigs.(name).(Max)=peaks.(name).(Max);
        Date=datetime(peaks.(name).(max_locs),'ConvertFrom','datenum');
        inonat=~isnat(Date);
        Y=Date.Year;
        M=Date.Month;
        D=Date.Day;
        for iii=1:size(Date,1)
            for iv=1:size(Date,2);
                if inonat(iii,iv)==1
                    Y(iii,iv)=2000;
                    M(iii,iv)=1;
                    D(iii,iv)=1;
                end
            end
        end
        H=Date.Hour;
        S=Date.Second;
        MI=Date.Minute;
        dayfigs.(name).(max_locs)=datenum(Y,M,D,H,MI,S);
        
        mins=array2table([peaks.(name).(Min);exceltime(datetime(peaks.(name).(min_locs),...
            'ConvertFrom','datenum'),'1904')],'VariableNames',rows);
        filename=[name,'_',Min,'.txt'];
        writetable(mins,filename,'Delimiter','\t');
        dayfigs.(name).(Min)=peaks.(name).(Min);
        Date=datetime(peaks.(name).(min_locs),'ConvertFrom','datenum');
        inonat=~isnat(Date);
        Y=Date.Year;
        M=Date.Month;
        D=Date.Day;
        for iii=1:size(Date,1)
            for iv=1:size(Date,2);
                if inonat(iii,iv)==1
                    Y(iii,iv)=2000;
                    M(iii,iv)=1;
                    D(iii,iv)=1;
                end
            end
        end
        H=Date.Hour;
        S=Date.Second;
        MI=Date.Minute;
        dayfigs.(name).(min_locs)=datenum(Y,M,D,H,MI,S);
        
        island{ii}=name;

    end
    
    f1 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
    hold on
    grid on
    ax=gca;
    
    errorbar(dayfigs.(island{1}).daylat,dayfigs.(island{1}).(var1),dayfigs.(island{1}).(var2),'d','Color',[0 0.3 0.1]);
    errorbar(dayfigs.(island{2}).daylat,dayfigs.(island{2}).(var1),dayfigs.(island{2}).(var2),'d','Color',[0 0.5 0.2]);
    errorbar(dayfigs.(island{3}).daylat,dayfigs.(island{3}).(var1),dayfigs.(island{3}).(var2),'d','Color',[0 0.5 0.4]);
    errorbar(dayfigs.(island{4}).daylat,dayfigs.(island{4}).(var1),dayfigs.(island{4}).(var2),'d','Color',[0 0.6 0.2]);
    errorbar(dayfigs.(island{5}).daylat,dayfigs.(island{5}).(var1),dayfigs.(island{5}).(var2),'d','Color',[0 0.6 0.3]);
    errorbar(dayfigs.(island{6}).daylat,dayfigs.(island{6}).(var1),dayfigs.(island{6}).(var2),'d','Color',[0 0.8 0.4]);
    errorbar(dayfigs.(island{7}).daylat,dayfigs.(island{7}).(var1),dayfigs.(island{7}).(var2),'d','Color',[0 0.3 0.8]);
    errorbar(dayfigs.(island{8}).daylat,dayfigs.(island{8}).(var1),dayfigs.(island{8}).(var2),'d','Color',[0 0.4 1]);
    errorbar(dayfigs.(island{9}).daylat,dayfigs.(island{9}).(var1),dayfigs.(island{9}).(var2),'d','Color',[0 0.6 1]);
    errorbar(dayfigs.(island{10}).daylat,dayfigs.(island{10}).(var1),dayfigs.(island{10}).(var2),'d','Color',[0 0.8 1]);

    title('Daily Means');
    ylabel('Mean');
    legend(island, 'Box','off');
    ax.XTick=[-20:3:20];
    ax.XTickLabel=island;
    filename=[vars{i},'_DailyMeans.eps'];
    saveas(f1, filename, 'epsc');
    
    f2 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
    hold on
    grid on
    ax=gca;
    
    plot(dayfigs.(island{1}).daylat,dayfigs.(island{1}).(var3),'d','Color',[0 0.3 0.1]);
    plot(dayfigs.(island{2}).daylat,dayfigs.(island{2}).(var3),'d','Color',[0 0.5 0.2]);
    plot(dayfigs.(island{3}).daylat,dayfigs.(island{3}).(var3),'d','Color',[0 0.5 0.4]);
    plot(dayfigs.(island{4}).daylat,dayfigs.(island{4}).(var3),'d','Color',[0 0.6 0.2]);
    plot(dayfigs.(island{5}).daylat,dayfigs.(island{5}).(var3),'d','Color',[0 0.6 0.3]);
    plot(dayfigs.(island{6}).daylat,dayfigs.(island{6}).(var3),'d','Color',[0 0.8 0.4]);
    plot(dayfigs.(island{7}).daylat,dayfigs.(island{7}).(var3),'d','Color',[0 0.3 0.8]);
    plot(dayfigs.(island{8}).daylat,dayfigs.(island{8}).(var3),'d','Color',[0 0.4 1]);
    plot(dayfigs.(island{9}).daylat,dayfigs.(island{9}).(var3),'d','Color',[0 0.6 1]);
    plot(dayfigs.(island{10}).daylat,dayfigs.(island{10}).(var3),'d','Color',[0 0.8 1]);

    title('Daily Integrated Totals');
    ylabel('Integrated Total');
    legend(island, 'Box','off');
    ax.XTick=[-20:3:20];
    ax.XTickLabel=island;
    filename=[vars{i},'_DailyTotals.eps'];
    saveas(f2, filename, 'epsc');
    
    f3 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
    hold on
    grid on
    ax=gca;
    
    plot(dayfigs.(island{1}).daylat,dayfigs.(island{1}).(var4),'d','Color',[0 0.3 0.1]);
    plot(dayfigs.(island{2}).daylat,dayfigs.(island{2}).(var4),'d','Color',[0 0.5 0.2]);
    plot(dayfigs.(island{3}).daylat,dayfigs.(island{3}).(var4),'d','Color',[0 0.5 0.4]);
    plot(dayfigs.(island{4}).daylat,dayfigs.(island{4}).(var4),'d','Color',[0 0.6 0.2]);
    plot(dayfigs.(island{5}).daylat,dayfigs.(island{5}).(var4),'d','Color',[0 0.6 0.3]);
    plot(dayfigs.(island{6}).daylat,dayfigs.(island{6}).(var4),'d','Color',[0 0.8 0.4]);
    plot(dayfigs.(island{7}).daylat,dayfigs.(island{7}).(var4),'d','Color',[0 0.3 0.8]);
    plot(dayfigs.(island{8}).daylat,dayfigs.(island{8}).(var4),'d','Color',[0 0.4 1]);
    plot(dayfigs.(island{9}).daylat,dayfigs.(island{9}).(var4),'d','Color',[0 0.6 1]);
    plot(dayfigs.(island{10}).daylat,dayfigs.(island{10}).(var4),'d','Color',[0 0.8 1]);

    title('Daily Ratios');
    ylabel('Ratio');
    legend(island, 'Box','off');
    ax.XTick=[-20:3:20];
    ax.XTickLabel=island;
    filename=[vars{i},'_DailyRatios.eps'];
    saveas(f3, filename, 'epsc');
    
    f4 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
    hold on
    grid on
    ax=gca;
    
    plot(dayfigs.(island{1}).daylat,dayfigs.(island{1}).(var5),'d','Color',[0 0.3 0.1]);
    plot(dayfigs.(island{2}).daylat,dayfigs.(island{2}).(var5),'d','Color',[0 0.5 0.2]);
    plot(dayfigs.(island{3}).daylat,dayfigs.(island{3}).(var5),'d','Color',[0 0.5 0.4]);
    plot(dayfigs.(island{4}).daylat,dayfigs.(island{4}).(var5),'d','Color',[0 0.6 0.2]);
    plot(dayfigs.(island{5}).daylat,dayfigs.(island{5}).(var5),'d','Color',[0 0.6 0.3]);
    plot(dayfigs.(island{6}).daylat,dayfigs.(island{6}).(var5),'d','Color',[0 0.8 0.4]);
    plot(dayfigs.(island{7}).daylat,dayfigs.(island{7}).(var5),'d','Color',[0 0.3 0.8]);
    plot(dayfigs.(island{8}).daylat,dayfigs.(island{8}).(var5),'d','Color',[0 0.4 1]);
    plot(dayfigs.(island{9}).daylat,dayfigs.(island{9}).(var5),'d','Color',[0 0.6 1]);
    plot(dayfigs.(island{10}).daylat,dayfigs.(island{10}).(var5),'d','Color',[0 0.8 1]);
    
    title('Daily Slopes');
    ylabel('Slopes');
    legend(island, 'Box','off');
    ax.XTick=[-20:3:20];    
    ax.XTickLabel=island;
    filename=[vars{i},'_DailySlopes.eps'];
    saveas(f4, filename, 'epsc');
    
    f5 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
    hold on
    grid on
    ax=gca;
    
    plot(dayfigs.(island{1}).daylat,dayfigs.(island{1}).(var6),'+','Color',[0 0.3 0.1]);
    plot(dayfigs.(island{2}).daylat,dayfigs.(island{2}).(var6),'+','Color',[0 0.5 0.2]);
    plot(dayfigs.(island{3}).daylat,dayfigs.(island{3}).(var6),'+','Color',[0 0.5 0.4]);
    plot(dayfigs.(island{4}).daylat,dayfigs.(island{4}).(var6),'+','Color',[0 0.6 0.2]);
    plot(dayfigs.(island{5}).daylat,dayfigs.(island{5}).(var6),'+','Color',[0 0.6 0.3]);
    plot(dayfigs.(island{6}).daylat,dayfigs.(island{6}).(var6),'+','Color',[0 0.8 0.4]);
    plot(dayfigs.(island{7}).daylat,dayfigs.(island{7}).(var6),'+','Color',[0 0.3 0.8]);
    plot(dayfigs.(island{8}).daylat,dayfigs.(island{8}).(var6),'+','Color',[0 0.4 1]);
    plot(dayfigs.(island{9}).daylat,dayfigs.(island{9}).(var6),'+','Color',[0 0.6 1]);
    plot(dayfigs.(island{10}).daylat,dayfigs.(island{10}).(var6),'+','Color',[0 0.8 1]);
    
    title('Daily R-Squared values');
    ylabel('R-Squared');
    legend(island, 'Box','off');
    ax.XTick=[-20:3:20];    
    ax.XTickLabel=island;
    filename=[vars{i},'_DailyRsq.eps'];
    saveas(f5, filename, 'epsc');
    
    f6 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
    hold on
    grid on
    ax=gca;

    plot(dayfigs.(island{2}).peakslat,dayfigs.(island{2}).(dmax),'o','Color',[0 0.5 0.2]);
    plot(dayfigs.(island{3}).peakslat,dayfigs.(island{3}).(dmax),'o','Color',[0 0.5 0.4]);
    plot(dayfigs.(island{4}).peakslat,dayfigs.(island{4}).(dmax),'o','Color',[0 0.6 0.2]);
    plot(dayfigs.(island{5}).peakslat,dayfigs.(island{5}).(dmax),'o','Color',[0 0.6 0.3]);
    plot(dayfigs.(island{6}).peakslat,dayfigs.(island{6}).(dmax),'o','Color',[0 0.8 0.4]);
    plot(dayfigs.(island{7}).peakslat,dayfigs.(island{7}).(dmax),'o','Color',[0 0.3 0.8]);
    plot(dayfigs.(island{8}).peakslat,dayfigs.(island{8}).(dmax),'o','Color',[0 0.4 1]);
    plot(dayfigs.(island{9}).peakslat,dayfigs.(island{9}).(dmax),'o','Color',[0 0.6 1]);
    plot(dayfigs.(island{10}).peakslat,dayfigs.(island{10}).(dmax),'o','Color',[0 0.8 1]);

    title('Daily Max Rates');
    ylabel('Rate');
    legend(island,'Box','off');
    filename=[vars{i},'_DailyMaxRates.eps'];
    ax.XTick=[-20:3:20];    
    ax.XTickLabel=island;
    saveas(f6, filename, 'epsc');    
    
    f7 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
    hold on
    grid on
    ax=gca;

    plot(dayfigs.(island{2}).peakslat,dayfigs.(island{2}).(dmin),'d','Color',[0 0.5 0.2]);
    plot(dayfigs.(island{3}).peakslat,dayfigs.(island{3}).(dmin),'d','Color',[0 0.5 0.4]);
    plot(dayfigs.(island{4}).peakslat,dayfigs.(island{4}).(dmin),'d','Color',[0 0.6 0.2]);
    plot(dayfigs.(island{5}).peakslat,dayfigs.(island{5}).(dmin),'d','Color',[0 0.6 0.3]);
    plot(dayfigs.(island{6}).peakslat,dayfigs.(island{6}).(dmin),'d','Color',[0 0.8 0.4]);
    plot(dayfigs.(island{7}).peakslat,dayfigs.(island{7}).(dmin),'d','Color',[0 0.3 0.8]);
    plot(dayfigs.(island{8}).peakslat,dayfigs.(island{8}).(dmin),'d','Color',[0 0.4 1]);
    plot(dayfigs.(island{9}).peakslat,dayfigs.(island{9}).(dmin),'d','Color',[0 0.6 1]);
    plot(dayfigs.(island{10}).peakslat,dayfigs.(island{10}).(dmin),'d','Color',[0 0.8 1]);

    title('Daily Min Rates');
    ylabel('Rate');
    legend(island,'Box','off');
    filename=[vars{i},'_DailyMinRates.eps'];
    ax.XTick=[-20:3:20];    
    ax.XTickLabel=island;
    saveas(f7, filename, 'epsc');
    
    f8 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
    hold on
    grid on
    ax=gca;

    plot(dayfigs.(island{2}).peakslat,dayfigs.(island{2}).(dmax_locs),'o','Color',[0 0.5 0.2],'MarkerFaceColor',[0 0.5 0.2]);
    plot(dayfigs.(island{3}).peakslat,dayfigs.(island{3}).(dmax_locs),'o','Color',[0 0.5 0.4],'MarkerFaceColor',[0 0.5 0.4]);
    plot(dayfigs.(island{4}).peakslat,dayfigs.(island{4}).(dmax_locs),'o','Color',[0 0.6 0.2],'MarkerFaceColor',[0 0.6 0.2]);
    plot(dayfigs.(island{5}).peakslat,dayfigs.(island{5}).(dmax_locs),'o','Color',[0 0.6 0.3],'MarkerFaceColor',[0 0.6 0.3]);
    plot(dayfigs.(island{6}).peakslat,dayfigs.(island{6}).(dmax_locs),'o','Color',[0 0.8 0.4],'MarkerFaceColor',[0 0.8 0.4]);
    plot(dayfigs.(island{7}).peakslat,dayfigs.(island{7}).(dmax_locs),'o','Color',[0 0.3 0.8],'MarkerFaceColor',[0 0.3 0.8]);
    plot(dayfigs.(island{8}).peakslat,dayfigs.(island{8}).(dmax_locs),'o','Color',[0 0.4 1],'MarkerFaceColor',[0 0.4 1]);
    plot(dayfigs.(island{9}).peakslat,dayfigs.(island{9}).(dmax_locs),'o','Color',[0 0.6 1],'MarkerFaceColor',[0 0.6 1]);
    plot(dayfigs.(island{10}).peakslat,dayfigs.(island{10}).(dmax_locs),'o','Color',[0 0.8 1],'MarkerFaceColor',[0 0.8 1]);

    title('Daily Max Rate Times');
    ylabel('Time');
    datetick('y', 'HH:MM');
    legend(island,'Box','off');
    filename=[vars{i},'_DailyMaxRateTimes.eps'];
    ax.XTick=[-20:3:20];    
    ax.XTickLabel=island;
    saveas(f8, filename, 'epsc');
    
    f9 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
    hold on
    grid on
    ax=gca;

    plot(dayfigs.(island{2}).peakslat,dayfigs.(island{2}).(dmin_locs),'o','Color',[0 0.5 0.2],'MarkerFaceColor',[0 0.5 0.2]);
    plot(dayfigs.(island{3}).peakslat,dayfigs.(island{3}).(dmin_locs),'o','Color',[0 0.5 0.4],'MarkerFaceColor',[0 0.5 0.4]);
    plot(dayfigs.(island{4}).peakslat,dayfigs.(island{4}).(dmin_locs),'o','Color',[0 0.6 0.2],'MarkerFaceColor',[0 0.6 0.2]);
    plot(dayfigs.(island{5}).peakslat,dayfigs.(island{5}).(dmin_locs),'o','Color',[0 0.6 0.3],'MarkerFaceColor',[0 0.6 0.3]);
    plot(dayfigs.(island{6}).peakslat,dayfigs.(island{6}).(dmin_locs),'o','Color',[0 0.8 0.4],'MarkerFaceColor',[0 0.8 0.4]);
    plot(dayfigs.(island{7}).peakslat,dayfigs.(island{7}).(dmin_locs),'o','Color',[0 0.3 0.8],'MarkerFaceColor',[0 0.3 0.8]);
    plot(dayfigs.(island{8}).peakslat,dayfigs.(island{8}).(dmin_locs),'o','Color',[0 0.4 1],'MarkerFaceColor',[0 0.4 1]);
    plot(dayfigs.(island{9}).peakslat,dayfigs.(island{9}).(dmin_locs),'o','Color',[0 0.6 1],'MarkerFaceColor',[0 0.6 1]);
    plot(dayfigs.(island{10}).peakslat,dayfigs.(island{10}).(dmin_locs),'o','Color',[0 0.8 1],'MarkerFaceColor',[0 0.8 1]);

    title('Daily Min Rate Times');
    ylabel('Time');
    datetick('y', 'HH:MM');
    legend(island,'Box','off');
    filename=[vars{i},'_DailyMinRateTimes.eps'];
    ax.XTick=[-20:3:20];    
    ax.XTickLabel=island;
    saveas(f9, filename, 'epsc');
    
    f10 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
    hold on
    grid on
    ax=gca;

    plot(dayfigs.(island{2}).peakslat,dayfigs.(island{2}).(Min),'d','Color',[0 0.5 0.2]);
    plot(dayfigs.(island{3}).peakslat,dayfigs.(island{3}).(Min),'d','Color',[0 0.5 0.4]);
    plot(dayfigs.(island{4}).peakslat,dayfigs.(island{4}).(Min),'d','Color',[0 0.6 0.2]);
    plot(dayfigs.(island{5}).peakslat,dayfigs.(island{5}).(Min),'d','Color',[0 0.6 0.3]);
    plot(dayfigs.(island{6}).peakslat,dayfigs.(island{6}).(Min),'d','Color',[0 0.8 0.4]);
    plot(dayfigs.(island{7}).peakslat,dayfigs.(island{7}).(Min),'d','Color',[0 0.3 0.8]);
    plot(dayfigs.(island{8}).peakslat,dayfigs.(island{8}).(Min),'d','Color',[0 0.4 1]);
    plot(dayfigs.(island{9}).peakslat,dayfigs.(island{9}).(Min),'d','Color',[0 0.6 1]);
    plot(dayfigs.(island{10}).peakslat,dayfigs.(island{10}).(Min),'d','Color',[0 0.8 1]);

    title('Daily Mins');
    ylabel('Min');
    legend(island,'Box','off');
    filename=[vars{i},'_DailyMins.eps'];
    ax.XTick=[-20:3:20];    
    ax.XTickLabel=island;
    saveas(f10, filename, 'epsc');
    
    f11 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
    hold on
    grid on
    ax=gca;

    plot(dayfigs.(island{2}).peakslat,dayfigs.(island{2}).(Max),'d','Color',[0 0.5 0.2]);
    plot(dayfigs.(island{3}).peakslat,dayfigs.(island{3}).(Max),'d','Color',[0 0.5 0.4]);
    plot(dayfigs.(island{4}).peakslat,dayfigs.(island{4}).(Max),'d','Color',[0 0.6 0.2]);
    plot(dayfigs.(island{5}).peakslat,dayfigs.(island{5}).(Max),'d','Color',[0 0.6 0.3]);
    plot(dayfigs.(island{6}).peakslat,dayfigs.(island{6}).(Max),'d','Color',[0 0.8 0.4]);
    plot(dayfigs.(island{7}).peakslat,dayfigs.(island{7}).(Max),'d','Color',[0 0.3 0.8]);
    plot(dayfigs.(island{8}).peakslat,dayfigs.(island{8}).(Max),'d','Color',[0 0.4 1]);
    plot(dayfigs.(island{9}).peakslat,dayfigs.(island{9}).(Max),'d','Color',[0 0.6 1]);
    plot(dayfigs.(island{10}).peakslat,dayfigs.(island{10}).(Max),'d','Color',[0 0.8 1]);

    title('Daily Maxes');
    ylabel('Max');
    legend(island,'Box','off');
    filename=[vars{i},'_DailyMaxes.eps'];
    ax.XTick=[-20:3:20];    
    ax.XTickLabel=island;
    saveas(f11, filename, 'epsc');
    
    f12 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
    hold on
    grid on
    ax=gca;

    plot(dayfigs.(island{2}).peakslat,dayfigs.(island{2}).(max_locs),'o','Color',[0 0.5 0.2],'MarkerFaceColor',[0 0.5 0.2]);
    plot(dayfigs.(island{3}).peakslat,dayfigs.(island{3}).(max_locs),'o','Color',[0 0.5 0.4],'MarkerFaceColor',[0 0.5 0.4]);
    plot(dayfigs.(island{4}).peakslat,dayfigs.(island{4}).(max_locs),'o','Color',[0 0.6 0.2],'MarkerFaceColor',[0 0.6 0.2]);
    plot(dayfigs.(island{5}).peakslat,dayfigs.(island{5}).(max_locs),'o','Color',[0 0.6 0.3],'MarkerFaceColor',[0 0.6 0.3]);
    plot(dayfigs.(island{6}).peakslat,dayfigs.(island{6}).(max_locs),'o','Color',[0 0.8 0.4],'MarkerFaceColor',[0 0.8 0.4]);
    plot(dayfigs.(island{7}).peakslat,dayfigs.(island{7}).(max_locs),'o','Color',[0 0.3 0.8],'MarkerFaceColor',[0 0.3 0.8]);
    plot(dayfigs.(island{8}).peakslat,dayfigs.(island{8}).(max_locs),'o','Color',[0 0.4 1],'MarkerFaceColor',[0 0.4 1]);
    plot(dayfigs.(island{9}).peakslat,dayfigs.(island{9}).(max_locs),'o','Color',[0 0.6 1],'MarkerFaceColor',[0 0.6 1]);
    plot(dayfigs.(island{10}).peakslat,dayfigs.(island{10}).(max_locs),'o','Color',[0 0.8 1],'MarkerFaceColor',[0 0.8 1]);

    title('Daily Max Times');
    ylabel('Time');
    datetick('y', 'HH:MM');
    legend(island,'Box','off');
    filename=[vars{i},'_DailyMaxTimes.eps'];
    ax.XTick=[-20:3:20];    
    ax.XTickLabel=island;
    saveas(f12, filename, 'epsc');
    
    f13 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
    hold on
    grid on
    ax=gca;

    plot(dayfigs.(island{2}).peakslat,dayfigs.(island{2}).(min_locs),'o','Color',[0 0.5 0.2],'MarkerFaceColor',[0 0.5 0.2]);
    plot(dayfigs.(island{3}).peakslat,dayfigs.(island{3}).(min_locs),'o','Color',[0 0.5 0.4],'MarkerFaceColor',[0 0.5 0.4]);
    plot(dayfigs.(island{4}).peakslat,dayfigs.(island{4}).(min_locs),'o','Color',[0 0.6 0.2],'MarkerFaceColor',[0 0.6 0.2]);
    plot(dayfigs.(island{5}).peakslat,dayfigs.(island{5}).(min_locs),'o','Color',[0 0.6 0.3],'MarkerFaceColor',[0 0.6 0.3]);
    plot(dayfigs.(island{6}).peakslat,dayfigs.(island{6}).(min_locs),'o','Color',[0 0.8 0.4],'MarkerFaceColor',[0 0.8 0.4]);
    plot(dayfigs.(island{7}).peakslat,dayfigs.(island{7}).(min_locs),'o','Color',[0 0.3 0.8],'MarkerFaceColor',[0 0.3 0.8]);
    plot(dayfigs.(island{8}).peakslat,dayfigs.(island{8}).(min_locs),'o','Color',[0 0.4 1],'MarkerFaceColor',[0 0.4 1]);
    plot(dayfigs.(island{9}).peakslat,dayfigs.(island{9}).(min_locs),'o','Color',[0 0.6 1],'MarkerFaceColor',[0 0.6 1]);
    plot(dayfigs.(island{10}).peakslat,dayfigs.(island{10}).(min_locs),'o','Color',[0 0.8 1],'MarkerFaceColor',[0 0.8 1]);

    title('Daily Min Times');
    ylabel('Time');
    datetick('y', 'HH:MM');
    legend(island,'Box','off');
    filename=[vars{i},'_DailyMinTimes.eps'];
    ax.XTick=[-20:3:20];    
    ax.XTickLabel=island;
    saveas(f13, filename, 'epsc');
    
    clearvars -except folder analysisfilesDay analysisfilesNight vars peaks dayfigs island

end




