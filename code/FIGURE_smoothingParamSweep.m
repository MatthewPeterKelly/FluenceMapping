% This script solves two benchmark optimization problems using a sweep of
% smoothing parameter values, and then compares the results in terms of
% objective function value (computed exactly) and CPU time.

clc; clear;

%%  Generate the results

% Select the data source:
dataFun = @getCortData;  %{@getCortData, @getSimData}

% Parameters for experiment:
duration = 5;  % duration of the leaf trajectories
nGrid = 6; % number of grid points in the leaf trajectories
dataSetNames = {'unimodal','bimodal'};
smoothingWidthVec = [0.5, 0.2, 0.05, 0.002];  % smoothing width, centimeters
iterSchedule = {...  % schedule of smoothing to compute
    1, 2, 3, 4,...
    [1,2], [1,3], [2,3],...
    [1,2,3]};

% Parameters for the optimization:
param.smooth.leafBlockingFrac = 0.95;
param.smooth.velocityObjective = 1e-6;
param.nQuad = 25;
param.guess.defaultLeafSpaceFraction = 0.25;
param.diagnostics.nQuad = 10*param.nQuad;
param.diagnostics.alpha = getExpSmoothingParam(0.999, 0.001);
param.fmincon = optimset(...
    'Display', 'iter',...
    'TolFun', 1e-4);

% Set up the results structure:
guess = [];
nDataSet = length(dataSetNames);
nIterSch = length(iterSchedule);
results = cell(nDataSet, nIterSch);
for iDataSet = 1:nDataSet
    
    % Load the data set:
    data = dataFun(dataSetNames{iDataSet});
    
    % Set up the dose structure:
    dose.tGrid = linspace(0, duration, nGrid);
    dose.rGrid = data.maxDoseRate * ones(size(dose.tGrid));
    
    % Set up the target structure:
    target.xGrid = data.x;
    target.dx = diff(data.x(1:2));
    target.fGrid = data.f;
    
    % Updates for the parameters from the data set:
    param.limits.position = [data.xLow, data.xUpp];
    param.limits.velocity = data.maxLeafSpeed * [-1, 1];
    
    for iIterSch = 1:nIterSch
        % Final parameter setup:
        param.smooth.leafBlockingWidth = smoothingWidthVec(iterSchedule{iIterSch});
        
        % Solve the optimization!
        results{iDataSet, iIterSch} = fitLeafTrajectoriesIter(dose, guess, target, param);
    end
end

save('RESULTS_smoothingParamSweep.mat');

%% Generate the figures
clear;
load('RESULTS_smoothingParamSweep.mat');

% Collect the CPU time data:
Result.cpuTime = zeros(nDataSet, nIterSch);
Result.objVal = zeros(nDataSet, nIterSch);
Result.objExact = zeros(nDataSet, nIterSch);
for iDataSet = 1:nDataSet
    for iIterSch = 1:nIterSch
        R = results{iDataSet, iIterSch};
        cpuTime = 0;
        for iSoln = 1:length(R)
            cpuTime = cpuTime + R(iSoln).nlpTime;
        end
        Result.cpuTime(iDataSet, iIterSch) = cpuTime;
        Result.objVal(iDataSet, iIterSch) = R(end).obj;
        Result.objExact(iDataSet, iIterSch) = R(end).diagnostics.objExact(end);
    end
end

% Compile the legend:
legendText = cell(nIterSch, 1);
for iIterSch=1:nIterSch
    str = '\DeltaX =';
    vals = smoothingWidthVec(iterSchedule{iIterSch});
    for i=1:length(vals)
        if i==1
            str = [str, ' ', num2str(vals(i))];  %#ok<*AGROW>
        else
            str = [str, ' -> ', num2str(vals(i))];
        end
    end
    legendText{iIterSch} = str;
end

% % Generate a simple figure with bar charts
% figure(2342); clf;
% hSub(1) = subplot(1,3,1);
% bar(Result.objVal);
% title('Obj. Val. Smooth')
% set(gca,'XTickLabel',dataSetNames)
% set(gca,'YScale','log')
% legend(legendText,'Location','SouthEast');
% hSub(2) = subplot(1,3,2);
% bar(Result.objExact);
% title('Obj. Val. Exact')
% set(gca,'XTickLabel',dataSetNames)
% set(gca,'YScale','log')
% legend(legendText,'Location','SouthEast');
% subplot(1,3,3);
% bar(Result.cpuTime)
% title('CPU time')
% set(gca,'XTickLabel',dataSetNames)
% legend(legendText,'Location','best');
% setFigureSize('wide')
% save2pdf('FIG_smoothingParamSweep_barChart.pdf')
% linkaxes(hSub,'y');

% % Create a pareto-front chart:
% figure(2253); clf;
% for iDataSet = 1:nDataSet
%     hSub(iDataSet) = subplot(1,nDataSet,iDataSet); hold on;
%     for iIterSch=1:nIterSch
%         plot(Result.cpuTime(iDataSet,iIterSch), Result.objExact(iDataSet,iIterSch),...
%             'o','MarkerSize',8,'LineWidth',4);
%     end
%     legend(legendText,'Location','best');
%     xlabel('CPU time (s)');
%     ylabel('Objective Value (no smoothing)')
%     title(dataSetNames{iDataSet});
%     set(gca,'YScale','log')
% end
% linkaxes(hSub, 'y');
% setFigureSize('wide')
% save2pdf('FIG_smoothingParamSweep_pareto.pdf')


% Create a pareto-front chart as independent figures:
colors = parula(nIterSch);
for iDataSet = 1:nDataSet
    hSub(iDataSet) = figure(2000 + iDataSet); %clf; hold on;
%     for iIterSch=1:nIterSch
%         plot(Result.cpuTime(iDataSet,iIterSch), Result.objExact(iDataSet,iIterSch),...
%             'o','MarkerSize',8,'LineWidth',4,'Color', colors(iIterSch,:));
%     end
%     legend(legendText,'Location','best');
%     xlabel('CPU time (s)');
%     ylabel('Objective Value (no smoothing)')
%     title(dataSetNames{iDataSet});
%     set(gca,'YScale','log')
    setFigureSize('square');
    save2pdf(['FIG_smoothingParamSweep_pareto_', num2str(iDataSet), '.pdf'])
end


%% Plot the best of the solutions:
figure(2255); clf;
setFigureSize('wide')
hSub(1) = subplot(1,2,1); title('Fluence Fitting');
hSub(2) = subplot(1,2,2); title('Leaf Trajectories');
plotResult(results{2,4}(end));
save2pdf('FIG_smoothingParamSweep_bimodalTraj.pdf')
linkaxes(hSub,'y');

figure(2258); clf;
setFigureSize('wide')
hSub(1) = subplot(1,2,1); title('Fluence Fitting');
hSub(2) = subplot(1,2,2); title('Leaf Trajectories');
plotResult(results{1,4}(end));
save2pdf('FIG_smoothingParamSweep_unimodalTraj.pdf')
linkaxes(hSub,'y');

