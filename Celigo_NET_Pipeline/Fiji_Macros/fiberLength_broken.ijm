// ===== USER CONFIGURATION =====
// Adjust these parameters based on your images
minFiberLength = 10;        // Minimum fiber length to include (pixels)
maxFiberLength = 5000;     // Maximum fiber length to include (pixels)
rollingBallRadius = 20;     // Background subtraction radius (try 30-100)
gaussianSigma = 2;          // Gaussian blur sigma for noise reduction
thresholdMethod = "Huang";     // Threshold method: "Li", "Otsu", "Yen", "Triangle", "Minimum", "Huang"
showIntermediateSteps = true; // Set to true to see each processing step
maskErosionIterations = 30; // How many pixels to shrink the mask inward (increase to remove more border)

// Cleanup options (set to false to disable problematic steps)
useDespeckle = true;        // Remove salt-and-pepper noise
useRemoveOutliers = true;   // Remove isolated bright pixels
useFillHoles = false;       // Fill holes in fibers (WARNING: may fill spaces between fibers)
useClosing = false;         // Connect nearby fiber segments (may merge separate fibers)
closingIterations = 1;      // How many times to apply closing
// ==============================

// Check if an image is open
if (nImages == 0) {
    exit("Please open an image first.");
}

// Get original image info
originalTitle = getTitle();
originalID = getImageID();
imgDir = getInfo("image.directory");
if (imgDir == "") {
    imgDir = getDirectory("Choose directory to save results");
}

print("\\Clear");
print("=== Automated Fiber Length Measurement ===");
print("Image: " + originalTitle);
print("Settings:");
print("  Rolling ball radius: " + rollingBallRadius);
print("  Gaussian blur sigma: " + gaussianSigma);
print("  Threshold method: " + thresholdMethod);
print("  Length range: " + minFiberLength + " - " + maxFiberLength + " pixels");
print("");

// Duplicate image for processing
run("Duplicate...", "title=processing");
processingID = getImageID();

// Convert to 8-bit if needed
if (bitDepth() != 8) {
    run("8-bit");
}

// Create mask to remove scope background (black border)
print("Creating field of view mask...");
run("Duplicate...", "title=mask_temp");
setAutoThreshold("Default dark");
setOption("BlackBackground", true);
run("Convert to Mask");
//run("Invert");
// Fill holes to get solid circular mask
run("Fill Holes");

// Erode to shrink mask inward and avoid border artifacts
for (i = 0; i < maskErosionIterations; i++) {
    run("Erode");
}

run("Create Selection");

// Apply mask to processing image
selectImage(processingID);
run("Restore Selection");
run("Clear Outside");
run("Select None");

// Close mask temp
selectWindow("mask_temp");
close();

print("  Field of view mask applied (eroded " + maskErosionIterations + " pixels)");
print("");

// Preprocessing steps
print("Preprocessing...");

// 1. Background subtraction to handle uneven illumination
print("  Subtracting background...");
run("Subtract Background...", "rolling=" + rollingBallRadius);
if (showIntermediateSteps) {
    run("Duplicate...", "title=1_AfterBackgroundSubtraction");
}

// 2. Enhance contrast
print("  Enhancing contrast...");
selectImage(processingID);
run("Enhance Contrast...", "saturated=0.3 normalize");
if (showIntermediateSteps) {
    run("Duplicate...", "title=2_AfterContrastEnhance");
}

// 3. Gaussian blur to reduce noise
print("  Applying Gaussian blur...");
selectImage(processingID);
run("Gaussian Blur...", "sigma=" + gaussianSigma);
if (showIntermediateSteps) {
    run("Duplicate...", "title=3_AfterGaussianBlur");
}

// Optional: Try Tubeness filter for fiber-like structures
// Uncomment if fibers are very faint or need enhancement
// print("  Applying Tubeness filter...");
// run("Tubeness", "sigma=2.0");

// 4. Auto-threshold
print("  Applying threshold (" + thresholdMethod + ")...");
selectImage(processingID);

// Invert image so fibers are BRIGHT on DARK background (better for thresholding)
run("Invert");

