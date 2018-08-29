% This script solves two benchmark optimization problems using a sweep of
% smoothing parameter values, and then compares the results in terms of
% objective function value (computed exactly) and CPU time.

clc; clear;

%%  Generate the results

% Select the data source:
dataFun = @getCortData;  %{@getCortData, @getSimData}

% Parameters for experiment:
durationVec = 1:9;  % duration of the leaf trajectories
nGrid = 1 + 2*durationVec;  % two segments per second
dataSetNames = {'unimodal','bimodal'};
smoothingWidthVec = [0.5, 0.2];  % smoothing width, centimeters

% Parameters for the optimization:
param.smooth.leafBlockingFrac = 0.95;
param.smooth.velocityObjective = 1e-6;
param.nQuad = 25;
param.guess.defaultLeafSpaceFraction = 0.25;
param.diagnostics.nQuad = 10*param.nQuad;
param.diagnostics.alpha = getExpSmoothingParam(0.999, 0.001);
param.fmincon = optimset(...
    'Display', 'iter');

% Set up the results structure:
guess = [];
nDataSet = length(dataSetNames);
nDuration = length(durationVec);
results = cell(nDataSet, nDuration);
for iDataSet = 1:nDataSet
    
    % Load the data set:
    data = dataFun(dataSetNames{iDataSet});
    
    % Set up the target structure:
    target.xGrid = data.x;
    target.dx = diff(data.x(1:2));
    target.fGrid = data.f;
    
    % Updates for the parameters from the data set:
    param.limits.position = [data.xLow, data.xUpp];
    param.limits.velocity = data.maxLeafSpeed * [-1, 1];
    
    % Smoothing schedule
    param.smooth.leafBlockingWidth = smoothingWidthVec;
    
    for iDuration = 1:nDuration
        
        % Set up the dose structure:
        duration = durationVec(iDuration);
        dose.tGrid = linspace(0, duration, nGrid(iDuration));
        dose.rGrid = data.maxDoseRate * ones(size(dose.tGrid));
        
        % Solve the optimization!
        results{iDataSet, iDuration} = fitLeafTrajectoriesIter(dose, guess, target, param);
    end
end

save('totalDurationSweep.mat');

%% Generate the figures
clear;
load('totalDurationSweep.mat');

% Collect the CPU time data:
Result.cpuTime = zeros(nDataSet, nDuration);
Result.objVal = zeros(nDataSet, nDuration);
Result.objExact = zeros(nDataSet, nDuration);
for iDataSet = 1:nDataSet
    for iDuration = 1:nDuration
        R = results{iDataSet, iDuration};
        cpuTime = 0;
        for iSoln = 1:length(R)
            cpuTime = cpuTime + R(iSoln).nlpTime;
        end
        Result.cpuTime(iDataSet, iDuration) = cpuTime;
        Result.objVal(iDataSet, iDuration) = R(end).obj;
        Result.objExact(iDataSet, iDuration) = R(end).diagnostics.objExact(end);
    end
end

% Compile the legend:
legendText = cell(nDuration, 1);
for iDuration = 1:nDuration
    val = durationVec(iDuration);
    legendText{iDuration} = ['T = ', num2str(val), 's'];
end

%% Generate a simple figure with bar charts
figure(2342); clf;
hSub(1) = subplot(1,3,1);
bar(Result.objVal);
title('Obj. Val. Smooth')
set(gca,'XTickLabel',dataSetNames)
set(gca,'YScale','log')
legend(legendText,'Location','SouthEast');
hSub(2) = subplot(1,3,2);
bar(Result.objExact);
title('Obj. Val. Exact')
set(gca,'XTickLabel',dataSetNames)
set(gca,'YScale','log')
legend(legendText,'Location','SouthEast');
subplot(1,3,3);
bar(Result.cpuTime)
title('CPU time')
set(gca,'XTickLabel',dataSetNames)
legend(legendText,'Location','SouthEast');
setFigureSize('wide')
save2pdf('FIG_totalDurationSweep_barChart.pdf')
linkaxes(hSub,'y');

%% Create a pareto-front chart:
figure(2253); clf;
colors = parula(nDuration);
for iDataSet = 1:nDataSet
    hSub(iDataSet) = subplot(1,nDataSet,iDataSet); hold on;
    for iDuration = 1:nDuration
        plot(Result.cpuTime(iDataSet,iDuration), Result.objExact(iDataSet,iDuration),...
            'o','MarkerSize',8,'LineWidth',4, 'Color', colors(iDuration, :));
    end
    legend(legendText,'Location','best');
    xlabel('CPU time (s)');
    ylabel('Objective Value (no smoothing)')
    title(dataSetNames{iDataSet});
    set(gca,'YScale','log')
end
linkaxes(hSub, 'y');
setFigureSize('wide')
save2pdf('FIG_totalDurationSweep_pareto.pdf')


%% Plot the best of the solutions:
figure(2255); clf;
setFigureSize('wide')
hSub(1) = subplot(1,2,1); title('Fluence Fitting');
hSub(2) = subplot(1,2,2); title('Leaf Trajectories');
plotResult(results{2,7}(end));
save2pdf('FIG_totalDurationSweep_bimodalTraj.pdf')
linkaxes(hSub,'y');

figure(2258); clf;
setFigureSize('wide')
hSub(1) = subplot(1,2,1); title('Fluence Fitting');
hSub(2) = subplot(1,2,2); title('Leaf Trajectories');
plotResult(results{1,7}(end));
save2pdf('FIG_totalDurationSweep_unimodalTraj.pdf')
linkaxes(hSub,'y');

