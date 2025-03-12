# Colony-Counter

## Table of Contents
- [About](#about)
- [Process](#process)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## About
Colony-Counter is an ImageJ Macro designed to batch process images of bacterial colonies on agar plates.
It leverages Labkit, a machine learning tool for segmentation and classification of microscopy images, to 
separate bacterial colonies from a background (most often an agar plate of some sort) so they can be 
counted by FIJI. The basic pipeline could probably be used to separate and count any collection of circular
objects from a background with sufficient contrast, so do with it what you will!

This macro draws heavily from nucleus segmentation protocols from the Harvard [Image Analysis Collaboratory](https://iac.hms.harvard.edu/), a brilliant resource for FIJI and other image analysis education.

Labkit citation:

Arzt, M., Deschamps, J., Schmied, C., Pietzsch, T., Schmidt, D., Tomancak, P., … Jug, F. (2022). 
LABKIT: Labeling and Segmentation Toolkit for Big Image Data. Frontiers in Computer Science, 
4. [doi:10.3389/fcomp.2022.777728](https://www.frontiersin.org/journals/computer-science/articles/10.3389/fcomp.2022.777728/full)


## Process
Here is a (originally-intended-to-be) brief overview of the process Colony-Counter takes to process your images, with some helpful tips:
- ### Cropping Image
  First, select your input directory (**all images should be in .jpg format!!!**). The macro will process all images in your directory, so it is recommended to separate images by strain or any treatments that significantly effect colony morphology. All images in a single directory will be processed by a single classifer (more on this in segmentation section).
  The macro will automatically generate an oval selection of the following parameters: `makeOval(908, 520, 1552, 1552)`
  You will be prompted to adjust the oval to be centered on your plate. The output will be stored in a 'cropped' folder in your image directory

  **The oval does not need to include all colonies as long as:**
  - You do not change the **size** of the oval between images (please only adjust the x/y position so it is centered on your plate)
  - The plates are imaged in a consistent manner (e.g at a fixed magnification/distance) such that the oval covers the same area of the plate in each image.
  - You do not need quantitative information about cfu/ml (You could still get this information using this tool, but you would need to normalize your colony count taking into account what percentage of the plate area is included in the oval selection)
  - You are only comparing between plates within one experiment.

  The reason that the plate is cropped is because edge colonies are difficult for the classifier to detect, so cropping gives a much more consistent and reliable result.
  
- ### Segmentation with Labkit
  After cropping, the macro will open the first cropped image file from your folder. It will direct you to open the Labkit plugin (included with FIJI, more on installation and use of Labkit [here](https://imagej.net/plugins/labkit/)) and use Labkit to train a classifier. Labkit is pretty user friendly: basically what you need to do is use the drawing tools to label your background (agar plate, etc) and your foreground (colonies, etc), and then add and train a classifier in the bottom right "Segmentation Menu". Continue to iteratively train the classifier until you are satisfied with the result. You will then need to save the classifier as a .classifier file.
<img width="600" alt="Labkit segmentation process 1" src="https://github.com/user-attachments/assets/ecc07d50-950f-42d8-9b5e-fbc8f3547d5c" />
<img width="600" alt="Labkit segmentation process 2" src="https://github.com/user-attachments/assets/cd74a94b-fa6b-4e0e-b6b1-647cb100d664" />

  The macro will prompt you to close Labkit after saving your classifier, and then you will be prompted to select your classifier file. All images in the folder will then be processed using your selected classifier. The output will be stored in a 'segmented' folder in your image directory.

  **A note on classifiers**:
  You may not need to train a new classifier every time you use the macro. I will generally train a classifier for a particular strain, and then as long as the imaging conditions are kept relatively consistent, I have found that the same classifier will do the trick for multiple experiments. Always do quality control checks when re-using a classifier and find what set-up works for you.
  
- ### Binary Filters
  I have found that hole-filling followed by watershed (to separate touching colonies) works best, so this is what is included in the protocol. Depending on the use-case it may make sense to try out different filtering protocols to optimize colony counting in the next step.

- ### Analyze Particles (colony counting)
  After applying binary filters, the first segmented, filtered binary image will be opened for you. You will be prompted to test 'Analyze particles' to find the optimal size ($\text{pix}^2$) and circularity (0.00-0.1) that maximizes the amount of colonies captured without counting artifacts as well. I suggest selecting 'add to manager' in the analyze particles settings, and then unchecking the 'labels' checkbox in the ROI manager when testing different settings. This should outline each detected colony in yellow so you can see what settings need to be adjusted.

  Once you have optimized the settings for analyze particles, record the min/max for each parameter. You will then be prompted to input these parameters, which will then be applied to each image in your folder. This is the step where colonies are actually counted! Note that 'exclude edges' is automatically selected, so edge colonies will not be counted.

- ### Output Files
  All output files are in .tiff or .csv format.
  - Cropped Folder: All cropped images
    ![RF568 MOPS T0 P2-638769366397858641-BF](https://github.com/user-attachments/assets/25d8fca8-3c16-4c45-a35b-fd4d86e14b1b)
  - Segmented Folder: All binary images produced via Labkit segmentation
    ![RF568 MOPS T0 P2-638769366397858641-BF](https://github.com/user-attachments/assets/051b7848-0b28-44a9-a00d-3a3aa698b415)
  - Binary Folder: Segmented images after binary filtering
    ![binary_RF568 MOPS T0 P2-638769366397858641-BF](https://github.com/user-attachments/assets/dc865077-e34e-45b5-8611-863d0f9cd2ff)
  - Summary Folder: Results of Analyze Particles for each image and concatenated file of all results
<img width="528" alt="Screenshot 2025-03-12 at 10 56 49 AM" src="https://github.com/user-attachments/assets/d17dd34c-44a5-4ce5-bf08-1b160ac5b936" />
  
  An example of concatenated results:
  
<img width="206" alt="Screenshot 2025-03-12 at 10 59 58 AM" src="https://github.com/user-attachments/assets/091913a2-0a91-496e-96c1-39d9d05c540f" />


## Usage
### Prerequisites
You will need FIJI/ImageJ to run this macro. This is the version of ImageJ this macro was optimzed for:
<img width="497" alt="Screenshot 2025-03-12 at 11 24 15 AM" src="https://github.com/user-attachments/assets/1c3e9457-c1ee-4b7d-936b-36df01ae4d7c" />

First, download the ColonyCounterMacro.ijm file from this repository

You can run a macro in FIJI by navigating Plugins -> Macros -> run... and then selecting the ColonyCounterMacro.ijm file

## Contributing
Feel free to reach out with any needs or if you have useful edits you want to share!

## License
<img width="787" alt="Screenshot 2025-03-12 at 11 27 52 AM" src="https://github.com/user-attachments/assets/c8849b64-1d15-4e5e-bd8d-346b884349ce" />

## Contact
Reach out to amelie_andreas@hms.harvard.edu with any questions or comments
