function [ F ] = FluorFit( s, arrayList )
%Plots exponential deacy of fluorescein readings 
% and determines N_0, tau and R-squared values for each dataset.

for x = 1:7
    spike = arrayList{x};
    data = s.(sprintf('%s',spike));
    plotTitle = sprintf('%s Fluorescein Exponential Decay', spike);
    c = 'g';
    S = 90;
    figure('name',plotTitle,'Color','w');
    set(gcf,'Visible','off');
    set(gca,'FontSize',14,'fontWeight','bold');
    scatter(data(:,1),data(:,2),S,c,'fill','v','MarkerEdgeColor','b');
    grid on;
    grid minor;
    axis tight;
    box on;
    title(plotTitle,'FontSize',20);
    xlabel('Time (min)');
    ylabel('Fluoresence (ppb)');
    
    showfit('N(t)=N_0*exp(-t/tau)',...
        'fitcolor',[0 0 0.5],'fitlinewidth',1.2,...
        'corrcoefmode','r2',...
        'boxlocation', [0.6 0.81 0.3 0.1],'dispeqmode','on');
    
    F.(sprintf('Fit%s',spike)) = ezfit('N(t)=N_0*exp(-t/tau)');
    saveas(gcf,plotTitle,'png');
    
end
end
