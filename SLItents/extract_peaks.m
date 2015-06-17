function [ varmax, max_locs, varmin, min_locs ] = extract_peaks( var, SDN, nanlength )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    [steg, locs] = findpeaks(var,'MinPeakDistance',datenum(0,0,0,4,0,0),...
        'MinPeakProminence', 0.01);
    for i=1:length(locs)
        locs(i)=SDN(locs(i));
    end
    if length(steg) < nanlength
        varmax = [steg; NaN(nanlength-length(steg),1)];
        max_locs = [locs; NaN(nanlength-length(steg),1)];
    else
        varmax = steg;
        max_locs = locs;
    end

    mins = -var;
    [steg, locs] = findpeaks(mins,'MinPeakDistance',datenum(0,0,0,4,0,0),...
        'MinPeakProminence', 0.01);
    for i=1:length(locs)
        locs(i)=SDN(locs(i));
    end
    if length(steg) < nanlength
        varmin = [-steg; NaN(nanlength-length(steg),1)];
        min_locs = [locs; NaN(nanlength-length(steg),1)];
    else
        varmin = -steg;
        min_locs = locs;
    end
end

