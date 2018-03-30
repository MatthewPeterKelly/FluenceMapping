function data = getCortDataFullMap(rowIdx, name)
%
% @param:  rowIdx  --  which row of the fluence map to use
%
% If multiple data sets are required, then simply add a second argument.
%

%%%% TODO:  replace with hard-coded CORT data set
rawData = [...
    0         0         0         0         0         0         0         0    1.7161    1.6782    1.6855         0         0;
    0         0         0         0         0    4.5014    4.4854    5.9117    8.6293    8.7217    6.5342    6.0618         0;
    0         0         0         0         0         0    0.5316    6.3237   10.2998   10.9428   10.7978    9.9621    9.6194;
    0         0         0         0    0.7999    2.4859         0         0    0.7080    2.1105    5.2234    7.7766    8.0534;
    0         0         0    5.7378    4.9081    0.9797         0         0    1.4410         0         0         0         0;
    1.4206    3.9839    9.6022    6.8258    2.3739         0         0         0         0    0.0681    1.2030         0         0;
    2.7745    4.7568    1.9040    2.3049    2.2920    0.0942         0         0         0         0         0         0         0;
    2.9189    3.2361    2.9055    2.7105    2.7742         0         0         0         0         0         0         0         0;
    0.6143         0    0.0058    0.1167    0.0816         0         0         0         0         0         0         0         0;
    0    5.1807    4.2935    3.2400    2.3796    0.7185    0.1619         0         0         0    0.0001         0         0;
    0         0    1.9791    7.0835    4.8402    4.8508    0.2581         0    5.1989   15.8794   23.0199   18.9020   17.9882;
    0         0         0    5.5470    9.5507   10.1578   12.4364   18.0679   24.5219   22.3425   18.6812   16.7426   13.6187;
    0         0         0         0    1.2481    6.6251    9.3975   13.0387   14.3398   13.1258   12.8300   13.1942   11.8914;
    0         0         0         0         0         0    4.3102    9.6847   14.5618   14.9369   13.1539   11.8256   10.7831;
    0         0         0         0         0    5.6051    5.9040    7.8643   11.5380   11.8454   10.1696    9.4062         0];

if strcmp(name, 'bimodel')
   rawData = rawData'; 
end

% Extract the data row:
data.f = rawData(rowIdx, :);

% Note: The data points for the fluence are equally spaced and centered on
% a uniform grid that moves from the lower to upper bound. This is
% requrired for the integrals in the code to make sense: the target fluence
% at each point is an integral over a bin width. If we try to fit fluence
% at the precise edge of the domain then we get something non-sensical.

% Generate the data for sampling the fluence map:
data.xLow = 0;
data.xUpp = 14;
nData = length(data.f);
xTmp = linspace(data.xLow, data.xUpp, nData + 1);
data.x = 0.5*(xTmp(2:end) + xTmp(1:(end-1)));
data.maxLeafSpeed = 3;
data.maxDoseRate = 10;

end