setAutoThreshold(thresholdMethod + " dark");
if (showIntermediateSteps) {
    run("Duplicate...", "title=4_BeforeConvertToMask");
}
selectImage(processingID);
run("Convert to Mask");
if (showIntermediateSteps) {
    run("Duplicate...", "title=5_AfterThreshold");
}

// 5. Clean up noise
print("  Cleaning up mask...");
selectImage(processingID);

if (useDespeckle) {
    run("Despeckle");
    print("    Applied: Despeckle");
}

if (useRemoveOutliers) {
    run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
    print("    Applied: Remove Outliers");
}

if (useFillHoles) {
    run("Fill Holes");
    print("    Applied: Fill Holes");
}

if (useClosing) {
    for (i = 0; i < closingIterations; i++) {
        run("Close-");
    }
    print("    Applied: Closing (" + closingIterations + " iterations)");
}

if (showIntermediateSteps) {
    run("Duplicate...", "title=6_AfterCleanup");
}

// 6. Skeletonize to get centerlines
print("  Skeletonizing fibers...");
selectImage(processingID);
run("Skeletonize");
if (showIntermediateSteps) {
    run("Duplicate...", "title=7_AfterSkeletonize");
    waitForUser("Review intermediate steps", "Check the intermediate images to see where detection fails.\nClick OK to continue with analysis.");
}

// 7. Analyze skeleton
print("  Analyzing skeleton...");
run("Analyze Skeleton (2D/3D)", "prune=none show");

// Get results from skeleton analysis
selectWindow("Branch information");
branchCount = Table.size;

// Create summary table
Table.create("Fiber_Lengths");
validFiberCount = 0;
totalLength = 0;

// Process branch information
for (i = 0; i < branchCount; i++) {
    branchLength = Table.get("Branch length", i, "Branch information");
    
    // Filter by length criteria
    if (branchLength >= minFiberLength && branchLength <= maxFiberLength) {
        Table.set("Fiber_ID", validFiberCount, "Fiber_" + (validFiberCount + 1), "Fiber_Lengths");
        Table.set("Length", validFiberCount, branchLength, "Fiber_Lengths");
        totalLength += branchLength;
        validFiberCount++;
    }
}

// Add summary statistics
Table.set("Fiber_ID", validFiberCount, "TOTAL", "Fiber_Lengths");
Table.set("Length", validFiberCount, totalLength, "Fiber_Lengths");
validFiberCount++;

if (totalLength > 0) {
    avgLength = totalLength / (validFiberCount - 1);
    Table.set("Fiber_ID", validFiberCount, "AVERAGE", "Fiber_Lengths");
    Table.set("Length", validFiberCount, avgLength, "Fiber_Lengths");
}

Table.update("Fiber_Lengths");

// Show results
selectWindow("Fiber_Lengths");
print("");
print("=== Results ===");
print("Total fibers detected: " + (validFiberCount - 1));
print("Total length: " + totalLength + " pixels");
if (totalLength > 0) {
    print("Average fiber length: " + avgLength + " pixels");
}

// Save results
savePath = imgDir + replace(originalTitle, ".tif", "") + "_fiber_lengths.csv";
savePath = replace(savePath, ".tiff", "");
savePath = replace(savePath, ".png", "");
savePath = replace(savePath, ".jpg", "");
selectWindow("Fiber_Lengths");
saveAs("Results", savePath);
print("Results saved to: " + savePath);

// Ask if user wants to keep processing images
selectImage(originalID);
selectImage(processingID);
rename("Processed_Skeleton");

// Optional: Create overlay on original
selectImage(originalID);
run("Duplicate...", "title=overlay");
run("RGB Color");
selectWindow("Processed_Skeleton");
run("Create Selection");
if (selectionType() != -1) {
    selectWindow("overlay");
    run("Restore Selection");
    setForegroundColor(255, 0, 0);
    run("Draw", "slice");
    run("Select None");
}

print("");
print("Processing complete!");
print("Review the 'Processed_Skeleton' and 'overlay' images to verify detection.");
print("");
print("To improve results, adjust parameters at top of macro:");