// Manual Curved Length Measurement Macro for Fiji
// Draw a freehand or segmented line on each object and press "m" to record

// Get the directory of the current image (if one is open)
if (nImages == 0) {
    saveDir = getDirectory("Choose directory to save results");
} else {
    imgPath = getInfo("image.directory");
    if (imgPath != "") {
        saveDir = imgPath;
    } else {
        saveDir = getDirectory("Choose directory to save results");
    }
}

// Set up measurement table
run("Set Measurements...", "length label redirect=None decimal=3");
setBatchMode(false);

Table.create("Lengths");
n = 0;

while (true) {
    waitForUser("Draw a line over the next object, then click OK.\nPress 'Cancel' when finished.");
    
    // Measure the current selection
    run("Measure");
    numResults = nResults();
    
    if (numResults == 0) {
        print("No measurement found — ending macro.");
        break;
    }
    
    // Get the most recent measurement
    len = getResult("Length", numResults-1);
    label = "Obj_" + (n+1);
    
    // Add to our custom table
    Table.set("Label", n, label, "Lengths");
    Table.set("Length", n, len, "Lengths");
    n++;
}
}

Table.show("Lengths");

// Save the results
selectWindow("Lengths");
saveAs("Results", saveDir + "curved_lengths.csv");

print("Measurement complete!");
print("Total objects measured: " + n);
print("Results saved to: " + saveDir + "curved_lengths.csv");