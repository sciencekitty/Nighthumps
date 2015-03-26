function [] = plotPARdata(SDN, PAR, island_name, plotname)
%Plots and saves an image of manta DOXY data

    fsize = 25;
    lwidth = 2;


    f1 = figure('units', 'inch', 'position', [1 1 12 8], 'visible', 'off');
    plot(SDN, PAR, 'linewidth', lwidth);
    title(island_name, 'fontsize', fsize);
    ylabel('PAR [\mumol photons m^-^2 s^-^1]', 'fontsize', fsize);
    % ylim([ymin ymax]);
    datetick('x', 'mm/dd');
    set(gca, 'fontsize', fsize);
    
    saveas(f1, plotname);

end

