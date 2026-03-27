// Define scale parameters
pixelsPerMicron = 1.0; // CHANGE THIS to your actual pixels per micron value
scaleBarLength = 2000; // Scale bar length in microns

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

// Output directory
outputDir = "/Users/brett/Documents/Cropped/";
File.makeDirectory(outputDir); // Create output directory if it doesn't exist

// Check each possible well name
for (w = 0; w < wellNames.length; w++) {
    wellName = wellNames[w];
    wellDirPath = parentDir + wellName + File.separator;
    
    // Check if this well directory exists by trying to get its file list
    if (!File.exists(wellDirPath)) {
        continue; // Skip if directory doesn't exist
    }
    
    wellFileList = getFileList(wellDirPath);
    
    // If we got a file list (even if empty), the directory exists
    if (wellFileList.length >= 0) {
        print("Found well directory: " + wellName);
        
        // Initialize variables to store found files
        ch1File = "";
        ch2File = "";
        ch3File = "";
        ch4File = "";
        
        // Search for files containing the channel patterns
        for (i = 0; i < wellFileList.length; i++) {
            fileName = wellFileList[i];
            
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
            print("Warning: Could not find all required channel files in " + wellName);
            print("  Ch1: " + ch1File);
            print("  Ch2: " + ch2File);
            print("  Ch3: " + ch3File);
            print("  Ch4: " + ch4File);
            skippedCount++;
        } else {
            // Process all 4 channels
            channelFiles = newArray(ch1File, ch2File, ch3File, ch4File);
            
            for (ch = 0; ch < channelFiles.length; ch++) {
                open(wellDirPath + channelFiles[ch]);
                
                // Crop
                makeRectangle(1160, 1850, 5392, 4100);
                run("Crop");
               
                // Set scale and add scale bar
                run("Set Scale...", "distance=" + pixelsPerMicron + " known=1 pixel=1 unit=um");
                run("Scale Bar...", "width=" + scaleBarLength + " height=100 thickness=30 font=80 color=White background=None location=[Lower Right] bold overlay");
                 
				
				run("Flatten");
                // Save with _cropped suffix
                originalTitle = getTitle();
                // Remove extension if present
                dotIndex = lastIndexOf(originalTitle, ".");
                if (dotIndex >= 0) {
                    baseName = substring(originalTitle, 0, dotIndex);
                } else {
                    baseName = originalTitle;
                }
                
                fullpath = outputDir + baseName + "_cropped.BMP";
                print("  Saving: " + fullpath);
                saveAs("BMP", fullpath);
                close();
                close();
            }
            
            processedCount++;
            print("Successfully processed well: " + wellName);
        }
    }
}

// Final summary
print("===================================");
print("Batch processing complete!");
print("Wells processed: " + processedCount);
print("Wells skipped: " + skippedCount);
print("===================================");