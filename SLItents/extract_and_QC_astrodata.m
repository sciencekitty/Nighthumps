% extract_and_QC_physdata.m

clear all
close all

% folder path where text files are kept
folder = '/Users/Sandi/Documents/Nighthumps/SLItents/raw_tent_text_files/';
% list of text file names for physical data
txtfiles = {'LineIslands2010_astronomy.txt'
    'LineIslands2013_astronomy.txt'
    'Curacao_astronomy.txt'
    'Moorea_astronomy.txt'};

for i = 1:length(txtfiles)
    island_name = txtfiles{i};
    island_name = island_name(1:end-14);
    
    trex = readtable([folder,txtfiles{i}],'Delimiter','tab');
    moon.rise = datetime(trex.Rise,'InputFormat','yyyy-dd-MM HH:mm');
    moon.mset = datetime(trex.Set,'InputFormat','yyyy-dd-MM HH:mm');
    moon.int = trex.MaxIntensity;
    moon.up = moon.mset-moon.rise;
    moon.peak = moon.rise+(moon.up/2);
    
    start = datenum(moon.rise(1));
    stop = datenum(moon.mset(end));
    step = datenum(0,0,0,0,1,0);
    moon.dur = datetime([start:step:stop],'ConvertFrom','datenum')';
    moon.totint = zeros(size(moon.dur));
    
    for ii = 1:size(trex,1)
        rng = inrange(moon.dur,[moon.rise(ii,1) moon.mset(ii,1)],'excludeboth');
        m = [datenum(moon.rise(ii,1)):datenum(0,0,0,0,1,0):datenum(moon.mset(ii,1))]';
        totint = [1:1:size(m,1)]';
        y = [0, moon.int(ii,1), 0];
        x = [1, size(totint,1)/2, size(totint,1)];
        [p,s] = polyfit(x,y,2);
        totint = polyval(p, totint);
        totint = totint(2:end-1,1);
        test = moon.dur(rng,1);
        if size(totint)==size(test)
            moon.totint(rng,1) = totint(:);
        elseif size(totint)>size(test)
            m = datetime(m,'ConvertFrom','datenum');
            mm = inrange(test, [m(1,1) m(end,1)]);
            totint = totint(mm(2:end-1,1),1);
            moon.totint(rng,1) = totint(:);
        else
            t = size(test,1)-size(totint,1);
            totint = [totint; zeros(size(t))];
            moon.totint(rng,1) = totint(:);
        end
    end
    hold
    plot(moon.dur,moon.totint);
    
  
f_name = [island_name,'_moon.mat'];
save(f_name, 'moon', 'island_name');
close all

clearvars -except folder txtfiles

end






