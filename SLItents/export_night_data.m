% export_night_data.m
% Exports anaylzed manta data to txt files and generates summary figures.

clear all
close all

% folder path where .mat files are kept
folder = '/Users/sandicalhoun/Nighthumps/AnalyzedData';

analysisfilesNight={'flint_analysis_night.mat'
    'vostok_analysis_night.mat'
    'millennium_analysis_night.mat'
    'starbuck_analysis_night.mat'
    'malden_analysis_night.mat'
    'jarvis_analysis_night.mat'
    'fanning_analysis_night.mat'
    'washington_analysis_night.mat'
    'palmyra_analysis_night.mat'
    'kingman_analysis_night.mat'};

vars={'DOXY'
    'pH'
    'ORP'
    'TC'
    };

for i=1:length(vars)
    var1=[vars{i},'mean'];
    var2=[vars{i},'std'];
    var3=['int',vars{i}];
    var4=['ratioDOXY_',vars{i}];
    var5=['slopesDOXY_',vars{i}];
    var6=['rsqDOXY_',vars{i}];
    island={};
    latitude=-12;

    for ii = 1:length(analysisfilesNight)
        load(analysisfilesNight{ii});

        nightnum=max(analysis.night);
        nightlat=zeros(nightnum,1);

        switch analysisfilesNight{ii}
            case 'flint_analysis_night.mat'
%                 latitude=-11.26;
            case 'vostok_analysis_night.mat'
%                 latitude=-10.06;
            case 'millennium_analysis_night.mat'
%                 latitude=-9.57;
%                 nightnum=nightnum-1;
            case 'starbuck_analysis_night.mat'
%                 latitude=-5.37;
%                 nightnum=nightnum-1;
            case 'malden_analysis_night.mat'
%                 latitude=-4.01;
%                 nightnum=nightnum-1;
            case 'jarvis_analysis_night.mat'
%                 latitude=-0.22;
            case 'fanning_analysis_night.mat'
%                 latitude=3.52;
            case 'washington_analysis_night.mat'
%                 latitude=4.43;
            case 'palmyra_analysis_day.mat'
%                 latitude=5.52;
            case 'kingman_analysis_day.mat'
%                 latitude=6.24;
        end
        
        nightlat(1,1)=latitude;
        for iii=2:nightnum
            nightlat(iii,1)=nightlat(iii-1,1)+0.5;
        end
        
%         daylat(daylat == 0) = NaN;
%         inonan = ~isnan(daylat);
%         daylat=daylat(inonan);
        
        latitude=max(nightlat)+2;
        
        nightfigs.(name).nightlat=zeros(nightnum,6);
        
        for iii=1:6
            nightfigs.(name).nightlat(:,iii)=nightlat;
        end
        
        means=zeros(nightnum,6);
        sds=zeros(nightnum,6);
        ints=zeros(nightnum,6);
        ratios=zeros(nightnum,6);
        slopes=zeros(nightnum,6);
        rsqs=zeros(nightnum,6);

        for iii=1:nightnum-1
            num=num2str(iii);
            
            if strcmp(vars{i},'DOXY')==0
                varA=[vars{i},'mean',num];
                varB=[vars{i},'std',num];
                varC=['int',vars{i},num];
                varD=['ratioDOXY_',vars{i},num];
                varE=['slopesDOXY_',vars{i},num];
                varF=['rsqDOXY_',vars{i},num];

                means(iii,:)=analysis.nightly.(varA)';
                sds(iii,:)=analysis.nightly.(varB)';
                ints(iii,:)=analysis.nightly.(varC)';
                ratios(iii,:)=analysis.nightly.(varD)';
                slopes(iii,:)=analysis.nightly.(varE)';
                rsqs(iii,:)=analysis.nightly.(varF)';
            else
                varA=[vars{i},'mean',num];
                varB=[vars{i},'std',num];
                varC=['int',vars{i},num];
                
                means(iii,:)=analysis.nightly.(varA)';
                sds(iii,:)=analysis.nightly.(varB)';
                ints(iii,:)=analysis.nightly.(varC)';
            end
        end
        
        if strcmp(vars{i},'DOXY')==0
            nightfigs.(name).(var1)=means;
            nightfigs.(name).(var2)=sds;
            nightfigs.(name).(var3)=ints;
            nightfigs.(name).(var4)=ratios;
            nightfigs.(name).(var5)=slopes;
            nightfigs.(name).(var6)=rsqs;
        else
            nightfigs.(name).(var1)=means;
            nightfigs.(name).(var2)=sds;
            nightfigs.(name).(var3)=ints;
        end

        rows={'Sensor1'
            'Sensor2'
            'Sensor3'
            'Sensor4'
            'Sensor5'
            'Sensor6'};

        summary=struct2table(analysis.nightly);
        summary.Properties.RowNames=rows;
        filename=[name,'_nightlySummary.txt'];
        writetable(summary,filename,'Delimiter','\t','WriteRowNames',1);
        
        island{ii}=name;

    end
    
