function data = getCortData(name)

% 
% These rows from the CORT prostate case should work, both having 13 bixels of 1cm wide:
% 
% unimodal: [0 0 0 5.55 9.55 10.16 12.44 18.07 24.52 22.34 18.68 16.74 13.62] (row 11, second map)
% bimodal: [0 0 1.98 7.08 4.84 4.85 0.26 0 5.20 15.88 23.02 18.90 17.99] (row 12, second map)


if nargin < 1
    name = 'bimodal';
end


switch name
    case 'unimodal'
        data.f = [0 0 0 5.55 9.55 10.16 12.44 18.07 24.52 22.34 18.68 16.74 13.62];    
    case 'bimodal'
        data.f = [0 0 1.98 7.08 4.84 4.85 0.26 0 5.20 15.88 23.02 18.90 17.99];        
    otherwise
        error('Invalid data name!')
end

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