function [ hours ] = stripTime( timevec )
%stripTime: removes hour, minute and second data from Y M D H MI S datenum
%array
Time=datetime(timevec,'ConvertFrom','datenum');
    inonat=~isnat(Time);
    Y=Time.Year;
    M=Time.Month;
    D=Time.Day;
    for iii=1:size(Time,1)
        for iv=1:size(Time,2);
            if inonat(iii,iv)==1
                Y(iii,iv)=2000;
                M(iii,iv)=1;
                D(iii,iv)=1;
            end
        end
    end
    H=Time.Hour;
    S=Time.Second;
    MI=Time.Minute;
    hours=datenum(Y,M,D,H,MI,S);
end

