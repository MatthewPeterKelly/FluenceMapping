function saveAndExportFigure(hFig, fileName, export)

if nargin == 2
    export = true;
end

figDir = 'figures';
if ~exist(figDir,'dir')
    mkdir(figDir)
end

% Save to .pdf file in figures/ directory
saveName = [figDir, filesep, fileName, '.pdf'];
save2pdf(saveName,hFig);

% Crop to desired margins and copy to the ../latex/fig/ directory
if isunix() && export
    marginStr = '--margins ''12 12 12 12'' ';
    exportDir = '../latex/fig/';
    exportCmd = ['pdfcrop ', marginStr, saveName, ' ', exportDir, fileName, '.pdf'];
    unix(exportCmd);
end

end