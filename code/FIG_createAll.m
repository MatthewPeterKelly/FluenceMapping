% TODO: more advanced figures like Figures 4&5 in Craft & Balvert (2017),
%       TikZ-based.
% TODO: some positioning, sizing and saving formalities

close all
clc

% Settings
isExample = 1; % 1 for example, 0 for real case
tnow = datestr(now(),'_yyyy-mm-dd_HH-MM-SS');
mainFolder = cd;
figFolder = [mainFolder '\latex\fig'];
cd(figFolder);

if isExample == 1
    fig1 = FIG_heatMaps;
    fileName = ['ExampleFluenceMaps' tnow];
    print(fig1,fullfile(figFolder, fileName),'-dpdf','-bestfit')
    fig2 = FIG_heatMap;
    fileName = ['ExampleFluenceMap' tnow];
    print(fig2,fullfile(figFolder, fileName),'-dpdf','-bestfit')
    fig3 = FIG_rowTrajectory; setFigureSize('square');
    fileName = ['ExampleRowTrajectory' tnow];
    print(fig3,fullfile(figFolder, fileName),'-dpdf','-bestfit')
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

%% Multiple delivery times

% Import: soln struct type
if isExample == 1
    load('FluenceMapping\code\exampleSoln.mat');
    soln(1).param.limits.dose = [0,3];
    solnT = struct('T',{1,2,3,4,5,6,7,8},'soln', {soln, soln, soln, soln, soln, soln, soln, soln});
    isStandAlone = 1;
else
    isStandAlone = 0;
end
FIG_generateTikzCode( solnT, isStandAlone)
cd(mainFolder)