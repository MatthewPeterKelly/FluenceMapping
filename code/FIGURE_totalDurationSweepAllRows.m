% This script solves two benchmark optimization problems using a sweep of
% smoothing parameter values, and then compares the results in terms of
% objective function value (computed exactly) and CPU time.

clc; clear;

%%  Generate the results

dataNames = {'bimodal', 'unimodal'};

for iDataName = 1:length(dataNames)
    dataName = dataNames{iDataName};
    
    % Select the rows to solve:
    if strcmp(dataName,'unimodal')
        solveRows = 1:15;
    else
        solveRows = 1:13;
    end
    
    nDataRows = length(solveRows);
    dataSetNames = cell(length(solveRows), 1);
    for iRow = 1:nDataRows
        dataSetNames{iRow} = ['dataRow_', num2str(solveRows(iRow))];
    end
    
    % Parameters for experiment:
    durationVec = 1:9;  % duration of the leaf trajectories
    nGrid = 1 + 2 * durationVec; % number of grid points in the leaf trajectories
    
    
    smoothingWidthVec = [0.5, 0.2];  % smoothing width, centimeters
    
    % Parameters for the optimization:
    param.smooth.leafBlockingFrac = 0.95;
    param.smooth.velocityObjective = 1e-6;
    param.nQuad = 25;
    param.guess.defaultLeafSpaceFraction = 0.25;
    param.diagnostics.nQuad = 10*param.nQuad;
    param.diagnostics.alpha = getExpSmoothingParam(0.999, 0.001);
    param.fmincon = optimset(...
        'Display', 'final');
    
    % Set up the results structure:
    guess = [];
    nDataSet = length(dataSetNames);
    nDuration = length(durationVec);
    results = cell(nDataSet, nDuration);
    for iDataSet = 1:nDataSet
        
        % Load the data set:
        fprintf('Solving: %s -- %s\n', dataName, dataSetNames{iDataSet});
        data = getCortDataFullMap(solveRows(iDataSet), dataName);
        
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
    
    save(['totalDurationSweepAllRows_' dataName '.mat']);
    
end



