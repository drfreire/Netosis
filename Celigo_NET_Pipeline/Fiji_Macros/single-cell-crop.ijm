// Conversion factor - change this when you know the actual scale
// Set to 1 for pixels, or actual value like 0.5 for micrometers per pixel
pixelsPerMicron = 1; // Change this value when you know the conversion
scaleBarLength = 10; // Length in current units (pixels or micrometers)

makeRectangle(1922, 2670, 28, 28);
waitForUser("Position the crop,");

// Get the rectangle coordinates
getSelectionBounds(x, y, width, height);

run("Crop");

// Add scale bar to the entire cropped stack
run("Set Scale...", "distance=" + pixelsPerMicron + " known=1 pixel=1 unit=um");
run("Scale Bar...", "width=" + scaleBarLength + " height=2 font=2 color=White background=Black location=[Lower Right] hide overlay");

// Store the original image title after scale bar is added
originalTitle = getTitle(); 
dir = "/Users/brett/Documents/Cropped/"; 
crop = "_croppedBig.BMP";

// Store the original image title
originalTitle = getTitle();

// Get number of slices in the stack
numSlices = nSlices;

// Save each slice separately using existing slice names
//for (i = 1; i <= numSlices; i++) {
  //  selectWindow(originalTitle);
    //setSlice(i);
    //sliceName = getInfo("slice.label");
    
    // Debug: print what we're getting
    //print("Slice " + i + " label: " + sliceName);
    
    // If no slice label, use slice number
    //if (sliceName == "" || sliceName == "null") {
      //  sliceName = "slice_" + IJ.pad(i, 3);
    //}
    
    // Remove file extension from slice name if present
    //dotIndex = lastIndexOf(sliceName, ".");
    //if (dotIndex > 0) {
      //  nameOnly = substring(sliceName, 0, dotIndex);
    //} else {
      //  nameOnly = sliceName;
    }
    
  //  fullpath = dir + nameOnly + crop;
   // print("Saving: " + fullpath);
    
    // Save just the current slice
   // selectWindow(originalTitle);
    //setSlice(i);
    //run("Duplicate...", "title=temp");
    //selectWindow("temp");
    //run("Flatten");
    // Flatten creates a new window, select it
    //selectWindow("temp-1");
    //saveAs("BMP", fullpath);
    //close();
    // Also close the original temp window
    //selectWindow("temp");
    //close();
    
//}
//run("Close All");