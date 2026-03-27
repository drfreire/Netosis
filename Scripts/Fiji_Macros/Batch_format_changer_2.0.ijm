// ===== USER CONFIGURATION =====
inputFileType = ".tif";      // Input file extension to convert from
outputFileType = ".bmp";    // Output file extension to convert to
// ==============================

// Prompt user to select directory
dir = getDirectory("Select folder containing images");

// Get all items in the directory
itemList = getFileList(dir);

// Count files matching input type in the main directory
fileCount = 0;
for (i = 0; i < itemList.length; i++) {
    if (!endsWith(itemList[i], "/") && !endsWith(itemList[i], File.separator)) {
        if (endsWith(itemList[i], inputFileType)) {
            fileCount++;
        }
    }
}

print("File Type Converter");
print("Converting: " + inputFileType + " to " + outputFileType);
print("Selected directory: " + dir);
print("");

convertedCount = 0;

// If files found in main directory, process them
if (fileCount > 0) {
    print("Found " + fileCount + " files in main directory");
    
    for (i = 0; i < itemList.length; i++) {
        fileName = itemList[i];
        
        // Skip directories
        if (endsWith(fileName, "/") || endsWith(fileName, File.separator)) {
            continue;
        }
        
        // Process matching files
        if (endsWith(fileName, inputFileType)) {
            print("Converting: " + fileName);
            
            // Open the file
            open(dir + fileName);
            
            // Generate new filename
            newFileName = replace(fileName, inputFileType, outputFileType);
            
            // Save with new extension
            if (outputFileType == ".tif" || outputFileType == ".tiff") {
                saveAs("Tiff", dir + newFileName);
            } else if (outputFileType == ".png") {
                saveAs("PNG", dir + newFileName);
            } else if (outputFileType == ".jpg" || outputFileType == ".jpeg") {
                saveAs("Jpeg", dir + newFileName);
            } else if (outputFileType == ".bmp") {
                saveAs("BMP", dir + newFileName);
            } else {
                saveAs("Tiff", dir + newFileName);
            }
            
            close();
            
            // Delete original file
            File.delete(dir + fileName);
            
            convertedCount++;
        }
    }
} else {
    // No files in main directory, process subfolders
    print("No matching files in main directory, checking subfolders...");
    print("");
    
    for (i = 0; i < itemList.length; i++) {
        itemName = itemList[i];
        
        // Check if this is a directory
        if (endsWith(itemName, "/") || endsWith(itemName, File.separator)) {
            subDir = dir + itemName;
            subFiles = getFileList(subDir);
            
            subfoldersProcessed = 0;
            
            for (j = 0; j < subFiles.length; j++) {
                fileName = subFiles[j];
                
                // Skip subdirectories
                if (endsWith(fileName, "/") || endsWith(fileName, File.separator)) {
                    continue;
                }
                
                // Process matching files
                if (endsWith(fileName, inputFileType)) {
                    if (subfoldersProcessed == 0) {
                        print("Processing subfolder: " + itemName);
                    }
                    
                    print("  Converting: " + fileName);
                    
                    // Open the file
                    open(subDir + fileName);
                    
                    // Generate new filename
                    newFileName = replace(fileName, inputFileType, outputFileType);
                    
                    // Save with new extension
                    if (outputFileType == ".tif" || outputFileType == ".tiff") {
                        saveAs("Tiff", subDir + newFileName);
                    } else if (outputFileType == ".png") {
                        saveAs("PNG", subDir + newFileName);
                    } else if (outputFileType == ".jpg" || outputFileType == ".jpeg") {
                        saveAs("Jpeg", subDir + newFileName);
                    } else if (outputFileType == ".bmp") {
                        saveAs("BMP", subDir + newFileName);
                    } else {
                        saveAs("Tiff", subDir + newFileName);
                    }
                    
                    close();
                    
                    // Delete original file
                    File.delete(subDir + fileName);
                    
                    convertedCount++;
                    subfoldersProcessed++;
                }
            }
        }
    }
}

print("");
print("Conversion complete!");
print("Total files converted: " + convertedCount);