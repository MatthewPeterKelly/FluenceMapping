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

data.x = 0:1:12;
data.maxLeafSpeed = 3;
data.maxDoseRate = 10;

end