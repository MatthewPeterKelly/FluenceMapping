function tZero = getVelocityRoots(tLow, tUpp, xLow, xUpp, vLow, vUpp)
% tZero = getVelocityRoots(tLow, tUpp, xLow, xUpp, vLow, vUpp)
%
% Given the parameters for a cubic hermite segment, compute the points
% where the velocity is zero. tZero is an array with the two roots of the
% equation. They may be imaginary and are not sorted.
%

if nargin == 0
    getVelocityRoots_test();
    return
end

h = tUpp - tLow;
h1 = 1/h;
h2 = h1*h1;
h3 = h2*h1;

a = 6.0*h3*(xLow - xUpp) + 3.0*h2*(vLow + vUpp);  % quadratic terms
b = 6.0*h2*(xUpp - xLow) - h1*(4*vLow + 2*vUpp);  % linear terms
c = vLow;  % linear term

d = sqrt(b*b - 4*a*c);

if b < 0
    z = -b + d;
else
    z = -b - d;
end

tZero(1) = 0.5*z / a;
tZero(2) = 2.0*c / z;
tZero = tZero + tLow;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function getVelocityRoots_test()

tLow = randn(1)  %#ok<NOPRT>
tUpp = tLow + 1.0 + rand(1)  %#ok<NOPRT>
xLow = randn(1)  %#ok<NOPRT>
xUpp = xLow + 0.5 + rand(1)  %#ok<NOPRT>
vLow = 0.1 + rand(1)  %#ok<NOPRT>
vUpp = 0.1 + rand(1)  %#ok<NOPRT>

tZero = getVelocityRoots(tLow, tUpp, xLow, xUpp, vLow, vUpp)  %#ok<NOPRT>
tZero = sort(tZero);

ppx = pwch([tLow, tUpp],[xLow, xUpp], [vLow, vUpp]);
ppv = ppDer(ppx);

if isreal(tZero)
    
    
    
    t = linspace(min(tZero(1), tLow), max(tZero(2), tUpp), 150);
    x = ppval(ppx, t);
    v = ppval(ppv, t);
    
    figure(5); clf;
    
    subplot(2,1,1); hold on;
    plot(t,x)
    plot(tLow, xLow,'rx')
    plot(tUpp, xUpp,'rx')
    plot(tZero(1), ppval(ppx, tZero(1)),'bo')
    plot(tZero(2), ppval(ppx, tZero(2)),'bo')
    xlabel('t');
    ylabel('x');
    
    subplot(2,1,2); hold on;
    plot(t,v)
    plot(tLow, vLow,'rx')
    plot(tUpp, vUpp,'rx')
    plot(tZero(1), 0,'bo')
    plot(tZero(2), 0,'bo')
    xlabel('t');
    ylabel('v');
    
else
    
    t = linspace(tLow, tUpp, 150);
    x = ppval(ppx, t);
    v = ppval(ppv, t);
    
    figure(5); clf;
    
    subplot(2,1,1); hold on;
    plot(t,x)
    plot(tLow, xLow,'rx')
    plot(tUpp, xUpp,'rx')
    xlabel('t');
    ylabel('x');
    
    subplot(2,1,2); hold on;
    plot(t,v)
    plot(tLow, vLow,'rx')
    plot(tUpp, vUpp,'rx')
    xlabel('t');
    ylabel('v');
    
end
end
