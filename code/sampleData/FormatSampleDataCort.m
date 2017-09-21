% This script loads the raw fluence map data and then generates an easy-to
% use data structure for it.
%
%

clc; clear;
load 'CortMapSet36.mat';   % sampleFluenceMapData

resolution = 0.35;  % size of each pixel, in centimeters

% Store the raw data:
rawDataMap = flMaps{1}';
targetFluence.rawData = rawDataMap;
targetFluence.resolution = 0.35; % centimeters per pixel
targetFluence.maxLeafSpeed = 3;  % maximum leaf speed, cm / sec
targetFluence.maxDoseRate = 10;  % maximum fluence dose rate, ?? / sec

% Rough dimensions
[nRow, nCol] = size(rawDataMap);
targetFluence.rowSlicePosBnd = [0, nCol*resolution];
targetFluence.colSlicePosBnd = [0, nRow*resolution];

% Slice by row:
for iRow=1:nRow
   targetFluence.rowSlice(iRow).xGrid = linspace(0, nCol*resolution, nCol);
   targetFluence.rowSlice(iRow).fGrid = rawDataMap(iRow, :);
end

% Slice by column:
for iCol=1:nCol
   targetFluence.colSlice(iCol).xGrid = linspace(0, nRow*resolution, nRow);
   targetFluence.colSlice(iCol).fGrid = rawDataMap(:, iCol)';
end

% Save the data!
save('cortFluenceMapData.mat','targetFluence');
