# MATLAB Data Processing Toolbox

## Introduction
This project is separated into two folders: **Examples** and **Subroutines**. The `.m` files in the **Examples** folder are scripts written using functions saved in the **Subroutines** folder. Because of the way MATLAB functions are preferably written, each file contains a single function. Example: a certain script might be used to load raw intensity and wavelength data from a spectrometer, use a subroutine to convert wavelength to wavenumbers with a user-input parameter, then use another subroutine to plot a intensity-wavenumber spectrum. Finally, it might then use a subroutine to export the figure in various formats.

## How to use
### Example scripts
Download the desired script(s) and place it in your MATLAB working directory (default: C:/Users/*<user>*/Documents/MATLAB). 

### Subroutines
Simply get the "Spectroelectrochemistry Data Processing Toolbox" add-on in MATLAB's Add-On Explorer, navigable from inside MATLAB ("HOME" > "Add-Ons", as of 2024a).

Alternatively, for a manual installation, download the necessary subroutines (or all of them, for simplicity) and place them in the working directory or in MATLAB's root folder. You can place the subroutines in a different folder to keep them organized. In that case, you must configure MATLAB to know where it should look for subroutines: goto Home > Set Path > Add Folder... select the desired folder and save.

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

The outputs of the scripts will usually be saved in the same path where the raw data is located. A copy of the original script and subroutines will be saved as well. 

### Main subroutines

- `readData`: reads raw data files at specified `path`. The user specifies the desired columns by their number, starting at 1. For example, `[X, Y, Z] = readData(filepath, 1, 3, 4)` would load the file at `filepath`, and assign the data in the first, third and fourth columns to the variables `X`, `Y` and `Z`, respectively. If `path` is a folder, a window will open prompting the user to select a file to be read.

- `createAnalysisFolder`: receives a `path` as input and creates a folder with the specified `name`. If the folder already exists, promps the user to overwrite or select a new name. If `name` is blank and `path` is the path to a file, the a folder with the name of the file + "_Analysis" is created.

- `saveFig`: used to export figure objects (`fig`) with a specified `name` and `path`, into raster (PNG) or vector (PDF) images (`format`). PDF images are especially useful as they can be edited in [Inkscape](https://inkscape.org/), Adobe Illustrator or any other vector graphics editors that loads PDFs. It is possible to export SVGs, but unfortunately MATLAB messes up fonts for some reason. PDFs and rasters are usually what-you-see-is-what-you-get. The `saveAllFigs` subroutine uses `saveFig` to save all current figures into files.

- `saveReport`: saves a text report at a specified `path`, containing info about the user, MATLAB version, date and data paths for traceability purposes. It also saves a copy of the script, appending the source code of all subroutines as well into a single file with the same name. This is particularly useful as you might do unwanted changes which might accumulate over time.

- `plotXY`: an encapsulation of MATLAB's native `plot` function, with the aim of reducing the amount of boilerplate code involved with changing the typefaces, font sizes, line widths, etc. Most arguments are well documented. It is possible to overlay plots using this function by passing the original `Axes` object as an optional argument (function overloading is not available in MATLAB). It is also possible to overlay data with two different y-axes using `plotXYY`.
