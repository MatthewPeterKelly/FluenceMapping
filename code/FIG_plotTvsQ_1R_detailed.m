function [myFig] = FIG_plotTvsQ_1R_detailed(R,as,mode)
% Shows the progress of the smoothed and corresponding exact objective
% value over CPU time, for one smoothing scheme.

% TODO: adjust paramter step and doublearrow annotation to allow for
% logarihmic x axis scale.

% Input handling
if nargin < 1
    R.diagnostics.cpuTime = 1:5;
    R.diagnostics.objVal = rand(5);
    R.diagnostics.objExact = rand(5);
    R.param.smooth.leafBlockingWidth = 0.05;
end
if nargin < 2
    as.x = 'linear';
    as.y = 'log';
end
if nargin < 3
    mode = 'best';
end

% Increment cpuTimes to sequence
[~,m] = size(R); % number of steps in parameter scheme
tIterStart = zeros(m,1);
for j = 2 : m
    tIterStart(j:end) = tIterStart(j:end) + R(j-1).diagnostics.cpuTime(end);
end
for j = 2 : m
    R(j).diagnostics.cpuTime = R(j).diagnostics.cpuTime + tIterStart(j);
end

% Specify line colors, styles and names for legend and plotting
myLine(1).name = 'ObjVal (smoothed)';
myLine(1).color = 'b';
myLine(1).style = '-';
myLine(2).name = 'ObjVal (exact)';
myLine(2).color = 'r';
myLine(2).style = '-';
myLine(3).name = 'ObjVal (last exact)';
myLine(3).color = 'g';
myLine(3).style = ':';
myLine(4).name = 'Smoothing value transition';
myLine(4).color = 'k';
myLine(4).style = '--';

% Filter data if only best smoothed objvals over time (and corresponding
% exact objvals) should be shown
if strcmp(mode,'best')

    for j = 1 : m
        D = R(j).diagnostics;
        if j == 1
            temp.cpuTime(1,1) = tIterStart(j); % at start, we got nothing
            temp.objVal(1,1)= inf;
            temp.objExact(1,1) = inf;
            kStart = 1;
        else
            temp.cpuTime(1,1) = D.cpuTime(1);
            temp.objVal(1,1) = D.objVal(1);
            temp.objExact(1,1) = D.objExact(1);
            kStart = 2;
        end  
        for k = kStart : length(D.cpuTime)-1
            if D.objVal(k) < temp.objVal(end) - 0.001 % minimal improvement
                temp.cpuTime(end+1,1) = D.cpuTime(k);
                temp.objVal(end+1,1)= D.objVal(k);
                temp.objExact(end+1,1) = D.objExact(k);
            end
        end
        if temp.cpuTime(end) ~= D.cpuTime(end) % end of step needs to be used
            temp.cpuTime(end+1) = D.cpuTime(end);
            temp.objVal(end+1) = temp.objVal(end);
            temp.objExact(end+1) = temp.objExact(end);
        end
        R(j).diagnostics = temp;
        clearvars temp
    end 
else % use the original iteration-wise data
end

% Plot objVal and objExact against cpuTime in piece-wise linear graph, for
% each step in the paramater scheme
myFig = figure();
setFigureSize('wide')
set(myFig,'color','w');
hold on

deltax = zeros(m,1);
maxyj = zeros(m,1);
for j = 1 : m % steps in smoothing scheme
    deltax(j) = R(j).param.smooth.leafBlockingWidth; % smoothing level
    D = R(j).diagnostics;
    D.cpuTime = D.cpuTime;
    
    % Little error handling
    n1 = length(D.cpuTime); n2 = length(D.objVal); n3 = length(D.objExact);
    n = min([n1,n2,n3]);
    if n1 ~= n2 || n1~= n3
        warning('cpuTime, objVal and objExact vectors should have equal length. Continued with smallest length.')
    end
    
    % Smoothed objective value
    for i = 1 : n-1
        line([D.cpuTime(i),D.cpuTime(i+1)],[D.objVal(i),D.objVal(i)],'Color',myLine(1).color,'LineStyle',myLine(1).style)
        line([D.cpuTime(i+1),D.cpuTime(i+1)],[D.objVal(i),D.objVal(i+1)],'Color',myLine(1).color,'LineStyle',myLine(1).style)
    end
    
    % Exact objective value (on top)
    for i = 1 : n-1
        line([D.cpuTime(i),D.cpuTime(i+1)],[D.objExact(i),D.objExact(i)],'Color',myLine(2).color,'LineStyle',myLine(2).style)
        line([D.cpuTime(i+1),D.cpuTime(i+1)],[D.objExact(i),D.objExact(i+1)],'Color',myLine(2).color,'LineStyle',myLine(2).style)
    end
    
    % Connect objective values between scheme steps
    if j < m
        D2 = R(j+1).diagnostics;
        % line([D.cpuTime(end),D2.cpuTime(1)],[D.objVal(end),D2.objVal(1)],'Color',myLine(1).color,,'LineStyle',myLine(1).style) % smoothed (different)
        line([D.cpuTime(end),D2.cpuTime(1)],[D.objExact(end),D2.objExact(1)],'Color',myLine(2).color,'LineStyle',myLine(2).style) % exact (same)
    end
    
    % Store largest values for figure sizing
    maxyj(j) = max([D.objVal(isfinite(D.objVal)) ;D.objExact(isfinite(D.objExact))]); 
