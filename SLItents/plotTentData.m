function [] = plotTentData( plotvar, manta, island_name, ymax, ymin )
%Plots and saves a png of SLI tent data

    fsize = 25;
    lwidth = 2;


    f1 = figure('units', 'inch', 'position', [1 1 12 8], 'visible', 'off');
    plot(manta.SDN(1:end), manta.(plotvar)(:,1:6), 'linewidth', lwidth);
    title(island_name, 'fontsize', fsize);
    ylabel('Oxygen [\mumol/kg]', 'fontsize', fsize);
%     ylim([150 220]);
    ylim([ymin ymax]);
    datetick('x', 'mm/dd');
    legend('1', '2', '3', '4', '5', '6');
    set(gca, 'fontsize', fsize);
    
    plotname = [island_name,'_',plotvar,'.png'];
    saveas(f1, plotname);
    %movefile(plotname, 'plots', 'f');

end

