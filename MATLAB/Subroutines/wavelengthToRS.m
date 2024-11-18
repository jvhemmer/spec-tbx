function ramanShift = wavelengthToRS(wavelength, laserWavelength, options)
%wavelengthToRS: Convert wavelength to Raman shift.
%   Detailed explanation goes here

    arguments
        wavelength (1, :)
        laserWavelength (1,1)
        options.ConversionFactor = 1e7 % 1e7 is for nm-1 to cm-1
    end

    % Calculate wavenumber, in nm-1
    wavenumber = 1./wavelength;

    % Calculate wavenumber of the laser line, in nm-1
    laserWavenumber = 1/laserWavelength;

    % Calculate Raman Shift, in cm-1
    ramanShift = options.ConversionFactor * (laserWavenumber - wavenumber);

    ramanShift = ramanShift';
end