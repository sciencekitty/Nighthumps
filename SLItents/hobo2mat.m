function [hobo, vars] = hobo2mat(filepath, ~)

% Based on manta2mat.m by Yui Takeshita (Scripps Insitution of
% Oceanography, 5/29/2014). This takes hobo light sensor data and inputs it
% into a matrix for further analysis. 


% get file id (fid)
fid = fopen(filepath);

% extract headers
headers = fgetl(fid); 
headers = textscan(headers, '%s', 'delimiter', '\t'); 
headers = headers{:};

% create dataformat for textscan for rest of data
dataformat = ['%s']; %first column is SDN
for i = 2:length(headers); dataformat = [dataformat,'%f']; end

% extract data
trex = textscan(fid, dataformat, 'delimiter', '\t', 'collectoutput', 1);

% close file ID
fclose(fid); 

% *************START PARSING DATA*****************************

% Get information needed for presizing matrix and extracting data
 
ncol = length(headers); %number of columns in data matrix
nrow = length(trex{1}); %number of rows in data matrix

SDN = datenum(trex{1}); % get SDN in matlab form
data = trex{2}; % get data matrix

% insert SDN into data matrix
% data = [SDN; data];

% Start extracting data. 
hobo.SDN = SDN;
for i = 2:length(headers)
    % start parsing
    hobo.(headers{i}) = data(:,i-1);
end

vars = headers;


return

    