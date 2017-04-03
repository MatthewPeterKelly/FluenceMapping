function plotFluenceFitting(tGrid,xLowGrid,xUppGrid,trGrid,rFun,xGrid,fGrid,fluenceFun)

ppxLow = pchip(tGrid,xLowGrid);
ppxUpp = pchip(tGrid,xUppGrid);
t = linspace(tGrid(1), tGrid(end), 100);
xLow = ppval(ppxLow,t);
xUpp = ppval(ppxUpp,t);
r = rFun(t);
rGrid = rFun(trGrid);

x = linspace(xGrid(1), xGrid(end), 100);
ppf = pchip(xGrid, fGrid);
f = ppval(ppf,x);

subplot(2,2,2); hold on;
plot(t,xLow,'r-');
plot(t,xUpp,'b-');
plot(tGrid,xLowGrid,'ro');
plot(tGrid, xUppGrid,'bo');
xlabel('time');
ylabel('leaf position');
legend('Leaf One','Leaf Two');

subplot(2,2,4); hold on;
plot(t,r,'g-');
plot(trGrid,rGrid,'go');
xlabel('time')
ylabel('fluence dose')

subplot(2,2,1); hold on;
if nargin > 7
    xTarget = linspace(xGrid(1), xGrid(end), 100);
   fTarget = fluenceFun(xTarget);
   plot(fTarget,xTarget,'b-');
end
plot(f,x,'k-')
plot(fGrid,xGrid,'ko');
if nargin > 7
    legend('Fluence Target','Fluence Delivered');
end
xlabel('fluence')
ylabel('position')

end