// Neuron arborisation growth tracer

// GUI's title
Dialog.createNonBlocking("Neuron arborisation growth tracer");
 
// Chose directory
Dialog.addDirectory("Select your directory ", "/");

Dialog.addNumber("Minimum threshold", 15);
Dialog.addNumber("# of despeckle", 0);
Dialog.addToSameRow()
Dialog.addNumber("# of dilation", 2);
Dialog.addNumber("Minimum size?", 2500);
Dialog.addToSameRow();
Dialog.addNumber("Max?", 20000000);
Dialog.addNumber("Save overlay every x frames?", 1);
 
Dialog.addCheckbox("See process?", false);

// Show GUI
Dialog.show();

// Execute the rest of the code when OK is pressed
// Set vars for inputs
masterDir = Dialog.getString();

minThreshold = Dialog.getNumber();
despeckleVal = Dialog.getNumber();
dilateVal = Dialog.getNumber();
minSizeInterval = Dialog.getNumber();
maxSizeInterval = Dialog.getNumber();

saveFrame = Dialog.getNumber();

seeProcess = Dialog.getCheckbox();

// Execute macro here
// Start timer
timeStart = getTime();

close("*");

// Show process if checked
if (seeProcess == 1) {} else {
	setBatchMode("hide");
}

input = masterDir + "/_images/"; 
list = getFileList(input);

// Create the overlay folder
new_directory_overlay = masterDir+"/overlay";
File.makeDirectory(new_directory_overlay);

// Create the data folder
new_directory_data = masterDir+"/rawdata";
File.makeDirectory(new_directory_data);

for (i = 0; i < list.length; i++){  
	path = list[i];
	file = input + path;

	open(file);
	sliceNumber = nSlices;

	for (x = 1; x <= sliceNumber; x++){		
		open(file, x);
		raw = getTitle(); 
		title = replace(raw, ".tif", "");
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel"); 

		run("Enhance Contrast", "saturated=0.35");
		run("Duplicate...", " "); 
		gaussian = getTitle();
		run("Gaussian Blur...", "sigma=80"); 
		
		imageCalculator("Subtract create", raw, gaussian);
		run("Enhance Contrast", "saturated=0.35");
		
		subtractedGaussian = getTitle();
		close(raw);
		close(gaussian);
	    run("8-bit");
	    
	   	// 1er stop Run until here and set Threshold manually to find min and max value ***
	    setMinAndMax(0, 100);
	    setThreshold(minThreshold, 255);
	    //setOption("BlackBackground", false);
	    run("Convert to Mask");
	    //2e stop pour despeckle et dilate
		for (Despeckle = 0; Despeckle < despeckleVal; Despeckle++){
	    	run("Despeckle");
	    }
		for (Dilate = 0; Dilate < dilateVal; Dilate++){
	    	run("Dilate");
	    }
	    //3e stop pour enlever la majorité du bruit de fond (pas besoin de tout enlever, facilite le skeletonize et réduit  temps traitement)
	    run("Analyze Particles...", "size="+minSizeInterval+"-"+maxSizeInterval+"pixel circularity=0-1 pixel show=Masks");
	    particleMask = getTitle();
	    close(subtractedGaussian);
	    run("Skeletonize");
	    //4e stop enlever tout le bruit de fond et sélectionner seulement les neurones
	    run("Analyze Particles...", "size=300-infinity pixel circularity=0-1 pixel show=Masks");
	    particleMask2 = getTitle();
	    close(particleMask);

		run("Analyze Skeleton (2D/3D)", "prune=none");
		// Save data
		saveAs("Results", masterDir + "/rawData/" + title + "_" + x + ".csv");
		close("Results");
		skeletonMask = getTitle();
		close(particleMask2);
	}
}

	// Save count every y frames
	if (x % saveFrame == 0) {
		run("Images to Stack");
		name = new_directory_overlay + "/" + title + "_skeleton"; 
		saveAs("tif", name);
	}
	/*if (x % saveFrame != 0) {
		close(skeletonMask);
	}*/

// Stop timer and calculate how long the macro ran
timeEnd = getTime();
timeElapsed = timeEnd - timeStart;
 
// Logs
print("Master directory path: "+masterDir);
print("Minimum threshold: "+minThreshold);
print("# of despeckle: "+despeckleVal);
print("# of dilations: "+dilateVal);
print("Minimum size: "+minSizeInterval);
print("Max size: "+maxSizeInterval);
print("Overlay saved every: "+saveFrame + " frame(s)");
print("The macro ran for "+timeElapsed/1000+" seconds.");

// Save logs
selectWindow("Log");
saveAs("Text", masterDir+"logs");
close("Log");