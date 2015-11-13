
%% Parameters

clearvars

ntrials   = 1;     % number of trials

regmode   = 'OLS';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)

morder    = 'BIC';  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)
momax     = 20;     % maximum model order for model order estimation

acmaxlags = '';   % maximum autocovariance lags (empty for automatic calculation)

tstat     = '';     % statistical test for MVGC:  'F' for Granger's F-test (default) or 'chi2' for Geweke's chi2 test
alpha     = 0.05;   % significance level for significance test
mhtc      = 'FDR';  % multiple hypothesis test correction (see routine 'significance')

fs        = 5;    % sample rate (min)
fres      = [];     % frequency resolution (empty for automatic calculation)


%% Load data
files = {'flint.mat'
    'vostok.mat'
    'malden.mat'
    'millennium.mat'
    'starbuck.mat'
    'fanning.mat'
    'kingman.mat'
    'palmyra.mat'
    'washington.mat'
    'jarvis.mat'};
    
for i = 1:length(files)
    load(files{i});
    island_name = files{i};
    island_name = island_name(1:end-4);
    nobs =  size(manta.SDN,1);  % number of observations per trial
    
    for ii = 1:6
        
        X = [manta.DOXY(:,ii),manta.moon,manta.Pres300,manta.Pres500,manta.Wind];

        times=datetime(manta.SDN,'ConvertFrom','datenum');
        vars={'DOXY','moon','Pres300','Pres500','Wind'};

        xlen=size(X,1)-1;
        ylen=size(X,2);
        Y=zeros(xlen,ylen);

        for iii=1:size(X,2)

            nan=isnan(X(:,iii));
            X(nan,iii)=0.000001;
            Y(:,iii)=diff(X(:,iii));

    %         figure(4); clf;
    %         plot(times(1:end-1),Y(i,:));
    %         name=['LL Differenced Data ',vars{i}];
    %         title(name);
    %         legend off;
    %         saveas(figure(4),name,'png');
    % 
    %         figure(5); clf;
    %         plot(times,X(i,:));
    %         name=['LL Raw Data ',vars{i}];
    %         legend off;
    %         title(name);
    %         saveas(figure(5),name,'png');
        end
        X=Y';

        %% Model order estimation (<mvgc_schema.html#3 |A2|>)

        % Calculate information criteria up to specified maximum model order.

        ptic('\n*** tsdata_to_infocrit\n');
        [AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(X,momax,icregmode);
        ptoc('*** tsdata_to_infocrit took ');

        % Plot information criteria.

%         figure(1); clf;
%         plot_tsdata([AIC BIC]',{'AIC','BIC'});
%         title('Model order estimation');

        amo = size(X,3); % actual model order

        fprintf('\nbest model order (AIC) = %d\n',moAIC);
        fprintf('best model order (BIC) = %d\n',moBIC);
        fprintf('actual model order     = %d\n',amo);

        % Select model order.

        if  strcmpi(morder,'actual')
            morder = amo;
            fprintf('\nusing actual model order = %d\n',morder);
        elseif strcmpi(morder,'AIC')
            morder = moAIC;
            fprintf('\nusing AIC best model order = %d\n',morder);
        elseif strcmpi(morder,'BIC')
            morder = moBIC;
            fprintf('\nusing BIC best model order = %d\n',morder);
        else
            fprintf('\nusing specified model order = %d\n',morder);
        end

        %% VAR model estimation (<mvgc_schema.html#3 |A2|>)

        % Estimate VAR model of selected order from data.

        ptic('\n*** tsdata_to_var... ');
        [A,SiG] = tsdata_to_var(X,morder,regmode);
        ptoc;

        % Check for failed regressionC

        assert(~isbad(A),'VAR estimation failed');

        % NOTE: at this point we have a model and are finished with the data! - all
        % subsequent calculations work from the estimated VAR parameters A and SiG.

        %% Autocovariance calculation (<mvgc_schema.html#3 |A5|>)

        % The autocovariance sequence drives many Granger causality calculations (see
        % next section). Now we calculate the autocovariance sequence G according to the
        % VAR model, to as many lags as it takes to decay to below the numerical
        % tolerance level, or to acmaxlags lags if specified (i.e. non-empty).

        ptic('*** var_to_autocov... ');
        [G,info] = var_to_autocov(A,SiG,acmaxlags);
        ptoc;

        % The above routine does a LOT of error checking and issues useful diagnostics.
        % if there are problems with your data (e.g. non-stationarity, colinearity,
        % etc.) there's a good chance it'll show up at this point - and the diagnostics
        % may supply useful information as to what went wrong. it is thus essential to
        % report and check for errors here.

        var_info(info,true); % report results (and bail out on error)

        %% Granger causality calculation: time domain  (<mvgc_schema.html#3 |A13|>)

        % Calculate time-domain pairwise-conditional causalities - this just requires
        % the autocovariance sequence.

        ptic('*** autocov_to_pwcgc... ');
        F = autocov_to_pwcgc(G);
        ptoc;

        % Check for failed GC calculation

        assert(~isbad(F,false),'GC calculation failed');

        % Significance test using theoretical null distribution, adjusting for multiple
        % hypotheses.

        nvars = size(X,1);
        pval = mvgc_pval(F,morder,nobs,ntrials,1,1,nvars-2,tstat); % take careful note of arguments!
        sig  = significance(pval,alpha,mhtc);

        % Plot time-domain causal graph, p-values and significance.

    %     figure(2); clf;
    %     subplot(1,3,1);
    %     plot_pw(F);
    %     title('Pairwise-conditional GC');
    %     subplot(1,3,2);
    %     cm='jet';
    %     plot_pw(pval,cm);
    %     title('p-values');
    %     subplot(1,3,3);
    %     plot_pw(sig);
    %     title(['Significant at p = ' num2str(alpha)])
    %     saveas(figure(2),'LL pvals','png');

        % For good measure we calculate Seth's causal density (cd) measure - the mean
        % pairwise-conditional causality. We don't have a theoretical sampling
        % distribution for this.

        cd = mean(F(~isnan(F)));

        fprintf('\ncausal density = %f\n',cd);

        %% Granger causality calculation: frequency domain  (<mvgc_schema.html#3 |A14|>)

        % Calculate spectral pairwise-conditional causalities at given frequency
        % resolution - again, this only requires the autocovariance sequence.

        ptic('\n*** autocov_to_spwcgc... ');
        f = autocov_to_spwcgc(G,fres);
        ptoc;

        % Check for failed spectral GC calculation

        assert(~isbad(f,false),'spectral GC calculation failed');

        % Plot spectral causal graph.

    %     figure(3); clf;
    %     plot_spw(f,fs);

        %% Granger causality calculation: frequency domain -> time-domain  (<mvgc_schema.html#3 |A15|>)

        % Check that spectral causalities average (integrate) to time-domain
        % causalities, as they should according to theory.

        fprintf('\nchecking that frequency-domain GC integrates to time-domain GC... \n');
        Fint = smvgc_to_mvgc(f); % integrate spectral MVGCs
        mad = maxabs(F-Fint);
        madthreshold = 1e-5;
        if mad < madthreshold
            fprintf('maximum absolute difference OK: = %.2e (< %.2e)\n',mad,madthreshold);
        else
            fprintf(2,'WARNiNG: high maximum absolute difference = %e.2 (> %.2e)\n',mad,madthreshold);
        end


        save([island_name,num2str(ii),'_GC.mat'],'G','F','f','sig','pval','info');
        writetable((array2table(pval,'VariableNames',vars,'RowNames',vars)),[island_name,num2str(ii),'-pval.csv']);
        writetable((array2table(sig,'VariableNames',vars,'RowNames',vars)),[island_name,num2str(ii),'-sig.csv']);
 


    end
end

%%
% <mvgc_demo.html back to top>
