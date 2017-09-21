function [ ] = FIG_generateTikzCode( solnT, isStandAlone )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

% File to print TikZ code
fileName = 'TikZCode.tex';
fileID=fopen(fileName,'w');

%% Generate preamble if standalone
if isStandAlone == 1
    strA= { '\documentclass{standalone}', ...
        '\usepackage{graphicx,amsmath}', ...
        '\usepackage{amssymb,amsthm}', ...
        '\usepackage{varwidth}', ...
        '\usepackage{moresize}', ...
        '\usepackage[skins]{tcolorbox}', ...
        '\usepackage{tikz}', ...
        '\usetikzlibrary{external}', ...
        '\usetikzlibrary{calc}', ...
        '\usepackage{pgfplots}',...
        '\pgfplotsset{compat=newest} % Allows to place the legend below plot'};
    
    fprintf(fileID,'%s\r\n',strA{:});
    fprintf(fileID,'\r\n%s\r\n','\begin{document}');
    clear strA
end
%% Some important values
TGrid =[solnT.T];
maxT = max(TGrid);
minT = 0; %min(tGrid);
numT = length(TGrid);

objT = zeros(1,numT);
for iT = 1 : numT
    objT(iT) = sum([solnT(iT).soln.obj]);
end
minObj = 0; %min(objT);
maxObj = max(objT);
yPower = floor(log10(abs(maxObj))); % power of 10 for scientific notation
cY = 10^yPower; % correction factor for ssdiff
objT = objT/cY;
maxObj = maxObj/cY;

% Determine maximum fluence over all(!) maps
n = numel(solnT(1).soln); % #leaf pairs
thegrid = solnT(1).soln(1,1).target.xGrid;
m = length(thegrid); %#bixels

maxs = zeros(1,numT);
for iT = 1 : numT
    % Convert to matrix form
    f = zeros(n,m); % desired fluence
    g = zeros(n,m); % delivered fluence

    for row = 1 : n
        rsoln = solnT(iT).soln(1,row);
        f(row,:) = rsoln.target.fGrid; % delivered fluence profile
        g(row,:) = rsoln.target.fSoln; % desired fluence profile
    end
    maxs(iT) = max(max(max(f,g)));
end
maxF = ceil(max(maxs));
dmax = solnT(1).soln(1).param.limits.doseRate(2);

%% Prtin the axis options
fprintf(fileID,'%s\r\n','\begin{tikzpicture}[x=1cm, y=1cm]');
AxOpts = { '\begin{axis}[',...
    'clip=false,',...
    'clip mode=individual,',...
    'width=\linewidth, % Scale the plot to \linewidth',...
    'height=150pt,',...
    ['xmin=' num2str(minT) ', xmax=' num2str(maxT) ','], ...
    ['ymin=' num2str(minObj) ', ymax=' num2str(maxObj) ','], ...
    'enlarge x limits=false,',...
    'enlarge y limits=false,',...
    'axis lines=center,',...
    'axis line style={-},',...
    'grid=both,',...
    'grid style={line width=.2pt, draw=gray!30},',...
    'major grid style={line width=.3pt,draw=gray!60},',...
    'minor x tick num=1,',...
    'xlabel style = {anchor=west,',...
    'at={(ticklabel* cs:1.01,0)},',...
    'text width=width("Max delivery"),',...
    '},',...
    'ylabel style={at={(ticklabel* cs:1.01)},',...
    'anchor=south',...
    '},',...
    'xlabel={Max delivery \newline time (s)},',...
    'x tick label style={anchor=north},',...
    'y tick label style={anchor=east},',...
    'xtick distance=1,',...
    'scaled ticks=false,',...
    'max space between ticks=40pt, % controls % y ticks',...
    'try min ticks = 5,'
    };
fprintf(fileID,'%s\r\n\t',AxOpts{:});

if yPower > 0
    str = ['ylabel=ssdif ($\times 10^' num2str(yPower) '$)'];
    fprintf(fileID,'%s\r\n',str);
