
%% generate data vectors (x and y)
% fsine = @(param,timeval) param(1) + param(2) * sin( param(3) + 2*pi*param(4)*timeval );
% param=[0 1 0 1/(2*pi)];  % offset, amplitude, phaseshift, frequency
% timevec=0:0.1:10*pi;
% x=timevec;
% y=fsine(param,timevec) + 0.1*randn(size(x));
load('starbuck.mat');
x=manta.SDN(:,1)';
y=manta.DOXY(:,1)';

%% standard parameter estimation
%[estimated_params]=sine_fit(x,y)

%% parameter estimation with forced fixed amplitude and frequency
[estimated_params, f1]=sine_fit(x,y,[NaN 0.7 NaN 1])

%% parameter estimation without plotting
%[estimated_params]=sine_fit(x,y,[],[],0)

yfit=estimated_params(1)+estimated_params(2) * sin(estimated_params(3) + 2*pi*estimated_params(4)*x);
yadj=y-yfit;
f2 = figure('units', 'inch', 'position', [1 1 12 8], 'visible', 'off');
plot(x,yadj);
ylabel('Oxygen [\mumol/kg]', 'fontsize', 25);
datetick('x', 'mm/dd');

%*****smooth data with a low pass filter*****
n = 5; % filter order
period = 80;% cutoff period. when 1/period = 1, it is half of the sampling rate (butter)
            % so that means period = 6 is one hour. 30 hours = 180.
Wn = 1/(period); % cutoff frequency
[b,a] = butter(n,Wn);


ysmooth = filtfilt(b, a, yadj);
f3 = figure('units', 'inch', 'position', [1 1 12 8], 'visible', 'off');
plot(x,ysmooth);
ylabel('Oxygen [\mumol/kg]', 'fontsize', 25);
datetick('x', 'mm/dd');

saveas(f1, 'fit.png');
saveas(f2, 'adj.png');
saveas(f3, 'adjSmooth.png');
