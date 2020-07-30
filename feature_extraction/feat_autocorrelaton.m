function [features, feature_labels]=feat_autocorrelaton(x, options)

feature_labels={'r_max','lag_max', 'r1_max'};
features=NaN(1,3);

if isempty(x) || all(isnan(x))
    return; end

%%
[acf,lags,~] = autocorr(x, 'NumLags',length(aMag)-1);
[r_max, mi]=max(abs(acf(lags>0))); %The maximum autocorrelation within the time-series x at lags > 0
r1_max=abs(acf(lags==1)); %The autocorrelation coefficient, r at time lag 1 within the timeseries

lag_max=lags(mi);

features=[r_max,lag_max, r1_max];
is this right 

end