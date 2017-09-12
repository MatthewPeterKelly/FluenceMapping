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
        soln(1,row).target.xGrid = 1:30;
        soln(1,row).target.fGrid = rand(1,30)*20;
        soln(1,row).target.dx = 1;
        maxF = 30;
    end
end

try % Retrieve information
    n = numel(soln); % #leaf pairs
    thegrid = soln(1,1).target.xGrid;
    m = length(thegrid); %#bixels
    
    % Convert to matrix form
    f = zeros(n,m); % fluence map
    for row = 1 : n
        rsoln = soln(1,row);
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
hold on
set(fig,'color','w');
set(gca,'xtick',[],'ytick',[]);

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
end