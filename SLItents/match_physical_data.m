% extract_and_QC_manta_data.m

clearvars
close all

% folder path where files are kept
folder = '/Users/Sandi/Documents/Nighthumps/';
% list of file names for manta data
Curacao = {'Carmabi052515.mat'
    'Carmabi051715.mat'
    'Carmabi051815.mat'
    'Carmabi051915.mat'
    'Carmabi052015.mat'
    'WaterFactory050715.mat'
    'WaterFactory041415.mat'};
CuracaoPhys = {'Curacao_moon.mat'
    'Curacao_weather.mat'
    'Curacao_wind.mat'};

for i = 1:length(Curacao);
    load([folder,Curacao{i}]);
    load('Curacao_moon.mat');
    load('Curacao_weather.mat');
    load('Curacao_wind.mat');
    
    use = inrange(datenum(moon.dur),[manta.SDN(1,1) manta.SDN(end,1)]);
    manta.moon = interpn(datenum(moon.dur(use,1)),moon.totint(use,1),manta.SDN);
    
    dater = datenum(weather.SDN);
    use = inrange(datenum(weather.SDN),[manta.SDN(1,1) manta.SDN(end,1)]);
    dater = dater(use,1);
    manta.TF = interpn(dater,weather.TF(use,1),manta.SDN,'spline');
    manta.Hum = interpn(dater,weather.Hum(use,1),manta.SDN,'spline');
    manta.Pres = interpn(dater,weather.Pres(use,1),manta.SDN,'spline');
    manta.Wind = interpn(dater,weather.Wind(use,1),manta.SDN,'spline');
    manta.WindDir = interpn(dater,weather.WindDir(use,1),manta.SDN,'spline');
    
    dater = datenum(wind.SDN);
    use = inrange(datenum(wind.SDN),[manta.SDN(1,1) manta.SDN(end,1)]);
    dater = dater(use,1);
    manta.WindGur = interpn(dater,wind.Wind(use,1),manta.SDN,'spline');
    manta.WaveHt = interpn(dater,wind.WaveHt(use,1),manta.SDN,'spline');
    manta.WavePd = interpn(dater,wind.WavePd(use,1),manta.SDN,'spline');
    manta.Cloud = interpn(dater,wind.Cloud(use,1),manta.SDN,'spline');
    
    save(Curacao{i},'manta');
end

clearvars -except folder
close all

SLI = {'flint.mat'
    'vostok.mat'
    'malden.mat'
    'millennium.mat'
    'starbuck.mat'}; 
SLIPhys = {'0N155W-2013_buoy.mat'
    '2S155W-2013_buoy.mat'
    '5S155W-2013_buoy.mat'
    '8S155W-2013_buoy.mat'
    'LineIslands2013_moon.mat'};

for i = 1:length(SLI);
    load([folder,SLI{i}]);
    load(SLIPhys{5});
    switch SLI{i}
        case 'malden.mat'
            load(SLIPhys{3});
        case 'starbuck.mat'
            load(SLIPhys{3});
        case 'millennium.mat'
            load(SLIPhys{4});
        case 'vostok.mat'
            load(SLIPhys{4});
        case 'flint.mat'
            load(SLIPhys{4});
    end
    use = inrange(datenum(moon.dur),[manta.SDN(1,1) manta.SDN(end,1)]);
    manta.moon = interpn(datenum(moon.dur(use,1)),moon.totint(use,1),manta.SDN);

    dater = datenum(buoy.SDN);
    use = inrange(datenum(buoy.SDN),[manta.SDN(1,1) manta.SDN(end,1)]);
    dater = dater(use,1);
    
    manta.Pres300 = interpn(dater,buoy.Pres300(use,1),manta.SDN,'spline');
    manta.Pres500 = interpn(dater,buoy.Pres500(use,1),manta.SDN,'spline');
    manta.Wind = interpn(dater,buoy.Wind(use,1),manta.SDN,'spline');
    
    save(SLI{i},'manta');
end

clearvars -except folder
close all

NLI = {'fanning.mat'
    'kingman.mat'
    'palmyra.mat'
    'washington.mat'
    'jarvis.mat'};
NLIPhys = {'0N155W-2010_buoy.mat'
    '5N155W-2010_buoy.mat'
    '8N155W-2010_buoy.mat'
    'LineIslands2010_moon.mat'};

for i = 1:length(NLI);
    load([folder,NLI{i}]);
    load(NLIPhys{4});
    switch NLI{i}
        case 'kingman.mat'
            load(NLIPhys{3});
        case 'palmyra.mat'
            load(NLIPhys{2});
        case 'washington.mat'
            load(NLIPhys{2});
        case 'fanning.mat'
            load(NLIPhys{2});
        case 'jarvis.mat'
            load(NLIPhys{1});
    end
    use = inrange(datenum(moon.dur),[manta.SDN(1,1) manta.SDN(end,1)]);
    manta.moon = interpn(datenum(moon.dur(use,1)),moon.totint(use,1),manta.SDN);
    
    dater = datenum(buoy.SDN);
    use = inrange(datenum(buoy.SDN),[manta.SDN(1,1) manta.SDN(end,1)]);
    dater = dater(use,1);
    
    manta.Pres300 = interpn(dater,buoy.Pres300(use,1),manta.SDN,'spline');
    manta.Pres500 = interpn(dater,buoy.Pres500(use,1),manta.SDN,'spline');
    manta.Wind = interpn(dater,buoy.Wind(use,1),manta.SDN,'spline');
    
    save(NLI{i},'manta');
end

clearvars -except folder
close all

Moorea = {'Moorea_9_1_11.mat'
    'Moorea_9_5_11.mat'
    'Moorea_9_8_11.mat'
    'Moorea_9_12_11.mat'
    'Moorea_9_14_11.mat'
    'Moorea_9_17_11.mat'};
MooreaPhys = {'Moorea_moon.mat'
    'Moorea_weather.mat'
    'Moorea_wind.mat'};

for i = 1:length(Moorea);
    load([folder,Moorea{i}]);
    load('Moorea_moon.mat');
    load('Moorea_weather.mat');
    load('Moorea_wind.mat');
    
    use = inrange(datenum(moon.dur),[manta.SDN(1,1) manta.SDN(end,1)]);
    manta.moon = interpn(datenum(moon.dur(use,1)),moon.totint(use,1),manta.SDN);
    
    dater = datenum(weather.SDN);
    use = inrange(datenum(weather.SDN),[manta.SDN(1,1) manta.SDN(end,1)]);
    dater = dater(use,1);
    manta.TF = interpn(dater,weather.TF(use,1),manta.SDN,'spline');
    manta.Hum = interpn(dater,weather.Hum(use,1),manta.SDN,'spline');
    manta.Pres = interpn(dater,weather.Pres(use,1),manta.SDN,'spline');
    manta.Wind = interpn(dater,weather.Wind(use,1),manta.SDN,'spline');
    manta.WindDir = interpn(dater,weather.WindDir(use,1),manta.SDN,'spline');
    
    dater = datenum(wind.SDN);
    use = inrange(datenum(wind.SDN),[manta.SDN(1,1) manta.SDN(end,1)]);
    dater = dater(use,1);
    manta.WindGur = interpn(dater,wind.Wind(use,1),manta.SDN,'spline');
    manta.WaveHt = interpn(dater,wind.WaveHt(use,1),manta.SDN,'spline');
    manta.WavePd = interpn(dater,wind.WavePd(use,1),manta.SDN,'spline');
    manta.Cloud = interpn(dater,wind.Cloud(use,1),manta.SDN,'spline');
    
    save(Moorea{i},'manta');
end


    







