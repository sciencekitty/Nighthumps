% extract_and_QC_weatherdata.m

clear all
close all

% folder path where text files are kept
folder = '/Users/Sandi/Documents/Nighthumps/SLItents/raw_tent_text_files/';
% list of text file names for physical data
txtfiles = {'Curacao-windguru.txt'
    'Moorea-windguru.txt'};

for i = 1:size(txtfiles,1)
    island_name = txtfiles{i};
    island_name = island_name(1:end-13);
    
    trex = readtable([folder,txtfiles{i}],'Delimiter','tab');
    wind.SDN = datetime(trex.DateTime,'InputFormat','yyyy-MM-dd HH:mm');
    wind.Wind = trex.Wind;
    wind.WaveHt = trex.WaveHt;
    wind.WavePd = trex.WavePd;
    wind.TC = trex.Temperature;
    wind.Rain = trex.Rain;
    wind.Cloud = trex.Cloud;

    f_name = [island_name,'_wind.mat'];
    save(f_name, 'wind', 'island_name');
    close all

    clearvars -except wind folder txtfiles
end







