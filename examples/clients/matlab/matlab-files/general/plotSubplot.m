%% Function Plot subplot
%
% Denis Štogl 2012 IIROB group IPR/KIT
% http://rob.ipr.kit.edu/english/303.php
%
% Definition: figureHandle = plotSubplot(data, titleText, legendText, xlabelText, ylabelText, xlimValues, ylimValues, figureNumber)
%
% This function split figure in size(data, 3) subplots and in every
% subplot are ploted data itereting on third dimension of data matrix. In
% first two dimensionsion are data, so that in first colum is time folowed
% by correspondig data. Different colors for every plot on the same
% subfigure are used.
%
% Every call creates njew figure.
%
% Input:
%       data - 3D-matrix with data. In first two dimenstion are placed data
%              columnwise. Third dimenosion stand for new subplot.
%       titleText - Title of the figure
%       xlabelText - label on x-Axis (usualy time)
%       ylableText - label on y-Axes. Every subplot has own label.
%                    (cell-object with strings)
%
%       xlimValues - limit x-Axis on area [xMin xMax] (optional)
%       ylimValues - limit y-Axis on area [yMin yMax] (optional)
%       figureNumber - parametar used for choosing active figure (optional)
%
% Output:
%       figureHandle - handle for current figure (optional)

function [figureHandle, plotHandles] = plotSubplot(data, titleText, legendText, xlabelText, ylabelText, xlimValues, ylimValues, figureNumber)

if nargin == 8
    figureHandle = figure(figureNumber);
else
    figureHandle = figure;
end
title(titleText);
listOfColors = {'r', 'b', 'g', 'm', 'c', 'k', 'y'};

plotHandles = zeros(size(data(:, :, 1), 2)/2, size(data, 3));
for i = 1:size(data, 3)
    
    subplot(size(data, 3), 1, i);
    hold on;
    
    for j = 1:2:size(data(:, :, i), 2);
        
        plotHandles(ceil(j/2), i) = plot(data(:, j, i), data(:, j+1, i), listOfColors{mod (floor(j/2), size(listOfColors, 2))+1});
    end
    
    ylabel(ylabelText{i});
    xlabel(xlabelText);
    grid on;
    legend(legendText{i, :});
    if nargin >= 6
        xlim(xlimValues);
    end
    if nargin >= 7
        ylim(ylimValues(i, :));
    end    
end