%     f1 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
%     hold on
%     grid on
%     ax=gca;
%     
%     errorbar(nightfigs.(island{1}).nightlat,dayfigs.(island{1}).(var1),nightfigs.(island{1}).(var2),'d','Color',[0 0.3 0.1]);
%     errorbar(nightfigs.(island{2}).nightlat,dayfigs.(island{2}).(var1),nightfigs.(island{2}).(var2),'d','Color',[0 0.5 0.2]);
%     errorbar(nightfigs.(island{3}).nightlat,dayfigs.(island{3}).(var1),nightfigs.(island{3}).(var2),'d','Color',[0 0.5 0.4]);
%     errorbar(nightfigs.(island{4}).nightlat,dayfigs.(island{4}).(var1),nightfigs.(island{4}).(var2),'d','Color',[0 0.6 0.2]);
%     errorbar(nightfigs.(island{5}).nightlat,dayfigs.(island{5}).(var1),nightfigs.(island{5}).(var2),'d','Color',[0 0.6 0.3]);
%     errorbar(nightfigs.(island{6}).nightlat,dayfigs.(island{6}).(var1),nightfigs.(island{6}).(var2),'d','Color',[0 0.8 0.4]);
%     errorbar(nightfigs.(island{7}).nightlat,dayfigs.(island{7}).(var1),nightfigs.(island{7}).(var2),'d','Color',[0 0.3 0.8]);
%     errorbar(nightfigs.(island{8}).nightlat,dayfigs.(island{8}).(var1),nightfigs.(island{8}).(var2),'d','Color',[0 0.4 1]);
%     errorbar(nightfigs.(island{9}).nightlat,dayfigs.(island{9}).(var1),nightfigs.(island{9}).(var2),'d','Color',[0 0.6 1]);
%     errorbar(nightfigs.(island{10}).nightlat,dayfigs.(island{10}).(var1),nightfigs.(island{10}).(var2),'d','Color',[0 0.8 1]);
% 
%     title('Nightly Means');
%     ylabel('Mean');
%     legend(island, 'Box','off');
%     ax.XTick=[-20:3:20];
%     ax.XTickLabel=island;
%     filename=[vars{i},'_NightlyMeans.eps'];
%     saveas(f1, filename, 'epsc');
%     
%     f2 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
%     hold on
%     grid on
%     ax=gca;
%     
%     plot(nightfigs.(island{1}).nightlat,nightfigs.(island{1}).(var3),'d','Color',[0 0.3 0.1]);
%     plot(nightfigs.(island{2}).nightlat,nightfigs.(island{2}).(var3),'d','Color',[0 0.5 0.2]);
%     plot(nightfigs.(island{3}).nightlat,nightfigs.(island{3}).(var3),'d','Color',[0 0.5 0.4]);
%     plot(nightfigs.(island{4}).nightlat,nightfigs.(island{4}).(var3),'d','Color',[0 0.6 0.2]);
%     plot(nightfigs.(island{5}).nightlat,nightfigs.(island{5}).(var3),'d','Color',[0 0.6 0.3]);
%     plot(nightfigs.(island{6}).nightlat,nightfigs.(island{6}).(var3),'d','Color',[0 0.8 0.4]);
%     plot(nightfigs.(island{7}).nightlat,nightfigs.(island{7}).(var3),'d','Color',[0 0.3 0.8]);
%     plot(nightfigs.(island{8}).nightlat,nightfigs.(island{8}).(var3),'d','Color',[0 0.4 1]);
%     plot(nightfigs.(island{9}).nightlat,nightfigs.(island{9}).(var3),'d','Color',[0 0.6 1]);
%     plot(nightfigs.(island{10}).nightlat,nightfigs.(island{10}).(var3),'d','Color',[0 0.8 1]);
% 
%     title('Nightly Integrated Totals');
%     ylabel('Integrated Total');
%     legend(island, 'Box','off');
%     ax.XTick=[-20:3:20];
%     ax.XTickLabel=island;
%     filename=[vars{i},'_NightlyTotals.eps'];
%     saveas(f2, filename, 'epsc');
%     
%     f3 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
%     hold on
%     grid on
%     ax=gca;
%     
%     plot(nightfigs.(island{1}).nightlat,nightfigs.(island{1}).(var4),'d','Color',[0 0.3 0.1]);
%     plot(nightfigs.(island{2}).nightlat,nightfigs.(island{2}).(var4),'d','Color',[0 0.5 0.2]);
%     plot(nightfigs.(island{3}).nightlat,nightfigs.(island{3}).(var4),'d','Color',[0 0.5 0.4]);
%     plot(nightfigs.(island{4}).nightlat,nightfigs.(island{4}).(var4),'d','Color',[0 0.6 0.2]);
%     plot(nightfigs.(island{5}).nightlat,nightfigs.(island{5}).(var4),'d','Color',[0 0.6 0.3]);
%     plot(nightfigs.(island{6}).nightlat,nightfigs.(island{6}).(var4),'d','Color',[0 0.8 0.4]);
%     plot(nightfigs.(island{7}).nightlat,nightfigs.(island{7}).(var4),'d','Color',[0 0.3 0.8]);
%     plot(nightfigs.(island{8}).nightlat,nightfigs.(island{8}).(var4),'d','Color',[0 0.4 1]);
%     plot(nightfigs.(island{9}).nightlat,nightfigs.(island{9}).(var4),'d','Color',[0 0.6 1]);
%     plot(nightfigs.(island{10}).nightlat,nightfigs.(island{10}).(var4),'d','Color',[0 0.8 1]);
% 
%     title('Nightly Ratios');
%     ylabel('Ratio');
%     legend(island, 'Box','off');
%     ax.XTick=[-20:3:20];
%     ax.XTickLabel=island;
%     filename=[vars{i},'_NightlyRatios.eps'];
%     saveas(f3, filename, 'epsc');
%     
%     f4 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
%     hold on
%     grid on
%     ax=gca;
%     
%     plot(nightfigs.(island{1}).nightlat,nightfigs.(island{1}).(var5),'d','Color',[0 0.3 0.1]);
%     plot(nightfigs.(island{2}).nightlat,nightfigs.(island{2}).(var5),'d','Color',[0 0.5 0.2]);
%     plot(nightfigs.(island{3}).nightlat,nightfigs.(island{3}).(var5),'d','Color',[0 0.5 0.4]);
%     plot(nightfigs.(island{4}).nightlat,nightfigs.(island{4}).(var5),'d','Color',[0 0.6 0.2]);
%     plot(nightfigs.(island{5}).nightlat,nightfigs.(island{5}).(var5),'d','Color',[0 0.6 0.3]);
%     plot(nightfigs.(island{6}).nightlat,nightfigs.(island{6}).(var5),'d','Color',[0 0.8 0.4]);
%     plot(nightfigs.(island{7}).nightlat,nightfigs.(island{7}).(var5),'d','Color',[0 0.3 0.8]);
%     plot(nightfigs.(island{8}).nightlat,nightfigs.(island{8}).(var5),'d','Color',[0 0.4 1]);
%     plot(nightfigs.(island{9}).nightlat,nightfigs.(island{9}).(var5),'d','Color',[0 0.6 1]);
%     plot(nightfigs.(island{10}).nightlat,nightfigs.(island{10}).(var5),'d','Color',[0 0.8 1]);
%     
%     title('Nightly Slopes');
%     ylabel('Slopes');
%     legend(island, 'Box','off');
%     ax.XTick=[-20:3:20];    
%     ax.XTickLabel=island;
%     filename=[vars{i},'_NightlySlopes.eps'];
%     saveas(f4, filename, 'epsc');
%     
%     f5 = figure('units', 'inch', 'position', [1 1 8 12], 'visible','off');
%     hold on
%     grid on
%     ax=gca;
%     
%     plot(nightfigs.(island{1}).nightlat,nightfigs.(island{1}).(var6),'+','Color',[0 0.3 0.1]);
%     plot(nightfigs.(island{2}).nightlat,nightfigs.(island{2}).(var6),'+','Color',[0 0.5 0.2]);
%     plot(nightfigs.(island{3}).nightlat,nightfigs.(island{3}).(var6),'+','Color',[0 0.5 0.4]);
%     plot(nightfigs.(island{4}).nightlat,nightfigs.(island{4}).(var6),'+','Color',[0 0.6 0.2]);
%     plot(nightfigs.(island{5}).nightlat,nightfigs.(island{5}).(var6),'+','Color',[0 0.6 0.3]);
%     plot(nightfigs.(island{6}).nightlat,nightfigs.(island{6}).(var6),'+','Color',[0 0.8 0.4]);
%     plot(nightfigs.(island{7}).nightlat,nightfigs.(island{7}).(var6),'+','Color',[0 0.3 0.8]);
%     plot(nightfigs.(island{8}).nightlat,nightfigs.(island{8}).(var6),'+','Color',[0 0.4 1]);
%     plot(nightfigs.(island{9}).nightlat,nightfigs.(island{9}).(var6),'+','Color',[0 0.6 1]);
%     plot(nightfigs.(island{10}).nightlat,nightfigs.(island{10}).(var6),'+','Color',[0 0.8 1]);
%     
%     title('Nightly R-Squared values');
%     ylabel('R-Squared');
%     legend(island, 'Box','off');
%     ax.XTick=[-20:3:20];    
%     ax.XTickLabel=island;
%     filename=[vars{i},'_NightlyRsq.eps'];
%     saveas(f5, filename, 'epsc');   
    
    clearvars -except folder analysisfilesNight vars nightfigs island

end