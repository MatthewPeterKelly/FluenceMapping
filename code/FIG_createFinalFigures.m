clear all
close all
clc
format bank

tnow = datestr(now(),'_yyyy-mm-dd_HH-MM-SS');
codeFolder = cd;
resAdd = '\results\finalResults';
figAdd = 'figures';
cd([codeFolder resAdd])
mkdir(figAdd);
addpath(genpath(figAdd))
solFolder = [codeFolder resAdd '\' figAdd];
cd(solFolder)
    
%% Plots using one delivery time and multiple smoothing parameter schemes
% T = 9 seconds --> ask Matthew to change to 6s? Compare with SWLS
load('Results.mat')

    %%% One smoothing parameter scheme only (0.5 --> 0.2)
    iIterSch = 4; % 0.5 --> 0.2


%% Plots using one smoothing parameter scheme and multiple delivery times
% dx = 0.5 --> 0.2
clear -except figFolder mainFolder resfolder solFolder tnow
load('totalDurationSweep.mat') % (uses scheme dx = 0.5 --> 0.2)

%%% One delivery time only
iT = 5; % available delivery time T (index == value)

	%%%% Unimodal fluence profile 
	iDataSet = 1; % unimodal
	Runi = results{iDataSet,iT}(end);

        % Plots desired and delivered fluence profiles
        [figUniProf] = FIG_plotFluenceProfile(Runi);
        save2pdf('FIG_uni_05-02_T5_profile.pdf');
        
        % Corresponding trajectory of both leaves
         [figUniTraj] = FIG_rowTrajectory(Runi,2);
         save2pdf('FIG_uni_05-02_T5_trajectory.pdf');
        %saveAndExportFigure(gcf, ['Trajectory_T' num2str(myT) '_Row' num2str(myRow) tnow])
        
        % Algorithm progress
        %as.x = 'log'; % x-scale % NOT SUPPORTED YET
        as.x = 'linear'; % x-scale
        as.y = 'log'; % y-scale
        %as.x = 'linear'; % x-scale
        mode = 'best'; % shows best obj val after each iteration
        %mode = 'iter'; % shows obj val of every iteration
        [figUniProg] = FIG_plotTvsQ_1R_detailed(Runi,as,mode);
        save2pdf('FIG_uni_05-02_T5_CPUvsObj.pdf');
       
	%%%% Bimodal fluence profile
	iDataSet = 2;
	Rbi = results{iDataSet,iT}(end);

        % Plots desired and delivered fluence profiles
        [figBiProf] = FIG_plotFluenceProfile(Rbi);
        save2pdf('FIG_bi_05-02_T5_profile.pdf');

        % Corresponding trajectory of both leaves
        [figBiTraj] = FIG_rowTrajectory(Rbi,2);
        save2pdf('FIG_bi_05-02_T5_trajectory.pdf');
        
        % Algorithm progress
        %as.x = 'log'; % x-scale % NOT SUPPORTED YET
        as.x = 'linear'; % x-scale
        as.y = 'log'; % y-scale
        %as.x = 'linear'; % x-scale
        mode = 'best'; % shows best obj val after each iteration
        %mode = 'iter'; % shows obj val of every iteration
        [figBiProg] = FIG_plotTvsQ_1R_detailed(Rbi,as,mode);
        save2pdf('FIG_bi_05-02_T5_CPUvsObj.pdf'); 
        
%%% Multiple delivery times (constant dose rate)
if 1 == 2 % NOTE: This data is not yet there?!
iDataSet = 1;
Runi_T = {results{iDataSet,:}};
isStandAlone = 1; % switch to 0 for production mode
showDoseRatePatterns = 0; % hide dose rate patterns
FIG_generateTikzCode(Runi_T, isStandAlone, showDoseRatePatterns)
end         
         
%% Closure
cd(codeFolder)