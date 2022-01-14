/* 
 *  a simple macro that allows you to segment and skeletonize
 *  images in a stack (time-lapse) 
 *  
 *  NB — you need to have a stack open to run the macro
 *  
 */

 // duplicate image from stack

 // clearn and binarize - define variables
	s = getSliceNumber();
	run("Duplicate...", "duplicate range="+s+"-"+s+"");
	//rename("original");
	raw = getTitle();
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
	run("mpl-viridis");
	run("Enhance Contrast", "saturated=0.35");
	
	run("Duplicate...", " ");
	//rename("gaussian"); 
	gaussian = getTitle();
	run("Gaussian Blur...", "sigma=40"); //modify 

	
	imageCalculator("Subtract create", raw, gaussian);
	run("Enhance Contrast", "saturated=0.35");
	//rename("subtractedGaussian"); 
	subtractedGaussian = getTitle();
	run("8-bit");

	run("Duplicate...", " ");
	setMinAndMax(0, 100);
	setThreshold(150, 255); //modify lower value (ie to the left for threshold)
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