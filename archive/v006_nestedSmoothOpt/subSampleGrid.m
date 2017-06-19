function [tGrid, iKey] = subSampleGrid(tKey,nSub)
% tGrid = subSampleGrid(tKey,nSub)
%
% Computes a new grid tGrid such that there a nSub segments of the
% trajectory between each point in tKey. 
%
% tGrid(iKey) = tKey
%

nKey = length(tKey);
nGrid = nSub*(nKey-1)+1;
tGrid = zeros(1,nGrid);
idx = 1:(nSub+1);
for i=1:(nKey-1)
    tGrid(idx) = linspace(tKey(i),tKey(i+1),nSub+1);
    idx = idx + nSub;
end
iKey = 1:nSub:nGrid;

end