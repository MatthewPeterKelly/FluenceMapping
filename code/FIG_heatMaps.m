function [ fig ] = FIG_heatMaps( soln )
% FIG_heatMaps(soln) plots the heatmaps of both desired and delivered
% fluence.
%
% Input:
%   o soln - structure matrix containing the optimization results,
%            where each row corresponds to a leaf pair (see one of the
%            MAIN_*.m files)
%
% Output:
%   o fig - figure handle (figure displayed)
%
% Note: assumes fluence grids are the same for desired and delivered
% fluence and across the rows of both maps.

% Error handling
if nargin == 0
    warning('No inputs specified. Example used.')
    for row = 1 : 20
        soln{1,row}(1).target.xGrid = 1:30;
        soln{1,row}(1).target.fGrid = rand(1,30)*20;
        soln{1,row}(1).target.fSoln = soln{1,row}(1).target.fGrid + rand(1,30)-0.5;
        soln{1,row}(1).target.dx = 1;
    end
end

try % Retrieve information
    n = numel(soln); % #leaf pairs
    thegrid = soln{1,1}(end).target.xGrid;
    thedx = soln{1,2}(end).target.dx;
    m = length(thegrid); %#bixels
    
    % Convert to matrix form
    f = zeros(n,m); % desired fluence
    g = zeros(n,m); % delivered fluence
    
    for row = 1 : n
        rsoln = soln{1,row}(end);
        f(row,:) = rsoln.target.fGrid; % delivered fluence profile
        g(row,:) = rsoln.target.fSoln; % desired fluence profile
    end
catch
    error('Error catched. Probalby the input does not have the required format.')
end

%% Plot fluence maps
% Label preparation
maxF = max(max(f)); maxG = max(max(g));
maxFluence = max(maxF,maxG);
clims = [0,maxFluence];
nLables = 4;
cTicks = 0 : ceil(maxFluence / nLables) : maxFluence;
cTickLabels = cell(1,length(cTicks));
for tick = 1 : length(cTicks)
    cTickLabels(1,tick) = {[num2str(cTicks(1,tick)) ' MU']};
end
nxLables = 6;
cxTicks = 0 : ceil(max(thegrid) / nxLables) : max(thegrid);

% Setup figure
fig = figure;
hold on
set(fig,'color','w');
colormap('hot')

% Desired fluence
ax1 = subplot(1,2,1);
imagesc(f,clims);
axis([0.5 m+0.5 0.5 n+0.5]);
xlabel('Position (cm)','FontSize',12,'Interpreter','latex')
ylabel('Leaf pair','FontSize',12,'Interpreter','latex')
title('Desired Fluence Map','FontSize',14,'Interpreter','latex')
if n <= 10
    yticks(1:n);
    yticklabels(1:n)
else
    yticks(1:2:n)
    yticklabels(1:2:n)
end
xtickformat('%.0f')
xticks(cxTicks/thedx)
xticklabels(cxTicks)
ax1.Position([1,3]) = [0.11, 0.30];

% Delivered fluence
ax2 = subplot(1,2,2);
imagesc(g,clims);
axis([0.5 m+0.5 0.5 n+0.5]);
xlabel('Position (cm)','FontSize',12,'Interpreter','latex')
ylabel('Leaf pair','FontSize',12,'Interpreter','latex')
title('Delivered Fluence Map','FontSize',14,'Interpreter','latex')
if n <= 10
    yticks(1:n);
    yticklabels(1:n)
else
    yticks(1:2:n)
    yticklabels(1:2:n)
end
xtickformat('%.0f')
xticks(cxTicks/thedx)
xticklabels(cxTicks)
ax2.Position([1,3]) = [0.52, 0.3];

% Colorbar
colorbar('Ticks',cTicks, ...
    'TickLabels',cTickLabels, ...
    'Position', [.85 .11 .04 .8150]);

% Make heatmaps square
posf = fig.Position;
wShare = ax1.Position(3) + ax2.Position(3);
hShare = ax1.Position(4);
hNew = hShare * wShare/2 * posf(3) + (1-hShare) * posf(4);
fig.Position(4) = hNew;

% Adjust figure size to fit page
maxDims = [1700 430];
share = fig.Position(3:4)./maxDims;
rescl = max(share);
fig.Position(1:2) = [100, 100];
fig.Position(3:4) = fig.Position(3:4)/rescl;

end