else
    fprintf(fileID,'%s\r\n','ylabel=ssdif');
end
fprintf(fileID,'%s\r\n\r\n',']');

%% Plot the trade-off curve
fprintf(fileID,'%s\r\n\t','% Plot the dots and connect');
toc = [];
for iT = 1 : numT
    toc = [toc '(' num2str(TGrid(iT)) ',' num2str(objT(iT)) ') '];
end
str = ['\addplot[black, mark=*] coordinates { ' toc '};'];
fprintf(fileID,'%s\r\n\r\n',str);

%% Some scaling
eps = 0.03; % some margin on the figures
Ysc = maxObj/150/0.0353; % maxObj to cm (via pt)

%% Plot the original map
Tsoln = solnT(1).soln; % to get target
hFig = FIG_heatMap( Tsoln, 0, maxF );
ofm = 'origMap.png'; % originial fluence map file name

print(hFig,ofm, '-dpng') % eps and pdf not well supported in tikz app

locText = ['(' num2str(maxT) ',' num2str(5.6*Ysc) ')'];
ofmloc1 = ['(' num2str(1.0286*maxT) ',' num2str(2.8*Ysc) ')'];
ofmloc2 = ['(' num2str(1.0286*maxT+1-2*eps) ',' num2str(5.3*Ysc) ')'];

origMap = {'% Original map', ...
    ['\node[anchor=west] at ' locText ' {\footnotesize{Original map:}}; % Text'],...
    ['\path[fill stretch image=' ofm ' ] ' ofmloc1 ' rectangle ' ofmloc2 '; % Figure']};
fprintf(fileID,'%s\r\n',origMap{:});

%% Draw the labels of following axis
fprintf(fileID,'\r\n%s\r\n','% Draw the fluence maps)');
loc1 = ['(0,' num2str(-2.05*Ysc) ')'];
fprintf(fileID,'%s\r\n',['\node[rotate=90, text width = width("Fluence"), text centered] at ' loc1 ' {\footnotesize{Fluence map}};']);

for iT = 1 : numT
    T = TGrid(iT);
    Tsoln = solnT(iT).soln; % to get target
    hFig = FIG_heatMap( Tsoln, 1, maxF );
    fileName = ['delMap' num2str(T);]; % name unique to T
    print(hFig,fileName, '-dpng')
        
    loc1 = ['(' num2str(TGrid(iT)-0.5+eps) ',' num2str(-3.3*Ysc) ')'];
    loc2 = ['(' num2str(TGrid(iT)+0.5-eps) ',' num2str(-0.8*Ysc) ')'];
    str = [ '\path[fill stretch image=' fileName '] ' loc1 ' rectangle ' loc2 ';'];
    fprintf(fileID,'%s\r\n',str);
end

%% Draw the colorbar
fprintf(fileID,'\r\n%s\r\n','% Draw the colorbar');
cFig = figure;
axis off
set(cFig,'color','w');
colormap('hot')
clims = [0,maxF];
caxis(clims);
nLables = 4;
cTicks = 0 : ceil(maxF/ nLables) : maxF;
cTickLabels = cell(1,length(cTicks));
for tick = 1 : length(cTicks)
    cTickLabels(1,tick) = {[num2str(cTicks(1,tick)) ' MU']};
end
cBar = colorbar('Ticks',cTicks, ...
    'TickLabels',cTickLabels);%, ...
cBar.Position(4) = 0.3;
fileName = 'colorBar';
export_fig(fileName,'-png','-r250')

loc1 = ['(' num2str(TGrid(iT)+0.5+5*eps) ',' num2str(-3.3*Ysc) ')'];
loc2 = ['(' num2str(TGrid(iT)+1.5-7*eps) ',' num2str(-0.8*Ysc) ')'];
str = [ '\path[fill stretch image=' fileName '] ' loc1 ' rectangle ' loc2 ';'];
fprintf(fileID,'%s\r\n',str);

