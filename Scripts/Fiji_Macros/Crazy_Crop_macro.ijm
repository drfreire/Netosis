// === USER SETTINGS ===
inputImage = "path/to/your/microscopy_image.tif";
coordsFile = "path/to/crop_coordinates.csv";
cropSize = 20;
outputMontage = "cell_montage.tif";

// Open the image
open(inputImage);
imageID = getImageID();
getPixelSize(unit, pixelWidth, pixelHeight);

// Read coordinates
coordsString = File.openAsString(coordsFile);
lines = split(coordsString, "\n");

// Skip header, count valid lines
nCells = 0;
for (i = 1; i < lines.length; i++) {
    if (lengthOf(lines[i]) > 0) nCells++;
}

print("Processing " + nCells + " cells");

// Arrays to store coordinates
xCoords = newArray(nCells);
yCoords = newArray(nCells);

// Parse coordinates
index = 0;
for (i = 1; i < lines.length; i++) {
    if (lengthOf(lines[i]) > 0) {
        cols = split(lines[i], ",");
        xCoords[index] = parseInt(cols[0]);
        yCoords[index] = parseInt(cols[1]);
        index++;
    }
}

// Create crops
halfSize = cropSize / 2;
setBatchMode(true);

for (i = 0; i < nCells; i++) {
    selectImage(imageID);
    
    x = xCoords[i] - halfSize;
    y = yCoords[i] - halfSize;
    
    // Make rectangular selection and duplicate
    makeRectangle(x, y, cropSize, cropSize);
    run("Duplicate...", "title=crop_" + i);
    
    if (i % 100 == 0) print("Processed " + i + " / " + nCells);
}

// Create montage from all crops
run("Images to Stack", "name=CropStack title=crop_ use");
run("Make Montage...", "columns=20 rows=0 scale=1 border=1");
saveAs("Tiff", outputMontage);

setBatchMode(false);
print("Montage saved to: " + outputMontage);
print("Complete!");