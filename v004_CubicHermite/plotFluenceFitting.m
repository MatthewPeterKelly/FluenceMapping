function plotFluenceFitting(fitErr,x,f,g,A,B,R)

figure(4); clf;

t = linspace(A.tLow, A.tUpp, 100);
ax = cubicHermiteInterpolate(A,t);
bx = cubicHermiteInterpolate(B,t);
rx = R(t);

subplot(2,2,1); hold on
plot(t,ax)
plot(t,bx)
xlabel('time');
ylabel('leaf position');
legend('Leaf One','Leaf Two');
title('Optimal Solution')

subplot(2,2,3); hold on;
plot(t,rx);
xlabel('time')
ylabel('fluence dose')

subplot(2,2,2); hold on;
plot(x,f,'ko')
plot(x,g,'rx')
plot(x,f,'k-')
plot(x,g,'r-','LineWidth',1)
xlabel('position','LineWidth',1)
ylabel('fluence')
legend('target','estimated')
title('Fluence Fitting')

subplot(2,2,4); hold on;
plot(x,f-g,'m*')
xlabel('position')
ylabel('fluence error')
title('fitting error')
title(['MSE: ' num2str(fitErr)]);

end