function [fitErr, x,f,g,A,B,R] = getFittingErr(tBnd, xBnd, vLow, vUpp, rData, dataFun)

if nargin == 0
    getFittingErr_test();
    return;
end

[g, x, w, A, B, R] = getFluenceProfile(tBnd, xBnd, vLow, vUpp, rData);
f = dataFun(x);
err = (f-g).^2;
fitErr = sum(err.*w);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%


function getFittingErr_test()

tBnd = [0, 3];
xBnd = [2, 6];
vLow = sort(0.1 + rand(1,2), 2, 'ascend');
vUpp = sort(0.1 + rand(1,2), 2, 'descend');
rData = rand(1,8);

dataFun = @(x)(  x.^2 );

[fitErr, x,f,g,A,B,R] = getFittingErr(tBnd, xBnd, vLow, vUpp, rData, dataFun);

plotFluenceFitting(fitErr,x,f,g,A,B,R);

end