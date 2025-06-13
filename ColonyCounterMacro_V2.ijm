//Part 1: before segmenting
waitForUser("Choose Image Directory")
folder = getDirectory("")
fileList = getFileList(folder); // Get all files in the folder

//Make output folders
File.makeDirectory(folder + "cropped")
File.makeDirectory(folder + "segmented")
File.makeDirectory(folder + "binary")
File.makeDirectory(folder + "summary")

//Crop circle
print("Cropping Plates")
	
for (i = 0; i < fileList.length; i++) {
    filePath = folder + fileList[i]; // Full path to file
    fileName = File.getName(filePath); // Extract filename
    
 	 if (endsWith(fileName, ".jpg") || endsWith(fileName, ".tif") || endsWith(fileName, ".tiff")){
		print((i+1) + "/" + (fileList.length));
	    open(filePath); //open file
		selectImage(fileName);
 	 }
 	 else{
 	 	continue
 	 }

//crop circle selection & remove background

	setTool("oval");
	makeOval(908, 520, 1552, 1552);
	waitForUser("adjust oval to center of plate");

	run("Crop");
	setBackgroundColor(0, 0, 0);
	run("Clear Outside");

	saveAs("Tiff", folder + "/cropped/" + fileName);
	
close();
};

cropped_folder = folder + "cropped/";
cropped_fileList = getFileList(cropped_folder);

open(cropped_folder + cropped_fileList[1])

waitForUser("Train classifier using Labkit plugin: \n \n Plugins -> LabKit -> Open Current Image With LabKit \n \n Save classifier, then click 'okay'.");

//Run segmentation

waitForUser("Close Labkit window & Select Classifier File")
classifier = File.openDialog("")

segment_folder = folder + "segmented/"
segment_fileList = getFileList(segment_folder);

print("Segmenting Colonies")

for (i = 0; i < (cropped_fileList.length); i++) {
	print((i+1) + "/" + cropped_fileList.length);
	filePath = cropped_folder + cropped_fileList[i]; // Full path to file
	fileName = File.getName(filePath);
	if (endsWith(fileName, ".tif") || endsWith(fileName, ".tiff")) {
    open(filePath); //open file
	selectImage(fileName);
	run("8-bit");
	run("Segment Image With Labkit", "segmenter_file=[" + classifier+ "] use_gpu=false");
	saveAs("Tiff", segment_folder + fileName);
	close();
    run("Close All");
    }
    else{
    	continue
    }
};

//Binary filters and analyze particles

binary_folder = folder + "/binary/"

summary_folder = folder + "/summary/"

segment_folder = folder + "segmented/"
segment_fileList = getFileList(segment_folder);

print("Applying Filters");

for (i = 0; i < segment_fileList.length; i++) {
	print((i+1) + "/" + segment_fileList.length);
	filePath = segment_folder + segment_fileList[i]; // Full path to file
    fileName = File.getName(filePath);
      
    open(filePath); //open file
	selectImage(fileName);

//Convert to 0-255

	run("RGB Color");
	run("8-bit");

//Binary Filters

	run("Fill Holes");
	run("Watershed");

	saveAs("Tiff", binary_folder + fileName);
	close();
}

binary_List = getFileList(binary_folder);

open(binary_folder + binary_List[1])

waitForUser("Optimize analyze particle parameters:\n \n Analyze -> Analyze Particles \n \nWhen satisfied, note parameters down, then press 'okay'. ");

Dialog.create("My inputs");
Dialog.addMessage("Adjust parameters");
Dialog.addNumber("Min particle size", 200);
Dialog.addNumber("Max particle size", 2000);
Dialog.addNumber("Min circularity", 0.8);
Dialog.addNumber("Max circularity", 1.0);

Dialog.show();


MinP = Dialog.getNumber()
MaxP = Dialog.getNumber()
MinC = Dialog.getNumber()
MaxC = Dialog.getNumber()

close("*");
print("Analyzing Particles & Summarizing Results");

for (i = 0; i < binary_List.length; i++) {
	print((i+1) + "/" + binary_List.length);
	filePath = binary_folder + binary_List[i]; // Full path to file
    fileName = File.getName(filePath);
    
    open(filePath); //open file
	selectImage(fileName);

//Analyze Particles (optimize size and circularity for specific strain)
	run("Analyze Particles...", "size=" + MinP + "-" + MaxP + " circularity=" + MinC + "-" + MaxC + " exclude summarize");

//Save summary
	saveAs("Results", summary_folder + fileName + ".csv");
	close();
	close("*.csv");
};


//Create Output File
strain = getString("Strain/Condition For Output File", "RF"); 

output_folder = folder + "summary"

outputCSV = output_folder + "/" + strain + "_combined_results.csv";

File.saveString("Filename,Count,AvgSize\n", outputCSV);

summary_fileList = getFileList(output_folder);

// Loop through each file and print its name (if troubleshooting)
//for (i = 0; i < summary_fileList.length; i++) {
    //print("File:", summary_fileList[i]);
//};

for (i = 0; i < summary_fileList.length; i++) {
    if (endsWith(summary_fileList[i], ".tif.csv") || endsWith(summary_fileList[i], ".tiff.csv")) {
        filePath = output_folder + "/" + summary_fileList[i];
        lines = File.openAsString(filePath);
        lineArray = split(lines, "\n");
        
        if (lengthOf(lineArray) > 1) {
            secondRow = split(lineArray[1], ","); // Extract second row
            
            if (lengthOf(secondRow) > 1) {
                lineToWrite = secondRow[0] + "," + secondRow[1] + "," + secondRow[3];
                File.append(lineToWrite, outputCSV);
            };
            
            else {
					continue;
        	};
        };
  		else{
     	continue;
     	};
    };
};
    

print("All done! \n⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⠀⠀⠀⠀⠀⠀\n⠀⠀⢀⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀\n⠐⠶⣿⣿⡿⠖⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣷⠀⠀⠀⠀⠀⠀\n⠀⠀⠈⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣰⣿⣿⣇⡀⠀⠀⠀⠀\n⠀⠀⠀⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⢿⣿⣿⡿⠟⠋⠉⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⠁⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⡇⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠇⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⢀⣠⣿⣿⣿⣿⣧⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⢠⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣦⡤⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠉⠛⢿⣿⣿⣿⣿⣿⠟⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣇⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣶⣿⣿⣆⣀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⡿⠉⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠃⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀");