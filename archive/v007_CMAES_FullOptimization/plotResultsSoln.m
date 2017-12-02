function plotResultsSoln(soln, pltOpt)

% Used to generate results for figures in the paper

hFig = gcf;
switch pltOpt.format
    case 'fluence-leaf-side-by-side'
        
        subplot(1,2,2); hold on;
        plotLeaves(soln);
        
        subplot(1,2,1); hold on;
        plotFLuence(soln);
        if pltOpt.saveResults
            setFigureSize('wide');
            saveAndExportFigure(hFig, pltOpt.fileName);
        end
end


end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function plotFLuence(soln)

plot(soln.target.fGrid, soln.target.xGrid,'rx')
plot(soln.param.fluenceTargetDense.f, soln.param.fluenceTargetDense.x, 'r-','LineWidth',1)
plot(soln.target.fSoln, soln.target.xGrid,'ko','LineWidth',2)
plot(soln.benchmark.fGrid, soln.benchmark.xGrid,'k-','LineWidth',1)
ylabel('leaf position (cm)')
xlabel('fluence dose (MU)')
legend('Fitting Points','Fluence Target', 'Smooth Fluence', 'Exact Fluence',...
    'Location','SouthEast');
title('Fluence Delivered')

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function plotLeaves(soln)

tGrid = soln.traj.time;

plot(tGrid, soln.traj.xLow,'r-o');
plot(tGrid, soln.traj.xUpp,'b-o');
xlabel('time (sec)');
ylabel('leaf position (cm)');
legend('Leaf One','Leaf Two','Location','SouthEast');
title('Leaf Trajectories')

end