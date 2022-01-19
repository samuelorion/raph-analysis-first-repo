// this macro runs the segmnetation on whole stacks 

setBatchMode("hide"); // ** modify me if you want to see the process (you can just add '//' before the command to comment out the command ** 

//directory = "/Users/samuelorion/Desktop/assorted-desktop/raph-analysis/images"; // ** modify me ** 
directory = "/Users/raphaelledenis/Desktop/raph-analysis/images";
//skeletondata = "/Users/samuelorion/Desktop/assorted-desktop/raph-analysis/skeleton-output"; // ** modify me ** 
skeletondata = "/Users/raphaelledenis/Desktop/raph-analysis/skeleton-output";

// for loop to open images within 'directory' *** 

list_directory = getFileList(directory);

	for (image = 0; image < list_directory.length; image++) {
	
	close("*"); // this is very important - sometimes the for loop can start before the last image is still open
	file_to_open = directory + "/" + list_directory[image]; 
	open(file_to_open);

// segmentation and skeletonization section *** 
	raw = getTitle();
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel"); 
	run("Duplicate...", "duplicate");
	gaussian = getTitle();
	run("Gaussian Blur...", "sigma=30 stack"); // ** modify me ** 
	imageCalculator("Subtract create stack", raw, gaussian);
	run("8-bit");
	subtractedGaussian = getTitle();
	close(gaussian);
	selectWindow(subtractedGaussian);
	setAutoThreshold("Default dark");
	setThreshold(5, 255);	// ** modify me ** 
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Default background=Dark black");
	//run("Duplicate...", "duplicate");
	//run("Dilate", "stack");
	run("Skeletonize", "stack");
	skeleton = getTitle();
	run("Analyze Particles...", "size=100-10000 circularity=0-1 pixel show=Masks stack"); // ** modify me ** 
	skeletonMinusParticles = getTitle();
	close(skeleton);
	run("Grays");
	skeletonMinusParticlesLength = nSlices + 1;

// for loop to analyse each slice of skeleton stack ***
// issue with plugin when analysing whole stack  	

	for (i = 1; i < skeletonMinusParticlesLength; i++) {
	setSlice(i);
	run("Duplicate...", " ");
	duplicate_skeleton = getTitle();
	run("Analyze Skeleton (2D/3D)", "prune=none");
	saveAs("Results", skeletondata + "/" + raw + "_frame_" + i + ".csv");
	selectWindow("Tagged skeleton"); close();
	selectWindow(duplicate_skeleton); close();
	close("Results");
	}
}

// each slice, from each stack, is saved in 'skeletondata' directory  *** 
	