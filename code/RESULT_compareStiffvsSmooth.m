% This script creates a sample fluence-fitting problem, generates a random
% dose-rate trajectory, and then computes the leaf-trajectories that
% do the best job of fitting those trajectories.

clc; clear;

nKnot = 7;  % Number of knot points in the trajectories
nFit = 1+5*nKnot;  % Number of points to fit solution at

nDose = 24;  % How many dose rates to try?

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
param.smooth.leafBlockingFrac = 0.95;  % Change in smoothing over width  --  strongly coupled to solve time
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

% Use the default initialization for now
guess = [];

%% Smooth Data:
smoothParam = 0.05*diff(xBnd);  % Width of the smoothing  --  strongly coupled to solve time
param.smooth.leafBlockingWidth = smoothParam;

% Loop over each constant dose profile:
for iDose = 1:nDose
    
    % Arbitrary dose trajectory for testing:
    dose.tGrid = linspace(tBnd(1), tBnd(2), nKnot);
    dose.rGrid = doseVals(iDose)*ones(size(dose.tGrid));
    
    % Solve!
    soln.smooth(iDose) = fitLeafTrajectories(dose, guess, target, param); %#ok<*SAGROW>
    soln.smooth(iDose) = benchmarkSoln(soln.smooth(iDose));
    
end

%% Stiff Data:
stiffParam = 0.005*diff(xBnd);  % Width of the smoothing  --  strongly coupled to solve time
param.smooth.leafBlockingWidth = stiffParam;

% Loop over each constant dose profile:
for iDose = 1:nDose
    
    % Arbitrary dose trajectory for testing:
    dose.tGrid = linspace(tBnd(1), tBnd(2), nKnot);
    dose.rGrid = doseVals(iDose)*ones(size(dose.tGrid));
    
    % Solve!
    soln.stiff(iDose) = fitLeafTrajectories(dose, guess, target, param); %#ok<*SAGROW>
    soln.stiff(iDose) = benchmarkSoln(soln.stiff(iDose));
    
end

%% Analysis

% Figure out which had the best fitting error:
objVals.smooth = zeros(size(doseVals));
fitErrs.smooth = zeros(size(doseVals));
nlpTime.smooth = zeros(size(doseVals));
for iDose = 1:nDose
   objVals.smooth(iDose) = soln.smooth(iDose).benchmark.objFunFitNormalized;
   fitErrs.smooth(iDose) = soln.smooth(iDose).benchmark.fitErrNormalized; 
   nlpTime.smooth(iDose) = soln.smooth(iDose).nlpTime;
end
totalTime.smooth = sum(nlpTime.smooth);

[~, bestIdx.smooth] = min(fitErrs.smooth);

% Figure out which had the best fitting error:
objVals.stiff = zeros(size(doseVals));
fitErrs.stiff = zeros(size(doseVals));
nlpTime.stiff = zeros(size(doseVals));
for iDose = 1:nDose
   objVals.stiff(iDose) = soln.stiff(iDose).benchmark.objFunFitNormalized;
   fitErrs.stiff(iDose) = soln.stiff(iDose).benchmark.fitErrNormalized; 
   nlpTime.stiff(iDose) = soln.stiff(iDose).nlpTime;
end
totalTime.stiff = sum(nlpTime.stiff);

[~, bestIdx.stiff] = min(fitErrs.stiff);


%% Plot the best smooth solution

% Plots!
iSoln = bestIdx.smooth;
bestDoseRate = doseVals(bestIdx.smooth);
disp(['Best dose rate: ', num2str(bestDoseRate)]);
figure(5235); clf;
plotFluenceSoln(soln.smooth(iSoln))


% Save results:
pltOpt.format = 'fluence-leaf-side-by-side';
pltOpt.fileName = 'fluenceMapSmoothingExample';
pltOpt.saveResults = saveFigures;

figure(142); clf;
plotResultsSoln(soln.smooth(iSoln), pltOpt);


%% Compare smooth and stiff optimizations

hFig = figure(253); clf; 

xText = 0.5;
yText = 5e-5;

h1 = subplot(1,2,1); hold on;
plot(doseVals, objVals.smooth,'ro');
plot(doseVals, fitErrs.smooth,'bx');
xlabel('Dose Rate (MU)');
ylabel('Normalized Fitting Error')
title('Smooth Optimization');
legend('Smooth Fitting Error', 'Exact Fitting Error');
h1.YScale = 'log';
textData = {
    ['leaf smoothing width:  ', num2str(smoothParam), ' cm'];
    ['mean solve time:  ', num2str(mean(nlpTime.smooth), 3), ' sec'];
    };
text(xText, yText, textData,'FontSize',12);

h2 = subplot(1,2,2); hold on;
plot(doseVals, objVals.stiff,'ro');
plot(doseVals, fitErrs.stiff,'bx');
xlabel('Dose Rate (MU)');
ylabel('Normalized Fitting Error')
title('Stiff Optimization');
legend('Stiff Fitting Error', 'Exact Fitting Error');
h2.YScale = 'log';
textData = {
    ['leaf smoothing width: ', num2str(stiffParam), ' cm'];
    ['mean solve time: ', num2str(mean(nlpTime.stiff), 3), ' sec'];
    };
text(xText, yText, textData,'FontSize',12);

linkaxes([h1,h2],'y');


if saveFigures
setFigureSize('wide');
saveAndExportFigure(hFig, 'smoothVsStiffOptimization');
end
