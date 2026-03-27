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
totalFilesProcessed = 0;

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
    
    // If directory exists and has files
    if (wellFileList.length > 0) {
        print("Found well directory: " + wellName);
        
        // Initialize array to store found channel files
        channelFiles = newArray();
        
        // Search for files containing the channel patterns
        for (i = 0; i < wellFileList.length; i++) {
            fileName = wellFileList[i];
            
            // Check if file matches any channel pattern
            if (indexOf(fileName, "_Ch1_") >= 0 || 
                indexOf(fileName, "_Ch2_") >= 0 || 
                indexOf(fileName, "_Ch3_") >= 0 || 
                indexOf(fileName, "_Ch4_") >= 0) {
                channelFiles = Array.concat(channelFiles, fileName);
            }
        }
        
        // Check if any matching files were found
        if (channelFiles.length == 0) {
            print("Warning: No channel files found in " + wellName);
            skippedCount++;
        } else {
            print("  Found " + channelFiles.length + " channel file(s) to process");
            
            // Process each found channel file
            for (ch = 0; ch < channelFiles.length; ch++) {
                open(wellDirPath + channelFiles[ch]);
                
                // Crop
                makeRectangle(136, 900, 5392, 4100);
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
                
                totalFilesProcessed++;
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
print("Total files processed: " + totalFilesProcessed);
print("===================================");