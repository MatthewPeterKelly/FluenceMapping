function data = getSimData(name, nData)

if nargin < 1
    name = 'bimodal';
end
if nargin < 2
    nData = 20;
end

% Grid for the simulated data
data.xLow = 0;
data.xUpp = 10;
xGrid = linspace(data.xLow, data.xUpp, 6);

switch name
    case 'unimodal'
        fGrid = [0, 5, 12, 32, 15, 0];    
    case 'bimodal'
        fGrid = [0, 20, 12, 30, 35, 0];        
    otherwise
        error('Invalid data name!')
end

% Note: The data points for the fluence are equally spaced and centered on
% a uniform grid that moves from the lower to upper bound. This is
% requrired for the integrals in the code to make sense: the target fluence
% at each point is an integral over a bin width. If we try to fit fluence
% at the precise edge of the domain then we get something non-sensical.

% Generate the data for sampling the fluence map:
xTmp = linspace(data.xLow, data.xUpp, nData + 1);
data.x = 0.5*(xTmp(2:end) + xTmp(1:(end-1)));
data.f = spline(xGrid, fGrid, data.x);
data.maxLeafSpeed = 3;
data.maxDoseRate = 10;

end