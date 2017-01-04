//this macro in Fiji can identify positions (x,z) of fish larvae in each frame.
//run("Smooth", "stack");
//run("Variance...", "radius=2 stack");
//run("Maximum...", "radius=2 stack");
//setAutoThreshold("Default dark");
//run("Threshold...");
//run("Invert", "stack");
run("Median...", "radius=1 stack");
run("Maximum...", "radius=1 stack");
setThreshold(0, 170);
run("Convert to Mask", "  black");
run("Invert", "stack");

run("Analyze Particles...", "size=4-100 circularity=0.00-1.00 show=Nothing add in_situ stack");
roiManager("Measure");