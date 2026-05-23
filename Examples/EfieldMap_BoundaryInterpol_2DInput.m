% Plot E-field or Enhancement from COMSOL simulated data. Input must be
% 2D data.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   18 Sep 2025
clear
close all

expName = 'E-field map wl=532 I0=2.38';

dataPath = {
"C:\Users\jhemmer\Box\Johann Hemmer Data\Plasmon-induced migration (Amin 3rd project)\COMSOL\09 Sep\09182025\E-field Map parallel wl=473 I0=2.38.txt"
};

% Plotting parameters
AspectRatio = 1.2;

% Parameters
xRange = [-200 200];
yRange = [-200 200]/AspectRatio;

surfPos = [0 0];

xTicks = [];
yTicks = [];
% cTicks = [25 27 29 31 33 35];

xLabel = '{\itz} (nm)';
yLabel = '{\ity} (nm)';
cLabel = '|{\bfE}| (V/m)'; % Colorbar label

% Read data
data = readmatrix(dataPath{1});
x = data(:,2);
y = data(:,3);
E = data(:,4);

% Display data range
disp(append('Full range x: ', num2str(min(x)), ' to ', num2str(max(x))))
disp(append('Full range y: ', num2str(min(y)), ' to ', num2str(max(y))))

xc = 0; yc = 0;           % center (nm)
rp = 100;                  % radius (nm)
buffer = 0.5;             % small safety band (nm) to avoid gaps at boundary

% classify your raw points
r2 = (x - xc).^2 + (y - yc).^2;
inside_pt  = r2 <= (rp - buffer).^2;
outside_pt = r2 >= (rp + buffer).^2;

% build two interpolants (no extrapolation)
F_out = scatteredInterpolant(x(outside_pt), y(outside_pt), E(outside_pt), 'natural', 'none');
F_in  = scatteredInterpolant(x(inside_pt),  y(inside_pt),  E(inside_pt),  'natural', 'none');

% regular grid as before
u_lin = linspace(xRange(1), xRange(2), 1000);
v_lin = linspace(yRange(1), yRange(2), 1000);
[U, V] = meshgrid(u_lin, v_lin);

% region masks on the grid
rgrid2 = (U - xc).^2 + (V - yc).^2;
in_mask  = rgrid2 <= rp^2;
out_mask = rgrid2 >  rp^2;

% evaluate each interpolant on its own side
E_out = F_out(U, V);
E_in  = F_in(U, V);

% stitch: use outside values outside, inside values inside
EGrid = nan(size(U));
EGrid(out_mask) = E_out(out_mask);
EGrid(in_mask)  = E_in(in_mask);

% optional: fill the thin buffer band with nearest neighbor to avoid a visible seam
if buffer > 0
    Fblend = scatteredInterpolant(x, y, E, 'nearest', 'nearest');
    band = ~in_mask & ~out_mask;   % the thin band between (rp-buffer) and (rp+buffer)
    EGrid(band) = Fblend(U(band), V(band));
end

imagesc(u_lin, v_lin, EGrid); set(gca,'YDir','normal'); axis image tight;

ax = gca;
ax.XLim = xRange;
ax.YLim = yRange;

if ~isempty(xTicks), ax.XTick = xTicks; end
if ~isempty(yTicks), ax.YTick = yTicks; end

colormap("nebula")
c = colorbar;

xlabel(xLabel, FontSize=20, FontName='Arial');
ylabel(yLabel, FontSize=20, FontName='Arial');

% ax.XTickLabel = ax.XTick - surfPos(1);
ax.YTickLabel = ax.YTick - surfPos(2);

c.Label.String = cLabel;
c.Units = 'inches';
c.FontName = 'Arial';
c.FontSize = 18;
c.Label.FontName = 'Arial';
c.Label.FontSize = 20;
c.LineWidth = 2;

set(ax, FontSize=18, LineWidth=2, Units='inches', Box='on', Layer='top', YDir='normal')
grid off

% Adjust size
PlotWidth = 5;
PlotHeight = PlotWidth / AspectRatio;
ax.Position([3 4]) = [PlotWidth PlotHeight];
fig.Position([3 4]) = ax.OuterPosition([3 4]);
ax.OuterPosition(1) = ax.OuterPosition(1) + ax.TickLength(1);
fig.Position(3) = fig.Position(3) + c.Label.Extent(3);

% Save everything
savePath = createAnalysisFolder(dataPath{1}, expName);
saveAllFigs(savePath, 'fig', 'png', 'pdf')
saveReport(savePath)
copyFile(savePath, dataPath)
