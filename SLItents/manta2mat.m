function [manta,vars,ncol] = manta2mat(filepath, daterange)

% [manta, vars] = manta2mat(filepath)
% 
% Converts manta data (Smithlab pH/O2/conductivity sensor) into matlab
% format. Output is a structure, and variables iwthin the structure are
% determined from the text file. This is significantly different than
% "extract_manta_data.m", originally coded for Northern Line Isalnd cruise.
% 
% filepath is the path to the text file of manta data.
%
% First line of data must be headers for columns. THESE WILL BE THE NAME OF
% THE VARIABLES IN MANTA STRUCTURE! First column MUST be tent ID, second
% column MUST be SDN (in string format), and the rest must be numbers.
% 
%
% Author: Yui Takeshita
% Scripps Insitution of Oceanography
% Created: 5/29/2014
% Modified: 10/30/2015 by Sandi Calhoun

% get file id (fid)
fid = fopen(filepath);

% extract headers
headers = fgetl(fid); 
headers = textscan(headers, '%s', 'delimiter', '\t'); 
headers = headers{:};

% extract data
trex = readtable(filepath, 'Delimiter', 'tab');

% close file ID
fclose(fid); 

% *************START PARSING DATA*****************************

% Get information needed for presizing matrix and extracting data

% extract sensor ID
sID = trex.SENS_ID;
[~,idx]=unique(sID);
ncol = length(idx); %number of columns in data matrix
% vector of indicies for start of new sensor ID. last one is one larger
% than the length of the  sensorID vector.
inewsens = [sort(idx);length(sID)+1]; 
dinewsens = diff(inewsens); % take difference of this matrix for parsing.
nrow = max(diff(inewsens));

trex.SDN = datenum(trex.SDN); % get SDN in matlab form


% Start extracting data. 
for i = 1:length(headers)
    % presize matrix
    if i==1
        manta.(headers{i}) = cell(nrow,ncol);
    else
        manta.(headers{i}) = NaN(nrow,ncol);
    end
    % start parsing
    for ii = 1:length(inewsens)-1
        manta.(headers{i})(1:dinewsens(ii),ii) = trex.(headers{i})(inewsens(ii):inewsens(ii+1)-1,1);
    end 
end

vars = headers;


return

    