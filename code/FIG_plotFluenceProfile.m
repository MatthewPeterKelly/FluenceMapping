function [fig] = FIG_plotFluenceProfile(R)
% Plots the desired and delivered fluence profile

% Retrieve relevant data
x = R.target.xGrid;
f = R.target.fGrid;
g = R.target.fSoln;

% Create the figure
fig = figure;
setFigureSize('square')
plot(x,f,'-k', ...
    x,g,'--k')
xlabel('position (cm)','FontSize',12,'Interpreter','latex')
ylabel('fluence (MU)','FontSize',12,'Interpreter','latex')
legend('Target', 'Delivered','Location','NorthWest')
end