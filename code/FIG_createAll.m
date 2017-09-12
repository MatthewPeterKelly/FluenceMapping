% TODO: more advanced figures like Figures 4&5 in Craft & Balvert (2017),
%       TikZ-based.
% TODO: some positioning, sizing and saving formalities

close all
clc

% Settings
isExample = 1; % 1 for example, 0 for real case
tnow = datestr(now(),'_yyyy-mm-dd_HH-MM-SS');

if isExample == 1
    fig1 = FIG_heatMaps;
    saveAndExportFigure(gcf, ['ExampleFluenceMaps' tnow])
    fig2 = FIG_heatMap;
    saveAndExportFigure(gcf, ['ExampleFluenceMap' tnow])
    fig3 = FIG_rowTrajectory; setFigureSize('square');
    saveAndExportFigure(gcf, ['ExampleRowTrajectory' tnow])
else

% Heatmap comparison
fig1 = FIG_heatMaps(soln); % for multiple leaf rows
saveAndExportFigure(gcf, ['FluenceMaps' tnow])

% One heatmap
isDel = 1;
maxDose = 30; % TODO: Matt, where can I find the maxdose in the soln struct?
fig2 = FIG_heatMap(soln, isDel, maxDose);

% Trajectory of a (central) row
myRow = 1; % row index
fig3 = FIG_rowTrajectory(soln,myRow,2); % for one row
saveAndExportFigure(gcf, ['RowTrajectory' tnow])

end