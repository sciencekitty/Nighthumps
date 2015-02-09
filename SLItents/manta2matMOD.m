function [manta, SDNend] = manta2matMOD(filepath)

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
% 

% get file id (fid)
fid = fopen(filepath);

% extract headers
headers = fgetl(fid); 
headers = textscan(headers, '%s', 'delimiter', '\t'); 
headers = headers{:};

% create dataformat for textscan for rest of data
dataformat = ['%f%s']; %first two columns are sensorID and SDN
for i = 1:length(headers)-2; dataformat = [dataformat,'%f']; end

% extract data
trex = textscan(fid, dataformat, 'delimiter', '\t', 'collectoutput', 0);

% close file ID
fclose(fid); 

% *************START PARSING DATA*****************************

% Get information needed for presizing matrix and extracting data

% extract sensor ID
sID = trex{1}; 
ncol = length(unique(sID)); %number of columns in data matrix
% vector of indicies for start of new sensor ID. last one is one larger
% than the length of the  sensorID vector.
inewsens = [1; find(diff(sID)~=0)+1; length(sID)+1]; 
dinewsens = diff(inewsens); % take difference of this matrix for parsing.
nrow = max(diff(inewsens));

SDN = datetime(trex{2},'InputFormat','MM/dd/yyyy HH:mm'); % get SDN in matlab form
% data = trex{3} % get data matrix

% insert sensorID and SDN into data matrix
% data = {sID; SDN; data}';

% pre-size data matrix
data = cell(size(trex));

% Set first two columns to sensor ID and SDN
data{1} = sID;
data{2} = SDN;

% Extract the rest of the data
for i = 3:length(headers)
    data{i} = trex{i};
end

% Start extracting data.
% sID and SDN are extracted separately from the rest.

% presize matrix
manta.sID = NaN(nrow, ncol);
for ii = 1:length(inewsens)-1
    check = data{1}(inewsens(ii):inewsens(ii+1)-1,1);
    % check2 = manta.(headers{i})(1:dinewsens(ii),ii);
    manta.sID(1:dinewsens(ii),ii) = check;
end 

for ii = 1:length(inewsens)-1
    check = data{2}(inewsens(ii):inewsens(ii+1)-1,1);
    % check2 = manta.(headers{i})(1:dinewsens(ii),ii);
    manta.SDN(1:dinewsens(ii),ii) = check;
end 

for i = 3:length(headers)
    % presize matrix
    manta.(headers{i}) = NaN(nrow, ncol);
    % start parsing
    for ii = 1:length(inewsens)-1
        check = data{i}(inewsens(ii):inewsens(ii+1)-1,1);
        % check2 = manta.(headers{i})(1:dinewsens(ii),ii);
        manta.(headers{i})(1:dinewsens(ii),ii) = check;
    end 
end

vars = headers;
SDNend = dinewsens(1);


return

    