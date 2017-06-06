function [x, v] = cubicHermiteInterpolate(tLow, tUpp, xLow, xUpp, vLow, vUpp, t)
%  [x, v] = cubicHermiteInterpolate(tLow, tUpp, xLow, xUpp, vLow, vUpp, t)
%  [x, v] = cubicHermiteInterpolate(data, t)
%
% Interpolate the cubic hermite to get position. Clamp t to [tLow, tUpp]

if nargin == 0
    cubicHermiteInterpolate_test();
    return;
end

if nargin == 2
   data = tLow;
   t = tUpp;
   tLow = data.tLow;
   tUpp = data.tUpp;
   xLow = data.xLow;
   xUpp = data.xUpp;
   vLow = data.vLow;
   vUpp = data.vUpp;
end

t = min(max(tLow, t), tUpp);

ppx = pwch([tLow, tUpp],[xLow, xUpp], [vLow, vUpp]);

x = ppval(ppx, t);

if nargout == 2
    ppv =  ppDer(ppx);
    v = ppval(ppv, t);    
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function cubicHermiteInterpolate_test()

tLow = randn(1)  %#ok<NOPRT>
tUpp = tLow + 1.0 + rand(1)  %#ok<NOPRT>
xLow = randn(1)  %#ok<NOPRT>
xUpp = xLow + 0.5 + rand(1)  %#ok<NOPRT>
vLow = 0.1 + rand(1)  %#ok<NOPRT>
vUpp = 0.1 + rand(1)  %#ok<NOPRT>

figure(6); clf;

t = linspace(tLow, tUpp, 200);
[x, v] = cubicHermiteInterpolate(tLow, tUpp, xLow, xUpp, vLow, vUpp, t);

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
