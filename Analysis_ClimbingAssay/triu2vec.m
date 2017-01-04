function y = triu2vec(x)
%   --> As the name suggests, this functin is to turn the upper 
%       triangle into a vector;
%   --> If a lower triangle is wanted, then transpose x.
%   By LIN Qian, 19th Nov 2015, Vienna, Austria

temp1 = nan * ones(size(x));
temp2 = x + triu(temp1);
y = temp2(~isnan(temp2));
end