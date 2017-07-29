function plotFluenceSoln(soln)

% Plot the solution of a fluence-fitting optimization

tGrid = soln.traj.time;

subplot(2,2,2); hold on;
plot(tGrid, soln.traj.xLow,'r-o');
plot(tGrid, soln.traj.xUpp,'b-o');
xlabel('time (sec)');
ylabel('leaf position (cm)');
legend('Leaf One','Leaf Two');

h = subplot(2,2,4); hold on;
plot(tGrid, soln.traj.dose, 'g-o');
xlabel('time')
ylabel('fluence dose')
h.YLim = [0, h.YLim(2)];

subplot(2,2,1); hold on;
plot(soln.target.fGrid, soln.target.xGrid,'rx')
plot(soln.param.fluenceTargetDense.f, soln.param.fluenceTargetDense.x, 'r-','LineWidth',1)
plot(soln.target.fSoln, soln.target.xGrid,'ko','LineWidth',2)
plot(soln.benchmark.fGrid, soln.benchmark.xGrid,'k-','LineWidth',2)
ylabel('leaf position (cm)')
xlabel('fluence dose (MU)')
legend('Fitting Points','Fluence Target', 'Smooth Fluence', 'Exact Fluence',...
       'Location','SouthEast');


end