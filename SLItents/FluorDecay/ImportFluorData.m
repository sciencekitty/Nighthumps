function [s, arrayList] = ImportFluorData ()
% Imports fluorescence time (min) and ppb reading from the Manta2 sensor data CSV files.

fileList = {'FLNT_Fluor_01.csv',
    'MLNM_Fluor_01.csv',
    'MLNM_Fluor_02.csv',
    'STBK_Fluor_01.csv',
    'STBK_Fluor_02.csv',
    'STBK_Fluor_03.csv',
    'STBK_Fluor_04.csv'}; 

arrayList = {'FLNTFluor01','MLNMFluor01','MLNMFluor02','STBKFluor01','STBKFluor02','STBKFluor03','STBKFluor04'};

for x = 1:7
    
    file = fileList{x};
    arrayName = arrayList{x};
    filename = sprintf('%s/CSV/%s',pwd,file);
    delimiter = ',';
    startRow = 2;
    
    % Only imports columns 2 and 3, since the time format of column 1 is unusable.
    % Creates a structure array with data field for each csv file.

    formatSpec = '%*s%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
    s.(sprintf('%s',arrayName)) = [dataArray{1:end-1}];
    fclose(fileID);
    clearvars filename delimiter startRow formatSpec fileID dataArray ans;
end
end



