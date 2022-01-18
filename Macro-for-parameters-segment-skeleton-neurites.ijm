/* 
 *  A simple macro that allows you to segment and skeletonize
 *  images in a stack (time-lapse) where the stack is already open in imageJ 
 *  
 *  NB — you need to have a stack open to run the macro
 *  
 */


 // clean, binarize, and skeletonize - define variables for gaussian, 
 // and thresholding that will be used

 	stack = getTitle();


//for (s = 1; s < 562; s+=50) {   // s is the slice number, s+ is the interval but s++ is to run at each slice 
for (s = 1; s < 3; s++) {
 	
 	selectWindow(stack);
//when running for loop	//s = getSliceNumber(); // to duplicate the image that is currently visualised, you need to tell imageJ to duplicate that frame (otherwise it will duplicate the first image) 
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
	close(gaussian);

	selectWindow(subtractedGaussian);
	run("Duplicate...", " ");
	setMinAndMax(0, 100);
	setThreshold(200, 255); //modify lower value (ie to the left for threshold)
	//setOption("BlackBackground", false);
	run("Convert to Mask");

	// despekle — will probably need to add this at some point on messier images. So far not needed 

	//add skeleton 
	run("Duplicate...", " ");
	run("Dilate"); // test, could put more than 1 dilate if needed
	run("Skeletonize");
	run("Duplicate...", " ");
	run("Analyze Particles...", "size=10-10000 circularity=0-1 pixel show=Masks"); //modify the interval if needed
	run("Grays"); // note - for some reason, the image is not in gray scale - curious 
	run("Analyze Skeleton (2D/3D)", "prune=none");

 } //end of the for loop
	
	run("Tile"); // places the images across the display so can see them all next to one another

	// TODO SECTION 

	// it's possible to close images for speeding up things - or, that you do not duplicate every step and you do windwoless mode
	//close(raw);
	//

	//close(gaussian);
	//close(subtractedGaussian); 
 