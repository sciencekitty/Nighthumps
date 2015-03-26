% analyze_hobo_data.m
% Analyze hobo data to determine the inside versus outside tent differences
% and compare to PAR data.

clear all
close all

% folder path where .mat files are kept
folder = '/Users/sandicalhoun/Nighthumps/AnalyzedData';
% list of file names for hobo data
hobofiles = {'malden_hobo.mat'
    'millennium_hobo.mat'
    'starbuck_hobo.mat'};

for i = 1:length(hobofiles)
    island_name = hobofiles{i};
    island_name = island_name(1:end-9);
    load(hobofiles{i});
    
    groups = fields(hobo);
    % exclude SDN and PAR columns
    groups = groups(2:end-1);
    rows = length(hobo.(groups{1}));
    % presize matrix for ANOVA
    obser = zeros(rows,length(groups));
    
    for ii = 1:length(groups)
        obser(:,ii) = hobo.(groups{ii});
    end
    
    % run 1-way ANOVA on hobo data, then perform a multiple comparison of
    % each pair-wise set of data
    
    [p,tbl,stats] = anova1(obser,groups,'off');
    [c,m,h] = multcompare(stats);
    title('')
    xlabel('')
    
    figname=[island_name,'_hoboANOVA'];
    saveas(h,figname,'png');
    
    % average all in and out of tent data, then re-run ANOVA
    
    in_out = zeros(rows,2);
    out = [obser(:,1), obser(:,end)];
    in = obser(:,2:end-1);
    in_out(:,1) = mean(in,2);
    in_out(:,2)= mean(out,2);
    groups = {'in','out'};
    
    [avep,avetbl,avestats] = anova1(in_out,groups,'off');
    [avec,avem,h] = multcompare(avestats);
    title('')
    xlabel('')
    
    figname=[island_name,'_hoboANOVAave'];
    saveas(h,figname,'png');
    
    
    filename=[island_name,'_hoboANOVA.mat'];
    save(filename, 'p','tbl','stats','c','m','avep','avetbl','avestats','avec','avem');
    
    tot_ave=[tot_ave;avem];
    
    close all
    clearvars -except folder hobofiles tot_ave
    
end
    
save('hobo_in-out_ave.mat','tot_ave');        
    