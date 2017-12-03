function data = getSimData(name, nData)

if nargin < 1
    name = 'bimodal';
end
if nargin < 2
    nData = 20;
end

xGrid = linspace(0, 10, 6);

switch name
    case 'unimodal'
        fGrid = [0, 5, 12, 32, 15, 0];    
    case 'bimodal'
        fGrid = [0, 20, 12, 30, 35, 0];        
    otherwise
        error('Invalid data name!')
end

data.x = linspace(xGrid(1), xGrid(end), nData);
data.f = spline(xGrid, fGrid, data.x);
data.maxLeafSpeed = 3;
data.maxDoseRate = 10;

end