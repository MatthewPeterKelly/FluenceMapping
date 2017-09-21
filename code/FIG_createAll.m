% TODO: more advanced figures like Figures 4&5 in Craft & Balvert (2017),
%       TikZ-based.
% TODO: some positioning, sizing and saving formalities

close all
clc

% Settings
isExample = 0; % 1 for example, 0 for real case
tnow = datestr(now(),'_yyyy-mm-dd_HH-MM-SS');
mainFolder = cd;

if isExample == 1
    figFolder = [mainFolder '\latex\fig'];
    cd(figFolder);
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
    % Load data 
    resFolder = '\code\results\cortData_Sep-19-20-06-36';
    solFolder = [mainFolder resFolder];
    cd(solFolder)
    data = load(fullfile(solFolder, 'solnT.mat'));
    solnT = data.solnTimeDataStruct;

    % Make some choices
    myRow = 5; % index of row for which the trajectory is visualzed
    myT = 6; % delivery time for which the delivered map is visualized
    
    index = find([solnT.T] == myT);
    thesoln = solnT(index).soln;
    maxDose = solnT(myT).soln(myRow).param.limits.doseRate(2);
    
    % Heatmap comparison
    fig1 = FIG_heatMaps(thesoln); % for multiple leaf rows
    saveAndExportFigure(gcf, ['FluenceMaps' tnow])
    
    % One heatmap
    isDel = 1;
    fig2 = FIG_heatMap(thesoln, isDel, maxDose);
    
    % Trajectory of a (central) row
    fig3 = FIG_rowTrajectory(thesoln,myRow,2); % for one row
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
    isStandAlone = 1; % switch to 0 for production mode
end
FIG_generateTikzCode(solnT, isStandAlone)
cd(mainFolder)