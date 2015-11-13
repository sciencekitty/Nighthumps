% export_GC_data.m

clearvars
close all

% folder path where files are kept
folder = 'C:\Users\Sandi\Dropbox\RohwerLabwork\Bioenergetics\Images\GCtables\LineIslands\';

% list of file names for GC data
files = cellstr(ls([folder,'*-pval.csv']));
vars = {'Island','Direction','moon','Pres300','Pres500','Wind'};
export = zeros(size(files,1)*2,4);
Island = cell(size(files,1)*2,1);
Direction = cell(size(files,1)*2,1);
idx = 1;

for i = 1:size(files,1);
    island = files{i};
    island = island(1,1:end-9);
    temp = readtable([folder,files{i}]);
    
    from = table2array(temp(1,2:end));
    export(idx,:) = from;
    Island{idx,1} = island;
    Direction{idx,1} = 'DO from';

    to = table2array(temp(2:end,1))';
    export(idx+1,:) = to;
    Island{idx+1,1} = island;
    Direction{idx+1,1} = 'DO to';
    
    idx = idx+2; 
end
moon = export(:,1);
Pres300 = export(:,2);
Pres500 = export(:,3);
Wind = export(:,4);
export = table(Island,Direction,moon,Pres300,Pres500,Wind);
writetable(export,[folder,'LineIslands-pval.csv']);

clearvars
close all

% folder path where files are kept
folder = 'C:\Users\Sandi\Dropbox\RohwerLabwork\Bioenergetics\Images\GCtables\MooreaCuracao\';

% list of file names for GC data
files = cellstr(ls([folder,'*-pval.csv']));
vars = {'Island','Direction','moon','TF','Hum','Pres','Wind','WindDir'};
export = zeros(size(files,1)*2,6);
Island = cell(size(files,1)*2,1);
Direction = cell(size(files,1)*2,1);
idx = 1;

for i = 1:size(files,1);
    island = files{i};
    island = island(1,1:end-9);
    temp = readtable([folder,files{i}]);
    
    from = table2array(temp(1,2:end));
    export(idx,:) = from;
    Island{idx,1} = island;
    Direction{idx,1} = 'DO from';

    to = table2array(temp(2:end,1))';
    export(idx+1,:) = to;
    Island{idx+1,1} = island;
    Direction{idx+1,1} = 'DO to';
    
    idx = idx+2; 
end
moon = export(:,1);
TF = export(:,2);
Hum = export(:,3);
Pres = export(:,4);
Wind = export(:,5);
WindDir = export(:,6);
export = table(Island,Direction,moon,TF,Hum,Pres,Wind,WindDir);
writetable(export,[folder,'MooreaCuracao-pval.csv']);

