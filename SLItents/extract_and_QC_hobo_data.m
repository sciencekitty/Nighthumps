% extract_and_QC_hobo_data.m
% Extract hobo data from a text file, and then QC the data.



clear all
close all

% folder path where text files are kept
folder = '/Users/sandicalhoun/Nighthumps/SLItents/raw_tent_text_files/';
% list of text file names for hobo data
txtfiles = {'malden_hobo.txt'
    'millennium_hobo.txt'
    'starbuck_hobo.txt'};


for i = 1:length(txtfiles)
    island_name = txtfiles{i};
    island_name = island_name(1:end-9);
    switch txtfiles{i}
        case 'malden_hobo.txt'
            daterange = [datenum(2013,10,31,5,24,0) datenum(2013,11,2,10,59,0)];
        case 'millennium_hobo.txt'
            daterange = [datenum(2013,11,6,3,12,0) datenum(2013,11,7,13,56,0)];
        case 'malden_PAR.txt'
            daterange = [datenum(2013,10,26,9,46,0) datenum(2013,10,29,9,31,0)];
    end
    
    filepath = [folder,txtfiles{i}];
    [trex, headers] = hobo2mat(filepath);
    
    % interpolate onto 1min intervals
    hobo.SDN = [daterange(1):datenum(0,0,0,0,1,0):daterange(end)]';
    iuse = inrange(trex.SDN, [hobo.SDN(1) hobo.SDN(end)]);
    
    for ii = 2:length(headers)
        hobo.(headers{ii}) = interp1(trex.SDN(iuse,:), trex.(headers{ii})(iuse,:), hobo.SDN);
    end
    
    % save .mat file
    f_name = [island_name,'_hobo.mat'];
    
    save(f_name, 'hobo', 'island_name');
    close all
    
    
    clearvars -except folder txtfiles
    
    
end






