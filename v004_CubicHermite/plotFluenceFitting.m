function plotFluenceFitting(fitErr,x,f,g,A,B,R)

figure(4); clf;

subplot(2,2,1); hold on;
plot(x,f,'ko')
plot(x,g,'rx')
legend('data','fit')
xlabel('position')
ylabel('fluence')
title(['fluence fitting  (err: ' num2str(fitErr) ')'])

t = linspace(A.tLow, A.tUpp, 100);
ax = cubicHermiteInterpolate(A,t);
bx = cubicHermiteInterpolate(B,t);
rx = cubicHermiteInterpolate(R,t);

subplot(2,2,2); hold on;
plot(t,ax)
plot(t,bx)
legend('lower','upper')
title('leaf trajectories')
xlabel('time')
ylabel('position')

subplot(2,2,3); hold on;
plot(t,rx);
xlabel('time')
ylabel('dose rate')
title('dose rate')

end