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

tBnd = [0,10];   % A rough guess for now. We can iterate over this.

vNom = diff(xBnd)/diff(tBnd);
vLowGuess = vNom*[0.1, 0.8];
vUppGuess = vNom*[0.8, 0.1];
rBndGuess = 5*[1,1];  % dose rate
drBndGuess = [4,-1];  % dose accel

[fitErr, x,f,g,A,B,R] = getFittingErr(tBnd, xBnd, vLowGuess, vUppGuess, rBndGuess, drBndGuess, fx);

plotFluenceFitting(fitErr,x,f,g,A,B,R);

