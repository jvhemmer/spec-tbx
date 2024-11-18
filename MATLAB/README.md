# MATLAB Data Processing Toolbox

## Introduction
This project is separated into two folders: **Scripts** and **Subroutines**. The `.m` files in the **Scripts** folder are scripts written using functions saved in the **Subroutines** folder. Because of the way MATLAB functions are preferably written, each file contains a single function. Example: a certain script might be used to load raw intensity and wavelength data from a spectrometer, use a subroutine to convert wavelength to wavenumbers with a user-input parameter, then use another subroutine to plot a intensity-wavenumber spectrum. Finally, it might then use a subroutine to export the figure in various formats.

## How to use
### Installation
Download the desired script(s) and place it in your MATLAB working directory (default: C:/Users/*<user>*/Documents/MATLAB). Download the necessary subroutines (or all of them, for simplicity) and place them in the working directory or in MATLAB's root folder. You can place the subroutines in a different folder to keep them organized. In that case, you must configure MATLAB to know where it should look for subroutines: goto Home > Set Path > Add Folder... select the desired folder and save.

### General use
Almost all scripts are well documented. I've tried to make the variable names as descriptive as possible without exaggerating on the name lengths. Overall, since most scripts use raw data as input, the first input you'll have to provide is a path of the file you want to load. This is done using MATLAB's cell variable type. On Windows, simply navigate to your file on Explorer, right-click the file and select "Copy Path". Go to the script and paste it in "DataPath" or a similar variable. These are all acceptable syntaxes for these scripts:

```
% Single line
dataPath = {"C:/Users/user/Data/spectrum1.txt"};

% Multiple lines, single path
dataPath = {
"C:/Users/user/Data/spectrum1.txt"
};

% Single line, multiple paths
dataPath = {"C:/Users/user/Data/spectrum1.txt"; "C:/Users/user/Data/spectrum2.txt"; "C:/Users/user/Data/spectrum3.txt"};

% Multiple lines, multiple paths
dataPath = {
"C:/Users/user/Data/spectrum1.txt"
"C:/Users/user/Data/spectrum2.txt"
"C:/Users/user/Data/spectrum3.txt"
};
```

In the last example, since we are using a cell array, most scripts iterate over the inputs and either overlay the plots, or plot and save the data individually. It depends on the script and you might have to play around with the loops to do it in the way you expect.

The outputs of the scripts will usually be saved in the same path where the raw data is using the `createAnalysisFolder`. If `expName` is specified, a folder with that name is created, otherwise the new folder is name after the first raw data file plus "_Analysis".

The `saveFig` and `saveAllFigs` are used to export figure objects into raster (PNG) or vector (PDF) images. PDF images are especially useful as they can be edited in [Inkscape](https://inkscape.org/), Adobe Illustrator or any other vector graphics editors that loads PDFs. It is possible to export SVGs, but unfortunately MATLAB messes up fonts for some reason. PDFs and rasters are usually what-you-see-is-what-you-get.

The `saveReport` subroutine save a text report containing info about the user, MATLAB version, date and data paths for traceability purposes. It also saves a copy of the script, appending the source code of all subroutines as well into a single file with the same name. This is particularly useful as you might do unwanted changes which might accumulate over time.

The `plotXY` subroutine is an encapsulation of MATLAB's native `plot` function, with the aim of reducing the amount of boilerplate code involved with changing the typefaces, font sizes, line widths, etc. Most arguments are well documented. It is possible to overlay plots using this function by passing the original `Axes` object as an optional argument (function overloading is not available in MATLAB). It is also possible to overlay data with two different y-axes.
