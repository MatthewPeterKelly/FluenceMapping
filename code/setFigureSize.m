function setFigureSize(format)

switch format
    case 'wide'
        
        hFig = gcf;
        width = 1600;
        height = 330;
        xStart = 100;
        yStart = 100;
        hFig.Units = 'pixels';
        hFig.Position = [xStart, yStart, xStart+width, yStart+height];
        
    case 'wide-small'
        
        hFig = gcf;
        width = 800;
        height = 200;
        xStart = 100;
        yStart = 100;
        hFig.Units = 'pixels';
        hFig.Position = [xStart, yStart, xStart+width, yStart+height];
        
    case 'square'
        
        hFig = gcf;
        width = 600;
        height = 400;
        xStart = 100;
        yStart = 100;
        hFig.Units = 'pixels';
        hFig.Position = [xStart, yStart, xStart+width, yStart+height];
        
    otherwise
        error('Invalid Format!')
end

end