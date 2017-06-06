function fGrid = getFluenceProfile(xGrid, tGrid, xLowGrid, xUppGrid, rFun)
% fGrid = getFluenceProfile(xGrid, tGrid, xLowGrid, xUppGrid, rFun)
%
% This function computes the fluence profile Gx.
%
% INPUTS:
%   xGrid = position grid on which to evaluate fluence
%   tGrid = time grid for leaf trajectories
%   xLowGrid = lower leaf position at knots in tGrid
%   xUppGrid = upper leaf position at knots in tGrid
%   rFun = dose rate as a function of time
% OUTPUTS:
%   fGrid = fluence at each point in xGrid
%

if nargin == 0
    getFluenceProfile_test();
    return;
end

nx = length(xGrid);
fGrid = zeros(size(xGrid));
for ix=1:nx
    xTest = xGrid(ix);
    
    % Compute the roots of each function
    [tRootLow, ~, ppLow] = getPchipRoots(tGrid, xTest - xLowGrid);
    [tRootUpp, ~, ppUpp] = getPchipRoots(tGrid, xUppGrid - xTest);
    
    % Merge roots:
    tRoot = sort(unique([tGrid(1), tGrid(end), tRootLow, tRootUpp]));
    tLow = tRoot(1:(end-1));
    tUpp = tRoot(2:end);
    tMid = 0.5*(tLow + tUpp);
    flagLow = ppval(ppLow,tMid) > 0;
    flagUpp = ppval(ppUpp,tMid) > 0;
    flagKeep = flagLow & flagUpp;
    
    % Compute integrals:
    sum = 0.0;
    dt = 0.01;
    for j=1:length(flagKeep)
        if flagKeep(j)
            tBnd = [tLow(j), tUpp(j)];
            n = max(2,ceil(diff(tBnd) / dt));
            tInt = linspace(tBnd(1), tBnd(2), n);
            rInt = rFun(tInt);
            sum = sum + trapz(tInt, rInt);
        end
    end
    fGrid(ix) = sum;
    
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function getFluenceProfile_test()

nGrid = 4;
tBnd = [0,2];
tGrid = linspace(tBnd(1),tBnd(2),nGrid);
xBnd = [2, 6];
xLowGridTmp = xBnd(1) + (xBnd(2) - xBnd(1))*rand(1,nGrid);
xUppGridTmp = xBnd(1) + (xBnd(2) - xBnd(1))*rand(1,nGrid);
xLowGrid = min(xLowGridTmp, xUppGridTmp);
xUppGrid = max(xLowGridTmp, xUppGridTmp);
xBnd(1) = min(xLowGrid) - 0.01;
xBnd(2) = max(xUppGrid) + 0.01;
xGrid = linspace(xBnd(1), xBnd(2), 20);

nr = 6;
rGrid = rand(1,nr);
trGrid = linspace(tBnd(1),tBnd(2),nr);
ppr = pchip(trGrid, rGrid);
rFun = @(t)( ppval(ppr,t) );

tic
fGrid = getFluenceProfile(xGrid, tGrid, xLowGrid, xUppGrid, rFun);
toc

figure(2); clf;
plotFluenceFitting(tGrid,xLowGrid,xUppGrid,trGrid,rFun,xGrid,fGrid);

end
