# Population Receptive Field (pRF)

Code for fitting population receptive fields (Dumoulin & Wandell, 2008) for multidimensional models. Includes optional compressive spatial summation exponential parameter (Kay et al., 2013).

---

# Demonstration

1. Add pathing to pRF package

	```matlab
	addpath(genpath('PathToPackage'));
	```

2. Open demopRF.m

	```matlab
	open demopRF
	```

3. Edit Pathing to Directories
	* Uncomment directories section and edit as based on your computer's pathing
	<br>
	
	```matlab
	% paths = createPaths(); % initialize paths structure
	% paths.data = fullfile(paths.main, 'DemoData'); % path to demostration data directory
	% paths.results = fullfile(paths.main, 'DemoExampleResults'); % path to output results directory
	% paths = createPaths(paths); % create paths if they do not already exist
	```

4. Run demopRF.m
	* Estimates pRF parameters, mu & sigma & exp, along with Boynton HRF parameters, tau & delta, for the demonstration data
	* Plots histogram of estimated pRF parameters mu, sigma, exp, and corr
	* Plots pRF model predicted voxel time courses vs. actual voxel time courses  

#### Continue for BrainVoyager Only visualization demo scripts

5. Open demoBVFiles.m

	```matlab
	open demoBVFiles
	```

6. Edit pathing to main directory

	```matlab
	paths.main = ''; % input main working directory
	```

7. Run demoBVFiles.m
	* Creates a .olt file based on the number of specified colors
	* Creatae a .vmp file for the parameters specified, able to adjust for a range of parameter fits

---

# Tutorial

I've written a tutorial that walks through the concepts of pRF modeling in case you're new to the topic.

[pRF Tutorial](http://htmlpreview.github.io/?https://github.com/kellychang4/pRF/blob/master/Tutorial/html/pRFTutorial.html)

--- 

# Latest Version
[Version Log](https://github.com/kellychang4/pRF/blob/master/VersionLog.txt)

### Version 2.1
- Added stimulus image capabilities, can now supply a "movie" of stimulus in time
- Added HRF options, can now provide a previously estimated HRF, non-parameterized, to be used in pRF convolution instead of parameterized version
- Added general pRF / fMRI walk-through in 'Tutorial' folder
- Reorganized pRF package structure
- Edited misc. functions for use outside of pRF package (i.e., removing some forced structure arguments)

--- 

# Contributor(s)

Kelly Chang - @kellychang4 - kchang4@uw.edu

--- 

# Dependencies

[BVQXtools/NeuroElf](http://support.brainvoyager.com/available-tools/52-matlab-tools-bvxqtools/232-getting-started.html)

--- 

# References

Dumoulin, S. O., & Wandell, B. A. (2008). Population receptive field estimates in human visual cortex. Neuroimage, 39(2), 647-660.

Kay, K. N., Winawer, J., Mezer, A., & Wandell, B. A. (2013). Compressive spatial summation in human visual cortex. Journal of neurophysiology, 110(2), 481-494.