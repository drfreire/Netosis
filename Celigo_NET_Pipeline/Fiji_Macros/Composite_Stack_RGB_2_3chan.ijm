// Prompt user to select the directory where images are located
dir = getDirectory("Select folder containing channel images");

// Get list of all files in the directory
fileList = getFileList(dir);

// Initialize variables to store found files
ch2File = "";
ch3File = "";

// Search for files containing the channel patterns
for (i = 0; i < fileList.length; i++) {
    fileName = fileList[i];
    
    if (indexOf(fileName, "_Ch2_") >= 0) {
        ch2File = fileName;
    }
    if (indexOf(fileName, "_Ch3_") >= 0) {
        ch3File = fileName;
    }
}

// Check if all required files were found
if (ch2File == "" || ch3File == "" ) {
    print("Error: Could not find all required channel files");
    print("Ch2 file: " + ch2File);
    print("Ch3 file: " + ch3File);
    exit();
}

// Open the files
open(dir + ch2File);
open(dir + ch3File);

// Print what files were found for confirmation
print("Using files:");
print("Ch2: " + ch2File);
print("Ch3: " + ch3File);


// Merge channels
run("Merge Channels...", "c1=" + ch3File + " c2=" + ch2File + " create keep ignore");
run("Stack to RGB");

// Generate output filename by replacing _Ch#_ with _Ch0_
// Use the Ch2 file as the base name (could use any of the three)
outputName = replace(ch2File, "_Ch2_", "_Ch0_");

// Save the merged image
saveAs("TIF", dir + outputName);

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