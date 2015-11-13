% extract_and_QC_weatherdata.m

clearvars
close all

% folder path where text files are kept
folder = '/Users/Sandi/Documents/Nighthumps/SLItents/raw_tent_text_files/';
% list of text file names for physical data
txtfiles = {'0N155W-2010.txt'
    '5N155W-2010.txt'
    '8N155W-2010.txt'
    '0N155W-2013.txt'
    '2S155W-2013.txt'
    '5S155W-2013.txt'
    '8S155W-2013.txt'};

for i = 1:size(txtfiles,1)
    island_name = txtfiles{i};
    island_name = island_name(1:end-4);
    
    trex = readtable([folder,txtfiles{i}],'Delimiter','tab');
    [SDN,idx] = unique(datetime(trex.SDN,'InputFormat','yyyy-MM-dd HH:mm'));
    buoy.SDN = SDN;
    buoy.Pres300 = trex.PRES300(idx,1);
    buoy.Pres500 = trex.PRES500(idx,1);
    buoy.Rain = trex.RAIN(idx,1);
    buoy.Wind = trex.WSPD(idx,1);

    f_name = [island_name,'_buoy.mat'];
    save(f_name, 'buoy', 'island_name');
    close all

    clearvars -except buoy folder txtfiles
end







