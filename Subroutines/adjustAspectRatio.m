function adjustAspectRatio(fig, plotWidth, aspectRatio, options)
% Not tested for figures that contain multiple axes.

arguments
    fig 
    plotWidth 
    aspectRatio 
    options.Units = 'inches'
end

fig.Units = options.Units;

ax = findall(fig, 'Type', 'axes');
ax.Units = options.Units;

plotHeight = plotWidth / aspectRatio;

ax.Position([3 4]) = [plotWidth plotHeight];

fig.Position([3 4]) = ax.OuterPosition([3 4]);

ax.OuterPosition(1) = ax.OuterPosition(1) + ax.TickLength(1);

end