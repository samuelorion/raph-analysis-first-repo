/* 
 *  A simple macro that allows you to segment and skeletonize
 *  images in a stack (time-lapse) where the stack is already open in imageJ 
 *  
 *  NB — you need to have a stack open to run the macro
 *  
 */


 // clearn, binarize, and skeletonize - define variables for gaussian, 
 // and threholding that will be used
 
	s = getSliceNumber(); // to duplicate the image that is currently visualised, you need to tell imageJ to duplicate that frame (otherwise it will duplicate the first image) 
	run("Duplicate...", "duplicate range="+s+"-"+s+""); // note that you need the '+' symbols and that the extra "" at the end for the command to work
	raw = getTitle();
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
	run("mpl-viridis");
	run("Enhance Contrast", "saturated=0.35");
	
	run("Duplicate...", " ");

	gaussian = getTitle();
	run("Gaussian Blur...", "sigma=40"); //modify the value: example if I want sigma to = 100, I would write run("Gaussian Blur...", "sigma=100"); 
	
	imageCalculator("Subtract create", raw, gaussian);
	run("Enhance Contrast", "saturated=0.35");

	subtractedGaussian = getTitle();
	run("8-bit");

	run("Duplicate...", " ");
	setMinAndMax(0, 100);
	setThreshold(200, 255); //modify lower value (ie to the left for threshold)
	//setOption("BlackBackground", false);
	run("Convert to Mask");

	// despekle etc., cleaning steps

	//add skeleton 
	
	run("Duplicate...", " ");
	run("Skeletonize");
	
	//close(gaussian);
	//close(subtractedGaussian); 
	run("Tile");
	
	//close(raw);
	//close(gaussian);
    run("8-bit");
 

 // clean binary, and skeletonize

 // for extra if we have time -- playt with skeleton anaylyze for output 