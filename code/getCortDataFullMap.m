function data = getCortDataFullMap(rowIdx)
%
% @param:  rowIdx  --  which row of the fluence map to use
%
% If multiple data sets are required, then simply add a second argument.
%


%%%% TODO:  replace with hard-coded CORT data set
rawData = 4 * abs(peaks(13));

% Extract the data row:
data.f = rawData(rowIdx, :);

% Note: The data points for the fluence are equally spaced and centered on
% a uniform grid that moves from the lower to upper bound. This is
% requrired for the integrals in the code to make sense: the target fluence
% at each point is an integral over a bin width. If we try to fit fluence
% at the precise edge of the domain then we get something non-sensical.

% Generate the data for sampling the fluence map:
data.xLow = 0;
data.xUpp = 14;
nData = length(data.f);
xTmp = linspace(data.xLow, data.xUpp, nData + 1);
data.x = 0.5*(xTmp(2:end) + xTmp(1:(end-1)));
data.maxLeafSpeed = 3;
data.maxDoseRate = 10;

end