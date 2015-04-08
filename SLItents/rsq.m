function [ rsq ] = rsq( yfit, y )
%rsq: Calculates the r-squared value from a linear regression using polyfit
% and polyval. (S. Calhoun, 4.7.2015)

yres=y-yfit;
ssres=sum(yres.^2);
sstot=(length(y)-1)*var(y);
rsq=1-ssres/sstot;

end

