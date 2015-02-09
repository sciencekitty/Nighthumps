% Gets fluorescein data, plots it, and logs the values of 
% an exponential decay curve in a csv file

cd('/Users/sandicalhoun/Desktop/RohwerLabwork/Bioenergetics/Tent_data');

[s, arrayList] = ImportFluorData ();
[F] = FluorFit( s, arrayList );

dataExport = cell(4,8);
dataExport{1,1}='Parameter';
dataExport{2,1}='N-0';
dataExport{3,1}='Tau';
dataExport{4,1}='R^2';

for c=2:8
    spike=arrayList{c-1};
    field=sprintf('Fit%s',spike);
    dataExport{1,c}=field;
    dataExport{2,c}=F.(sprintf('%s',field)).m(1);
    dataExport{3,c}=F.(sprintf('%s',field)).m(2);
    dataExport{4,c}=F.(sprintf('%s',field)).r;
end

fileExpname=sprintf('%s/CSV/FluorAnalysis.csv',pwd);
fileExpID=fopen(fileExpname,'w');
formatHeader='%s,%s,%s,%s,%s,%s,%s,%s\n';
fprintf(fileExpID,formatHeader,dataExport{1,:});

formatSpec='%s,%d,%d,%d,%d,%d,%d,%d\n';
for row=2:4
    fprintf(fileExpID,formatSpec,dataExport{row,:});
end
fclose('all');
clearvars;




        