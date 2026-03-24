// Prompt user to select the parent directory containing well subfolders
parentDir = getDirectory("Select folder containing well subfolders");

// Get list of all items in the parent directory
itemList = getFileList(parentDir);

// Generate all possible well names (A1 to H12)
wellNames = newArray();
rows = newArray("A", "B", "C", "D", "E", "F", "G", "H");

for (r = 0; r < rows.length; r++) {
    for (c = 1; c <= 12; c++) {
        wellNames = Array.concat(wellNames, rows[r] + c);
    }
}

processedCount = 0;
skippedCount = 0;

print("Starting batch processing of well directories...");
print("Parent directory: " + parentDir);

// Check each possible well name
for (w = 0; w < wellNames.length; w++) {
    wellName = wellNames[w];
    wellDirPath = parentDir + wellName + File.separator;
    
    // Check if this well directory exists by trying to get its file list
    fileList = getFileList(wellDirPath);
    
    // If we got a file list (even if empty), the directory exists
    if (fileList.length >= 0) {
        print("Found well directory: " + wellName);
// Initialize variables to store found files
ch2File = "";
ch3File = "";
ch4File = "";

// Search for files containing the channel patterns
for (i = 0; i < fileList.length; i++) {
    fileName = fileList[i];
    
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
if (ch2File == "" || ch3File == "" || ch4File == "") {
    print("Error: Could not find all required channel files");
    print("Ch2 file: " + ch2File);
    print("Ch3 file: " + ch3File);
    print("Ch4 file: " + ch4File);
     skippedCount++;
 } else {
            // Open the files
            open(wellDirPath + ch2File);
            open(wellDirPath + ch3File);
            open(wellDirPath + ch4File);
            
            // Print what files were found for confirmation
            print("Processing well: " + wellName);
            print("Using files:");
            print("Ch2: " + ch2File);
            print("Ch3: " + ch3File);
            print("Ch4: " + ch4File);

// Merge channels
run("Merge Channels...", "c1=" + ch3File + " c2=" + ch2File + " c3=" + ch4File + " create keep ignore");
run("Stack to RGB");

// Generate output filename by replacing _Ch#_ with _Ch0_
// Use the Ch2 file as the base name (could use any of the three)
outputName = replace(ch2File, "_Ch2_", "_Ch0_");

// Save the merged image
saveAs("BMP", wellDirPath + outputName);

print("Saved merged image as: " + outputName);

// Close all images
            while (nImages > 0) {
                selectImage(nImages);
                close();
            }
            
            processedCount++;
            print("Successfully processed " + wellName);
    }
}
}