%% Draw the dose rate patterns
% Axis
fprintf(fileID,'\r\n%s\r\n','% Draw the dose rate axis');
loc1 = ['(0,' num2str(-4.5*Ysc) ')'];
loc3 = ['(' num2str(maxT/2+1/2) ',' num2str(-5.9*Ysc) ')'];
fprintf(fileID,'%s\r\n',['\node[rotate=90, text width = width("Dose Rate"), text centered] at ' loc1 ' {\footnotesize{Dose rate (MU/s)}};']);
fprintf(fileID,'%s\r\n',['\node[anchor=north, text centered] at ' loc3 ' {\footnotesize{Time (s)}};']);

for iT = 1 : numT
    % horizontal lines
    loc1 = ['(' num2str(TGrid(iT)-0.5+eps) ',' num2str(-5.5*Ysc) ')'];
    loc2 = ['(' num2str(TGrid(iT)+0.5-eps) ',' num2str(-5.5*Ysc) ')'];
    str = [ '\draw[-] ' loc1 ' -- ' loc2 ';'];
    fprintf(fileID,'%s\r\n',str);
    
    % vertical lines
    loc1 = ['(' num2str(TGrid(iT)-0.5+eps) ',' num2str(-5.5*Ysc) ')'];
    loc2 = ['(' num2str(TGrid(iT)-0.5+eps) ',' num2str(-3.5*Ysc) ')'];
    str = [ '\draw[-] ' loc1 ' -- ' loc2 ';'];
    fprintf(fileID,'%s\r\n',str);
end

% y-ticks
fprintf(fileID,'\r\n%s\r\n','% y-ticks');
loc = ['(' num2str(TGrid(1)-0.5+eps) ',' num2str(-5.5*Ysc) ')'];
str = ['\node[anchor=east] at ' loc ' {\footnotesize{0}};'];
fprintf(fileID,'%s\r\n',str);
loc = ['(' num2str(TGrid(1)-0.5+eps) ',' num2str(-3.5*Ysc) ')'];
str = ['\node[anchor=east] at ' loc ' {\footnotesize{' num2str(dmax) '}};'];
fprintf(fileID,'%s\r\n',str);

% x-ticks
fprintf(fileID,'\r\n%s\r\n','% x-ticks');
for iT = 1 : numT
    T = TGrid(iT);
    loc1 = ['(' num2str(TGrid(iT)-0.5+3*eps) ',' num2str(-5.5*Ysc) ')'];
    loc2 = ['(' num2str(TGrid(iT)+0.5-3*eps) ',' num2str(-5.5*Ysc) ')'];
    str1 = ['\node[anchor=north] at ' loc1 ' {\footnotesize{0}};'];
    str2 = ['\node[anchor=north] at ' loc2 ' {\footnotesize{' num2str(T) '}};'];
    fprintf(fileID,'%s\r\n',str1);
    fprintf(fileID,'%s\r\n',str2);
end

% Draw the actual dose rate patterns
fprintf(fileID,'\r\n%s\r\n','% Draw the dose rate patterns');
for iT = 1 : numT
    T = TGrid(iT);
    time = solnT(iT).soln(1).traj.time; % assumes same grid among rows
    dose = solnT(iT).soln(1).traj.dose; % assumes same grid among rows
    nTime = length(time);
    
    cor = [];
    for it = 1 : nTime
        t = time(it);
        d = dose(it);
        tmax = time(end);
        xloc = (T-1)+0.5+eps + (1-2*eps)*(t/tmax);
        yloc = (-5.5+2*(d/dmax))*Ysc;
        cor = [cor '(' num2str(xloc) ',' num2str(yloc) ') '];
    end
    str = ['\addplot[black, mark=*, mark size=1pt] coordinates {' cor '};'];
    fprintf(fileID,'%s\r\n',str);
end

%% Closure
% Close enviroments
fprintf(fileID,'\r\n%s\r\n','\end{axis}');
fprintf(fileID,'%s\r\n','\end{tikzpicture}');
if isStandAlone == 1
    fprintf(fileID,'%s\r\n','\end{document}');
end
close all % close all figures

% Close the file
fclose(fileID);

end