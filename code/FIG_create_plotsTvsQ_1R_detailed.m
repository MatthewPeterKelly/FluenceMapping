%close all
clc
iDataSet = 1;
iIterSch = 1;
R = results{iDataSet, iIterSch};
%as.x = 'log'; % x-scale % NOT SUPPORTED YET
as.x = 'linear'; % x-scale
as.y = 'log'; % y-scale
%as.x = 'linear'; % x-scale
mode = 'best'; % shows best obj val after each iteration
%mode = 'iter'; % shows obj val of every iteration
[myFig] = FIG_plotTvsQ_1R_detailed(R,as,mode);
% D = struct array, one element for each iteration