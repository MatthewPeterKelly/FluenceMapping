function [ fig ] = FIG_heatMap( soln, isDel, maxF )
% FIG_heatMaps(soln, isDel, maxF) plots the heatmap for the desired or delivered
% fluence map
%
% Input:
%   o soln - structure matrix containing the optimization results,
%            where each row corresponds to a leaf pair (see one of the
%            MAIN_*.m files)
%   o isDel - 1 if for delivered map, 0 for desired map
%   o maxF - heatmap colorscale upper bound
%
% Output:
%   o fig - figure handle (figure displayed)
%
% Note: assmues fluence grid is the same across the rows the map

% Error handling
if nargin == 0
    warning('No inputs specified. Example used.')
    isDel = 0;
    for row = 1 : 20
        soln{1,row}(1).target.xGrid = 1:30;
        soln{1,row}(1).target.fGrid = rand(1,30)*20;
        soln{1,row}(1).target.dx = 1;
        maxF = 30;
    end
end

try % Retrieve information
    n = numel(soln); % #leaf pairs
    thegrid = soln{1,1}(end).target.xGrid;
    m = length(thegrid); %#bixels
    
    % Convert to matrix form
    f = zeros(n,m); % fluence map
    for row = 1 : n
        rsoln = soln{1,row}(end);
        if isDel == 1
            f(row,:) = rsoln.target.fSoln; % target
        else % isDel == 0
            f(row,:) = rsoln.target.fGrid; % delivered
        end
    end

catch
    error('Error catched. Probalby the input does not have the required format.')
end

% Setup figure
fig = figure;
ax = gca;
hold on
set(fig,'color','w');
set(ax,'xtick',[],'ytick',[]);

% Heatmap
colormap('hot')
clims = [0,maxF];
imagesc(f,clims);

axis([0.5 m+0.5 0.5 n+0.5]);
bWidth = 15;
bHeight = 15;
fWidth = m * bWidth;
fHeight = n * bHeight;
fig.Position = [420.00 378.00 fWidth fHeight];

% Crop figure (no white spaces)
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
end