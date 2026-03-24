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
            print("Ch1 file: " + ch1File);
            print("Ch2 file: " + ch2File);
            print("Ch3 file: " + ch3File);
            print("Ch4 file: " + ch4File);
            skippedCount++;
        } else {
            // Open the files
            open(wellDirPath + ch1File);
            open(wellDirPath + ch2File);
            open(wellDirPath + ch3File);
            open(wellDirPath + ch4File);
            
            // Print what files were found for confirmation
            print("Processing well: " + wellName);
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
                // Extract everything from "Well_" onwards
                wellPart = substring(baseName, startIndex);
                
                // Find the first "_" after "Well_" (this comes after the well position like A1, B2, etc.)
                endIndex = indexOf(wellPart, "_", 5); // Start looking after "Well_" (5 characters)
                
                if (endIndex >= 0) {
                    // Extract just "Well_A1_" part
                    wellPattern = substring(wellPart, 0, endIndex + 1); // Include the trailing "_"
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
            run("Bio-Formats Exporter", "save=[" + wellDirPath + outputName + "] export compression=Uncompressed");
            
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

print("Batch processing complete!");
print("Processed: " + processedCount + " wells");
print("Skipped: " + skippedCount + " wells");