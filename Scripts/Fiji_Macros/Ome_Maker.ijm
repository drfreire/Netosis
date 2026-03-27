// Prompt user to select the directory where images are located
dir = getDirectory("Select folder containing channel images");

// Get list of all files in the directory
fileList = getFileList(dir);

// Initialize variables to store found files
ch1File = "";
ch2File = "";
ch3File = "";
ch4File = "";

// Search for files containing the channel patterns
for (i = 0; i < fileList.length; i++) {
    fileName = fileList[i];
    
    if (indexOf(fileName, "_Ch1_") >= 0) {
        ch1File = fileName;
    }
    if (indexOf(fileName, "_Ch2_") >= 0) {
        ch2File = fileName;
    }
    if (indexOf(fileName, "_Ch3_") >= 0) {
        ch3File = fileName;
    }
    if (indexOf(fileName, "_Ch4_") >= 0) {
        ch4File = fileName;
    }
}

// Check if all required files were found
if (ch1File == "" || ch2File == "" || ch3File == "" || ch4File == "") {
    print("Error: Could not find all required channel files");
    print("Ch1 file: " + ch1File);
    print("Ch2 file: " + ch2File);
    print("Ch3 file: " + ch3File);
    print("Ch4 file: " + ch4File);
    exit();
}

// Open the files
open(dir + ch1File);
open(dir + ch2File);
open(dir + ch3File);
open(dir + ch4File);

// Print what files were found for confirmation
print("Using files:");
print("Ch1: " + ch1File);
print("Ch2: " + ch2File);
print("Ch3: " + ch3File);
print("Ch4: " + ch4File);

// Merge channels according to the specified mapping:
// Ch3 -> C1 (red), Ch2 -> C2 (green), Ch4 -> C3 (blue), Ch1 -> C4 (gray)
run("Merge Channels...", "c1=" + ch3File + " c2=" + ch2File + " c3=" + ch4File + " c4=" + ch1File + " create keep ignore");

// Extract well position from filename (e.g., "Well_A1_" from any channel file)
wellPattern = "";
baseName = ch2File; // Use Ch2 file as base for extracting well pattern

// Find the well pattern in the filename
startIndex = indexOf(baseName, "Well_");
if (startIndex >= 0) {
    // Extract everything from "Well_" to the next "_" after the well position
    wellPart = substring(baseName, startIndex);
    endIndex = indexOf(wellPart, "_", 5); // Start looking after "Well_"
    if (endIndex >= 0) {
        endIndex = indexOf(wellPart, "_", endIndex + 1); // Find the second "_" to get "Well_A1_"
        if (endIndex >= 0) {
            wellPattern = substring(wellPart, 0, endIndex + 1); // Include the trailing "_"
        }
    }
}

// Generate output filename
if (wellPattern != "") {
    outputName = wellPattern + "Composite.ome.tiff";
} else {
    // Fallback if well pattern not found - use base filename
    outputName = replace(baseName, "_Ch2_", "_Composite.");
    outputName = replace(outputName, ".tif", ".ome.tiff");
    outputName = replace(outputName, ".tiff", ".ome.tiff");
}

// Save using Bio-Formats Exporter
run("Bio-Formats Exporter", "save=[" + dir + outputName + "] export compression=Uncompressed");

print("Saved merged image as: " + outputName);

// Close all images except the current composite
// Store the title of the composite image
compositeTitle = getTitle();

// Get list of all open image windows
imageList = getList("image.titles");

// Close all images except the composite
for (i = 0; i < imageList.length; i++) {
    if (imageList[i] != compositeTitle) {
        selectWindow(imageList[i]);
        close();
    }
}

// Make sure the composite is selected
selectWindow(compositeTitle);

run("Close All");