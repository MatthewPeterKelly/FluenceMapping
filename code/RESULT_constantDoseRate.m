% This script creates a sample fluence-fitting problem, generates a random
% dose-rate trajectory, and then computes the leaf-trajectories that
% do the best job of fitting those trajectories.

clc; clear;

nKnot = 7;  % Number of knot points in the trajectories
nFit = 1+5*nKnot;  % Number of points to fit solution at

nDose = 15;  % How many dose rates to try?

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
param.smooth.leafBlockingWidth = 0.05*diff(xBnd);  % Width of the smoothing  --  strongly coupled to solve time
param.smooth.leafBlockingFrac = 0.95;  % Change in smoothing over width  --  strongly coupled to solve time
param.smooth.velocityObjective = 1e-2;
param.nQuad = 30;  % Number of segments for quadrature calculations
param.guess.defaultLeafSpaceFraction = 0.2;


% parameters for fmincon:
param.fmincon = optimset(...
    'Display', 'iter',...
    'TolFun', 1e-2,...
    'MaxFunEvals',5000);

% Create a set of constant dose profiles:
doseVals = linspace(rBnd(1), rBnd(2), nDose+1);
doseVals = 0.5*(doseVals(2:end) + doseVals(1:(end-1)));

% Use the default initialization for now
guess = [];

% Loop over each constant dose profile:
for iDose = 1:nDose
    
    % Arbitrary dose trajectory for testing:
    dose.tGrid = linspace(tBnd(1), tBnd(2), nKnot);
    dose.rGrid = doseVals(iDose)*ones(size(dose.tGrid));
    
    % Solve!
    soln(iDose) = fitLeafTrajectories(dose, guess, target, param); %#ok<*SAGROW>
    soln(iDose) = benchmarkSoln(soln(iDose));
    soln(iDose).target.dense.x = fluenceTargetData.sx;
    soln(iDose).target.dense.f = fluenceTargetData.sf;
    
end

%% Analysis

% Figure out which had the best fitting error:
objVals = zeros(size(doseVals));
fitErrs = zeros(size(doseVals));
nlpTime = zeros(size(doseVals));
for iDose = 1:nDose
   objVals(iDose) = soln(iDose).obj;
   fitErrs(iDose) = soln(iDose).target.fitErr; 
   nlpTime(iDose) = soln(iDose).nlpTime;
end
totalTime = sum(nlpTime);


% Plots!
iSoln = 8;
figure(5235); clf;
plotFluenceSoln(soln(iSoln))

