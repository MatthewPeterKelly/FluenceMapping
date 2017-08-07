% This script creates a sample fluence-fitting problem, generates a random
% dose-rate trajectory, and then computes the leaf-trajectories that
% do the best job of fitting those trajectories.

clc; clear;

nKnot = 7;  % Number of knot points in the trajectories
nFit = 1+5*nKnot;  % Number of points to fit solution at

nDose = 24;  %{21, 24};  % How many dose rates to try?

saveFigures = true;

% Load a sample fluence profile
fileName = 'sampleData/twohumps.mat';  figNum = 1026;
fluenceTargetData = load(fileName);
xBnd = [min(fluenceTargetData.sx), max(fluenceTargetData.sx)];   % bounds on leaf position
xGrid = linspace(xBnd(1), xBnd(2), nFit+1);
xMid = 0.5*(xGrid(1:nFit) + xGrid(2:end));
target.xGrid = xMid;
target.dx = xGrid(2:end) - xGrid(1:nFit);
target.fGrid = interp1(fluenceTargetData.sx', fluenceTargetData.sf', target.xGrid')';

% Problem bounds
tBnd = [0, 10];  % Time  (seconds)
vBnd = [0, 3];  % bounds on leaf velocity   (3 cm / sec)
rBnd = [0, 10]; % bounds on dose rate  (10 MU / sec)

% parameters for the leaf trajectory fitting
param.limits.time = tBnd;
param.limits.position = xBnd;
param.limits.velocity = vBnd;
param.smooth.leafBlockingWidth = [0.1, 0.05, 0.01]*diff(xBnd);
param.smooth.leafBlockingFrac = 0.98;  % Change in smoothing over width  --  strongly coupled to solve time
param.smooth.velocityObjective = 0;
param.nQuad = 30;  % Number of segments for quadrature calculations
param.guess.defaultLeafSpaceFraction = 0.2;

% Keep track of the original fluence target, densely sampled, for
% benchmarking and plotting
param.fluenceTargetDense.x = fluenceTargetData.sx;
param.fluenceTargetDense.f = fluenceTargetData.sf;
param.fluenceTargetDense.peakFitErr = trapz(param.fluenceTargetDense.x, param.fluenceTargetDense.f.^2);

% parameters for fmincon:
param.fmincon = optimset(...
    'Display', 'iter',...
    'TolFun', 1e-2,...
    'MaxFunEvals',5000);

% Create a set of constant dose profiles:
doseVals = linspace(rBnd(1), rBnd(2), nDose + 2);
doseVals([1,end]) = [];

% Use default guess for first iteration
guess = [];

% Loop over each constant dose profile:
for iDose = 1:nDose
    
    % Arbitrary dose trajectory for testing:
    dose.tGrid = linspace(tBnd(1), tBnd(2), nKnot);
    dose.rGrid = doseVals(iDose)*ones(size(dose.tGrid));
    
    % Solve!
    soln(iDose).iter = fitLeafTrajectoriesIter(dose, guess, target, param); %#ok<*SAGROW>
    
end


%% Analysis

% Figure out which had the best fitting error:
objVals = zeros(size(doseVals));
fitErrs = zeros(size(doseVals));
nlpTime = zeros(length(doseVals), length(param.smooth.leafBlockingWidth));
for iDose = 1:nDose
    objVals(iDose) = soln(iDose).iter(end).benchmark.objFunFitNormalized;
    fitErrs(iDose) = soln(iDose).iter(end).benchmark.fitErrNormalized;
    for iIter = 1:length(soln(iDose).iter)
        nlpTime(iDose, iIter) = soln(iDose).iter(iIter).nlpTime;
    end
end
totalTime = sum(nlpTime);

[~, bestIdx] = min(fitErrs);

%% Plot the best smooth solution

% Plots!
iSoln = bestIdx;
bestDoseRate = doseVals(bestIdx);
disp(['Best dose rate: ', num2str(bestDoseRate)]);
figure(5235); clf;
plotFluenceSoln(soln(iSoln).iter(end))


% Save results:
pltOpt.format = 'fluence-leaf-side-by-side';
pltOpt.fileName = 'fluenceMapIterativeBest';
pltOpt.saveResults = saveFigures;

figure(142); clf;
plotResultsSoln(soln(iSoln).iter(end), pltOpt);


%% Plot sweep of solutions

hFig = figure(253); clf; hold on;

xText = 3.1;
yText = 2e-1;

plot(doseVals, objVals,'ro');
plot(doseVals, fitErrs,'bx');
xlabel('Dose Rate (MU)');
ylabel('Normalized Fitting Error')
title('Iterative Smooth Optimization');
legend('Smooth Fitting Error', 'Exact Fitting Error');
h1 = gca;
h1.YScale = 'log';
smoothParamStr = [];
solveTimeStr = [];

for i=1:length(param.smooth.leafBlockingWidth)
    if i > 1
        smoothParamStr = [smoothParamStr, ',  '];%#ok<AGROW>
        solveTimeStr = [solveTimeStr, ',  '];%#ok<AGROW>
    end
    smoothParamStr = [smoothParamStr, num2str(param.smooth.leafBlockingWidth(i))]; %#ok<AGROW>
    solveTimeStr = [solveTimeStr, num2str(mean(nlpTime(i),1),3)]; %#ok<AGROW>
end
textData = {
    ['leaf smoothing width:  [', smoothParamStr, '] cm'];
    ['mean total solve time:  [', solveTimeStr, '] sec'];
    };
text(xText, yText, textData,'FontSize',12);


if saveFigures
    setFigureSize('square');
    saveAndExportFigure(hFig, 'iterSmoothSweep');
end
