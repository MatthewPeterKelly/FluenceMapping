% This script loads the raw fluence map data and then generates an easy-to
% use data structure for it.
%
%

clc; clear;
load 'rawFluenceMapData.mat';   % sampleFluenceMapData

resolution = 1; % width of each bixel, in centimeters (prostate case)

% Store the raw data:
rawDataMap = sampleFluenceMapData'; % second arc segment of prostate case
targetFluence.rawData = rawDataMap;
targetFluence.resolution = resolution; % centimeters per bixel
targetFluence.maxLeafSpeed = 3;  % maximum leaf speed, cm / sec
targetFluence.maxDoseRate = 10;  % maximum fluence dose rate, MU / sec

% Rough dimensions
[nRow, nCol] = size(rawDataMap);
targetFluence.rowSlicePosBnd = [0, nCol*resolution];
targetFluence.colSlicePosBnd = [0, nRow*resolution];

% Slice by row:
for iRow=1:nRow
    targetFluence.rowSlice(iRow).xGrid = 1/2*resolution:resolution:nCol*resolution;
    %linspace(0, nCol*resolution, nCol);
    targetFluence.rowSlice(iRow).fGrid = rawDataMap(iRow, :);
end

% Slice by column:
for iCol=1:nCol
    targetFluence.colSlice(iCol).xGrid = 1/2*resolution:resolution:nRow*resolution;
    %targetFluence.colSlice(iCol).xGrid = linspace(0, (nRow-1)*resolution, nRow+1);
    targetFluence.colSlice(iCol).fGrid = rawDataMap(:, iCol)';
end

% Save the data!
save('cortFluenceMapData.mat','targetFluence');
