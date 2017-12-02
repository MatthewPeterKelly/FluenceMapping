function plotFluence(tGrid, xLow, xUpp, fTarget, fDelivered, xGrid)

subplot(1, 2, 2); hold on;
plot(tGrid,xLow,'r-o');
plot(tGrid,xUpp,'b-o');
xlabel('time');
ylabel('leaf position');
legend('Leaf One','Leaf Two');

subplot(1, 2, 1); hold on;
plot(fTarget,xGrid,'k-o')
plot(fDelivered,xGrid,'r-x')

end