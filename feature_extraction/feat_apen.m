function ApEn=feat_apen(x, options)

ApEn=NaN;

if isempty(x) || all(isnan(x))
    return; end
%%

m=2; r=0.02; 
options.zscore=1;
%if not normaised already you can normalise the sensor data
%x=normalise_data(x, options);
[ApEn] = approx_entropy(m,r,x);

end