function [] = plotDOXYdata(SDN, DOXY, island_name, plotname)
%Plots and saves an image of manta DOXY data

    fsize = 10;
    lwidth = 2;


    f1 = figure('units', 'inch', 'position', [1 1 12 8], 'visible', 'off');
    plot(SDN, DOXY, 'linewidth', lwidth);
    title(island_name, 'fontsize', fsize);
    ylabel('Oxygen [\mumol/kg]', 'fontsize', fsize);
    % ylim([ymin ymax]);
%     datetick('x', 'HH:MM');
    legend('1', '2', '3', '4', '5', '6');
    set(gca, 'fontsize', fsize);
    
    saveas(f1, plotname);

end

