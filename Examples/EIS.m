% CV: Plot CVs from data files.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   20 Aug 2024
clear
close all
clc

%% Basic Parameters
% Experiment name (comment out or leave blank to use file name)
expName = '';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\Box\Johann Hemmer Data\ORR\2025\09262025\Potentiostatic EIS Plus2947 ch1 (2025-09-26 16_22_27)\Potentiostatic EIS 20250926 162232.csv"
};

bkgPath = {
};

% General
saveToAnalysisFolder = false;

% Experiment parameters
YScaleFactor = 1;

%% Read files
[f, Zreal, Zimag] = readDataPath(dataPath, 7, 10, 11); % Squidstat
% [f, Zreal, Zimag] = readDataPath(dataPath, 1, 2, 3);

f = f{1};
Zreal = Zreal{1};
Zimag = -Zimag{1}; % Squidstat
% Zimag = Zimag{1};

%% Process
Zexp = Zreal + 1i*Zimag; % check if your potentiostat outputs Z" or -Z"
omega = 2*pi*f;

Rs0 = min(real(Zexp));
Rct0 = max(real(Zexp)) - Rs0;
Q0 = 1e-9; % CPE prefactor
n0 = 0.9; % CPE exponent
sigma0 = 0; % 
tau0 = 0; % 
L0 = 1e-7;
p0 = [Rs0, Rct0, Q0, n0, sigma0, tau0, L0];

opts = optimset('TolX',1e-9,'TolFun',1e-9,'Display','off');
p = fminsearch(@(p) sum(abs(Zexp - circuit(p, omega)).^2), p0, opts);

Rs = p(1);
Rct = p(2);
Q = p(3);
n = p(4);
sigma = p(5);
% tau = p(6);
L = p(6);

Zfit = circuit(p, omega);

function Z = circuit(p, omega)
% Randles circuit: Rs + parallel(Rct, CPE)
% Rand. + Warburg: Rs + parallel(  
    Rs = p(1);
    Rct = p(2);
    Q = p(3);
    n = p(4);
    sigma = p(5);
    % tau = p(6);
    L = p(6);

    ZL = 1i*omega*L; % lead inductance
    Zcpe = 1./(Q*(1i*omega).^n); % CPE impedance
    Zw = sigma ./ sqrt(1i*omega); % Infinite Warburg
    % Zw = sigma * tanh(sqrt(1i*omega*tau)) ./ sqrt(1i*omega*tau); % Finite Warburg
    Zpar = 1./(1./(Rct + Zw) + 1./Zcpe); % (Rct + W) || CPE

    Z = Rs + ZL + Zpar; % total impedance
end

%% Plot
if isempty(expName)
    figName = 'EIS';
else
    figName = expName;
end

colors = {
    SpecTbx.Colors.IsothermalBlues{3}; SpecTbx.Colors.IsothermalBlues{1}
    };

[fig, ax] = plotXY({real(Zexp); real(Zfit)}, {-imag(Zexp); -imag(Zfit)}, ...
    'XLabel', '{\itZ''} (\Omega)', ...
    'YLabel', '−{\itZ''''} (\Omega)', ...
    'XLim', [], ...
    'YLim', [], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'Color', colors, ...
    'LineStyle', {'-', '--'}, ...
    'Marker', {'o'; 'none'}, ...
    'YScaleFactor', YScaleFactor, ...
    'AxisMargins', 'padded', ...
    'FigureName', append(figName, '_-nyquist'));

legend(ax, ...
    {'Experiment'; 'Fit'}, ...
    'Location', 'best')

[fig2, ax2] = plotXY(f, {abs(Zexp); abs(Zfit)}, ...
    'XLabel', 'Frequency (Hz)', ...
    'YLabel', '|{\itZ}| (\Omega)', ...
    'XLim', [], ...
    'YLim', [], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'Color', colors, ...
    'LineStyle', {'-', '--'}, ...
    'Marker', {'o'; 'none'}, ...
    'AxisMargins', 'padded', ...
    'YScaleFactor', YScaleFactor, ...
    'FigureName', append(figName, '_bodemagnitude'));

ax2.XScale = "log";
ax2.YScale = "log";
ax2.XTick = [1e0 1e1 1e2 1e3 1e4 1e5 1e6];

legend(ax2, ...
    {'Experiment'; 'Fit'}, ...
    'Location', 'best')

[fig3, ax3] = plotXY(f, {angle(Zexp)*180/pi; angle(Zfit)*180/pi}, ...
    'XLabel', 'Frequency (Hz)', ...
    'YLabel', 'Phase (°)', ...
    'XLim', [], ...
    'YLim', [], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'Color', colors, ...
    'LineStyle', {'-', '--'}, ...
    'Marker', {'o'; 'none'}, ...
    'AxisMargins', 'padded', ...
    'YScaleFactor', YScaleFactor, ...
    'FigureName', append(figName, '_bodephase'));

ax3.XScale = "log";
ax3.XTick = [1e0 1e1 1e2 1e3 1e4 1e5 1e6];

legend(ax3, ...
    {'Experiment'; 'Fit'}, ...
    'Location', 'best')

tiledfig = figure('Theme', 'light', 'Name', 'full_bodeplot', 'WindowStyle', 'normal');
t = tiledlayout(tiledfig, 1, 2);
cax2 = copyobj(ax2, t);
cax2.Layout.Tile = 1;
cax3 = copyobj(ax3, t);
cax3.Layout.Tile = 2;


%% Save
if saveToAnalysisFolder == true
    % Creating folder to save analysis
    savePath = createAnalysisFolder(dataPath{1}, expName);

    % Copy files
    copyFile(savePath, dataPath)
else
    savePath = fileparts(dataPath{1});
end

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Save data
saveTable(Rs, Rct, Q, n, sigma, L, ...
    FileName='circuit', ...
    SavePath=savePath, ...
    VariableNames={'Rs'; 'Rct'; 'Cdl'; 'n'; 'sigma'; 'L'});