end

% Algorithm termination & accepted solution
Dend = R(end).diagnostics;
scatter(Dend.cpuTime(end),Dend.objExact(end),'MarkerEdgeColor',myLine(3).color,'MarkerFaceColor',myLine(3).color)
line([0.01,Dend.cpuTime(end)],[Dend.objExact(end),Dend.objExact(end)],'Color',myLine(3).color,'LineStyle',myLine(3).style)

% Axes handling
myAxes = gca;
xlabel('CPU time (s)','FontSize',12)
ylabel('Objective value','FontSize',12)

% Switch both axes to log-scale for better view
myAxes.YAxis.Scale = as.y;
myAxes.XAxis.Scale = as.x;

if strcmp(as.y,'linear')
    xMarginScale = 1.5;
else
    xMarginScale = 1;
end
if strcmp(as.y,'linear')
    yMarginScale = 1.5;
else
    yMarginScale = 1.05;
end
maxx = xMarginScale * (R(m).diagnostics.cpuTime(end));
maxy = yMarginScale * max(maxyj);
xlim([0,maxx]);
ylim([0,maxy]);

% Grid
myAxes.GridAlpha = 0.25;
myAxes.MinorGridAlpha = 0.3;
grid on

% Transition between smoothing schedule steps
for j = 1 : m
    D = R(j).diagnostics;
    if m > 1 && j < m % otherwise not of added value
        line([D.cpuTime(end),D.cpuTime(end)],[0.001,maxy],'Color',myLine(4).color,'LineStyle',myLine(4).style) % vertical line
    end
    
    % Scale for annotations: smoothing parameter value
    if strcmp(as.x,'linear')
        xS =  tIterStart(j)/maxx; % linear scale
        xE =  D.cpuTime(end)/maxx; % linear scale
    else
        xS =  max(0,log10(tIterStart(j))/log10(maxx)); % log scale % BUG
        xE =  max(0,log10(D.cpuTime(end))/log10(maxx)); % log scale % BUG
    end
    
    xScale = myAxes.Position(3);
    yScale = myAxes.Position(4);
    xAdd = myAxes.Position(1);
    yAdd = myAxes.Position(2);
    
    % Draw double arrow
    xa = [xS*xScale + xAdd, xE*xScale + xAdd];
    ya = ones(2,1) * (yAdd + yScale * 0.95);
    annarrow = annotation('doublearrow',xa,ya);
    annarrow.Head1Style = 'plain';
    annarrow.Head2Style = 'plain';
    
    % Smoothing parameter value (label)
    dim = [xS*xScale + xAdd, ...
        .9*yScale + yAdd, ...
        (xE-xS)*xScale, ...
        .1*yScale];
    
    str = ['\Deltax = ' num2str(deltax(j))];
    ann = annotation('textbox',dim,'String',str);
    ann.FontSize = 12;
    ann.HorizontalAlignment = 'center';
    ann.VerticalAlignment = 'top';
    ann.FitBoxToText = 'on';
    ann.BackgroundColor = 'w';
   % ann.LineStyle = 'none';
   
end

% Legend
h = zeros(4,1);
h(1) = plot(NaN,NaN,'Color',myLine(1).color,'LineStyle',myLine(1).style);
h(2) = plot(NaN,NaN,'Color',myLine(2).color,'LineStyle',myLine(2).style);
h(3) = plot(NaN,NaN,'Color',myLine(3).color,'LineStyle',myLine(3).style);
h(4) = plot(NaN,NaN,'Color',myLine(4).color,'LineStyle',myLine(4).style);
myLegend = legend(h, myLine(1).name,myLine(2).name,myLine(3).name,myLine(4).name);
myLegend.FontSize = 10;
myLegend.Location = 'best';

% Adjust behaviour of all lines
set(findall(myAxes, 'Type', 'Line'),'LineWidth',1.5); % line width

end