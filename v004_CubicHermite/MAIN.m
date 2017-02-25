%%%% NOTES:
%
%

clc; clear; 

%%%% Load the example:
% Two example problems:   (target profiles given in .mat files)
% --> "two humps"
% --> "two dips" 
% max leaf speed:  3 cm / sec
% max dose rate: 10 MU / sec
% both leaves start at x = 0 and end at x = 10
% filename = 'example_one/twohumps.mat';
filename = 'example_one/twodips.mat';
[fx, xBnd] = loadProfile(filename);

vMax = 3;
rMax = 10;

nGridDoseRate = 5;

tBnd = 3*[0,diff(xBnd)/vMax];   % A rough guess for now. We can iterate over this.

vNom = diff(xBnd)/diff(tBnd);
vLow = [0,vMax];
vUpp = [vMax,0];
rDataGuess = 0.5*rMax*ones(nGridDoseRate,1);

% Solve for data:
problem.objective =  @(rData)( getFittingErr(tBnd, xBnd, vLow, vUpp, rData, fx) );
problem.x0 = rDataGuess;
problem.Aineq = [];
problem.bineq = [];
problem.Aeq = [];
problem.beq = [];
problem.lb = zeros(nGridDoseRate,1);
problem.ub = rMax*ones(nGridDoseRate,1);
problem.nonlcon = [];
problem.options = optimset('fmincon');
problem.solver = 'fmincon';

rDataSoln = fmincon(problem);

[fitErr, x,f,g,A,B,R] = getFittingErr(tBnd, xBnd, vLow, vUpp, rDataSoln, fx);

plotFluenceFitting(fitErr,x,f,g,A,B,R);

