function plotFluence(tGrid, xLow, xUpp, fTarget, fDelivered, xGrid)

subplot(1, 2, 2); hold on;
plot(tGrid,xLow,'r-o','LineWidth',2);
plot(tGrid,xUpp,'b-o','LineWidth',2);
xlabel('time (s)');
ylabel('leaf position (cm)');
legend('Leaf One','Leaf Two','Location','SouthEast');

subplot(1, 2, 1); hold on;
plot(fTarget,xGrid,'k-o','LineWidth',2)
plot(fDelivered,xGrid,'r-x','LineWidth',2)
xlabel('fluence dose (MU)');
ylabel('dose position (cm)');
legend('Target','Delivered','Location','SouthEast');

end