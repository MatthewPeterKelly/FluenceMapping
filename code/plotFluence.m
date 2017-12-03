function plotFluence(tGrid, xLow, xUpp, fTarget, fDelivered, xGrid)

subplot(1, 2, 2); hold on;
plot(tGrid,xLow,'r-o','LineWidth',2);
plot(tGrid,xUpp,'b-o','LineWidth',2);
xlabel('time');
ylabel('leaf position');
legend('Leaf One','Leaf Two','Location','SouthEast');

subplot(1, 2, 1); hold on;
plot(fTarget,xGrid,'k-o','LineWidth',2)
plot(fDelivered,xGrid,'r-x','LineWidth',2)
xlabel('fluence dose');
ylabel('dose position');
legend('Target','Delivered','Location','SouthEast');

end