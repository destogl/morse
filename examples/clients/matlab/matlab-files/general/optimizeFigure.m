%% Function Optimize Figure
%
% Denis Štogl 2012 IIROB group IPR/KIT
% http://rob.ipr.kit.edu/english/303.php
%
% Definition: optimizeFigure(figureHandle, xlimValues, ylimValues)
%
% This function sets some figure parameters on static so figure can be
% fast drown.
%
% Input:
%       figureHandle - handle of figure to optimize
%       xlimValues - parameter for xlim function (optional)
%       ylimValues - parameter for ylim funciton (optional)

function optimizeFigure(figureHandle, xlimValues, ylimValues)

% set figure with figurehandle activ
axesHandles = findall(figureHandle, 'Type', 'Axes');

for i = 1:length(axesHandles)

    axes(axesHandles(i));
    
    % Static legend
    set(gca,'LegendColorbarListeners',[]); 
    setappdata(gca,'LegendColorbarManualSpace',1);
    setappdata(gca,'LegendColorbarReclaimSpace',1);
    legend off;

    % Draw mode and limits
    set(gca,'DrawMode','fast');

    % Static limits
    if nargin >= 2
        xlim(xlimValues);
        set(gca, 'XLimInclude', 'off');
        set(gca, 'XLimMode', 'manual');
    end
    if nargin >= 3
        ylim(ylimValues);
        set(gca, 'YLimInclude', 'off');
        set(gca, 'YLimMode', 'manual')
    end
end

set(figureHandle, 'ToolBar', 'none');
%set(gca, 'XTick', iterations);