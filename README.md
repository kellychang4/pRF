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
	* Edit directories section as based on your computer's pathing
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
	* Plots estimated Boynton HRF as a function of time

---

# Tutorial

I've written a tutorial that walks through the concepts of pRF modeling in case you're new to the topic.

[pRF Tutorial](http://htmlpreview.github.io/?https://github.com/kellychang4/pRF/blob/master/Tutorial/html/pRFTutorial.html)

--- 

# Latest Version

### Version 3.0
- createScan.m can now also take in FreeSurfer .nii, .nii.gz, .mgz files along with .label files (to select ROIs)
- Edited HRF options, can now provide other parameterized HRF function other than the BoyntonHRF such as the TwoGammaHRF from SPM
- Edited HRF estimating methods, can now iteratively fit HRF parameters either voxels that past a correlation threshold and/or are in the top percentage of initial correlation fits
- Incorporated timing interpolation if stimulus image and voxel time courses were collected at different sampling rates
- Add plotHRF.m to visualize the HRF used to fit the pRF model
- Optimizing for redundant code calls and efficiency. Also reduced nested structure layers
- General documentation editing for spelling errors and clarity

[Version Log](https://github.com/kellychang4/pRF/blob/master/VersionLog.txt)

--- 

# Contributor(s)

Kelly Chang - @kellychang4 - kchang4@uw.edu

--- 

# Dependencies

* [BVQXtools/NeuroElf](http://support.brainvoyager.com/available-tools/52-matlab-tools-bvxqtools/232-getting-started.html)
* [mrVista/FreeSurfer](https://github.com/vistalab/vistasoft/tree/master/external/freesurfer)

--- 

# References

Dumoulin, S. O., & Wandell, B. A. (2008). Population receptive field estimates in human visual cortex. Neuroimage, 39(2), 647-660.

Kay, K. N., Winawer, J., Mezer, A., & Wandell, B. A. (2013). Compressive spatial summation in human visual cortex. Journal of neurophysiology, 110(2), 481-494.
