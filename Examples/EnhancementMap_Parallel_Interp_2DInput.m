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

%% Parameters

% Path to data
expName = 'Enhancement map parallel';

dataPath = "C:\Users\jhemmer\Box\Johann Hemmer Data\Plasmon-induced migration (Amin 3rd project)\COMSOL\09 Sep\09182025\E-field Map parallel wl=532 I0=2.38.txt";

wl = 532;
I0 = 2.38;

% E0 = 2195.9; % For 0.64 W/cm^2
% E0 = 2689.5; % For 0.96 W/cm^2
% E0 = 3093.4; % For 1.27 W/cm^2
% E0 = 3461.2; % For 1.59 W/cm^2
E0 = 4234.7; % For 2.38 W/cm^2

% Plotting parameters
AspectRatio = 1.2;
xRange = [-200 200];
yRange = [-200 200]/AspectRatio;
overwriteFile = true;

surfPos = [0 0];

xTicks = [];
yTicks = [];
% cTicks = [25 27 29 31 33 35];

xLabel = '{\itx} (nm)';
yLabel = '{\ity} (nm)';
cLabel = '(|{\bfE}|/{\itE}_0)^2'; % Colorbar label

%% Process
data = readmatrix(dataPath{1});
x = data(:,2);
y = data(:,3);
E = data(:,4);

% Convert E-field to enhancement
E = (E./E0).^2;

% Display data range
disp(append('Full range x: ', num2str(min(x)), ' to ', num2str(max(x))))
disp(append('Full range y: ', num2str(min(y)), ' to ', num2str(max(y))))

% Interpolate field magnitude for heatmap
u_lin = linspace(xRange(1), xRange(2), 500);
v_lin = linspace(yRange(1), yRange(2), 500);
[U, V] = meshgrid(u_lin, v_lin);
Fmag = scatteredInterpolant(x, y, E, 'natural', 'none');
EGrid = Fmag(U, V);

%% Plot
fig = figure(Theme='light', Units='inches');

imagesc(u_lin, v_lin, EGrid);

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
clim([1 16]);

set(ax, FontSize=18, LineWidth=2, Units='inches', Box='on', Layer='top', YDir='normal')
grid off

% Adjust size
PlotWidth = 5;
PlotHeight = PlotWidth / AspectRatio;
ax.Position([3 4]) = [PlotWidth PlotHeight];
fig.Position([3 4]) = ax.OuterPosition([3 4]);
ax.OuterPosition(1) = ax.OuterPosition(1) + ax.TickLength(1);
fig.Position(3) = fig.Position(3) + c.Label.Extent(3);

% annotation(fig,'textbox',...
%     [0.184476581952313 0.160600445087139 0.252544024249423 0.141405561159923],...
%     'VerticalAlignment','cap',...
%     'String',{append('{\it\lambda} = ',num2str(wl,3),' nm'), append('{\itI}_0 = ', num2str(I0,3),' W/cm^2')},...
%     'LineWidth',2,...
%     'FontSize',18,...
%     'FitBoxToText','off',...
%     'BackgroundColor',[1 1 1]);

expName = append(expName, ' wl=', num2str(wl,3), ' I0=', num2str(I0,3));

%% Save
savePath = createAnalysisFolder(dataPath{1}, expName, 'Overwrite', overwriteFile);
saveAllFigs(savePath, 'fig', 'png', 'pdf')
saveReport(savePath)
copyFile(savePath, dataPath)
