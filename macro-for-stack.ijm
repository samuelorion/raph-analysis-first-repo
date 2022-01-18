	// this macro runs the segmnetation on whole stacks 

	directory = "/Users/samuelorion/Desktop/assorted-desktop/raph-analysis";
	skeletondata = "/Users/samuelorion/Desktop/assorted-desktop/raph-analysis/skeleton-output";
	//TEST RAPH TO SEE IF I'M ABLE TO RUN IT ON MY COMPUTER directory = "/Users/raphaelledenis/Desktop/raph-analysis";
	//TEST RAPH TO SEE IF I'M ABLE TO RUN IT ON MY COMPUTER skeletondata = "/Users/raphaelledenis/Desktop/raph-analysis/skeleton-output";
	
	
	// create for loop to open stacks to then run analysis 
	raw = getTitle();
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel"); 
	run("Duplicate...", "duplicate");
	gaussian = getTitle();
	run("Gaussian Blur...", "sigma=40 stack");
	imageCalculator("Subtract create stack", raw, gaussian);
	run("8-bit");
	subtractedGaussian = getTitle();
	close(gaussian);
	selectWindow(subtractedGaussian);
	setAutoThreshold("Default dark");

	setThreshold(200, 255);
	
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Default background=Dark black");
	//run("Duplicate...", "duplicate");
	run("Dilate", "stack");
	run("Skeletonize", "stack");
	skeleton = getTitle();
	run("Analyze Particles...", "size=10-10000 circularity=0-1 pixel show=Masks stack");
	skeletonMinusParticles = getTitle();
	close(skeleton);
	run("Grays");
	
	skeletonMinusParticlesLength = nSlices + 1;
	
	//for (i = 1; i < skeletonMinusParticlesLength; i++) {
	for (i = 1; i < 3; i++) {
		setSlice(i);
		run("Analyze Skeleton (2D/3D)", "prune=none");		
		saveAs("Results", skeletondata + "/" + raw + "_" + i + ".csv");
		close("Results");
		}
	