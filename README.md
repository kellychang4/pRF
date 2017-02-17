# Population Receptive Field (pRF)

Code for fitting population receptive fields (Dumoulin & Wandell, 2008). Includes compressive spatial summation exponential parameter (Kay et al., 2013).

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
	% paths.data = fullfile(paths.main, 'Ver2.0', 'Demo', 'DemoData'); % path to demostration data directory
	% paths.results = fullfile(paths.main, 'Ver2.0', 'Demo', 'DemoExampleResults'); % path to output results directory
	% paths = createPaths(paths); % create paths if they do not already exist
	```

4. Run demopRF.m
	* Estimates pRF parameters, mu & sigma & exp, along with HRF parameters, tau & delta, for the demonstration data
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

# Verions

### Verson 1.0
- Estimates individual HRF parameters, tau & delta
- Fits 1D Gaussian pRF model with parameters, mu & sigma; includes a compressive spatal summation exponential parameter, exp  
<br>

### Version 1.1
- Added cost option to parameter estimation
- Fixed convoluion of stimulus that is not time locked to scan's TRs. Note currently only works so long as stimulus presentation interval is constant and not jittered
- Added plotting functions to plot parameter histograms and pRF model predicted voxel time courses vs. actual voxel time courses
- Added demostration scripts and data (see Demostration section)
- Added BrainVoyager QX capatible functions and demo files for visualization for demonstration data
- Fixed bugs for single scan inputs
- Optimizing script for additional efficient and interfacing
- Added more misc. functions  
<br>

### Version 2.0
- Added m-D pRF modeling! (finally)
- Added options to fit pRF model and HRF (in iterations) in one go
- Changed mentions of 'HDR' to 'HRF' 
- Iterative HRF takes subset of voxels past settable threshold after initial pRF fitting and parameters to then fit tau and delta parameters of HRF. HRF parameters are then held constant to be pRF fitted. This cycle repeats ending on a HRF fit for however many HRF fitting iterations specified.  
- Added createModel.m, GLMinVOI.m, callFitModel.m, callFitHRF.m
- Edited bug in safeSave.m
- Modified createConvStim, createScans, createPaths, createStimImg, estpRF, predictpRF for m-D pRF modeling
- Added voi2mat.m; saves linear indices of .voi coordinates within a .vtc as a .mat
- Added nestedF.m; computes a nested F test on each voxel where Model 1 must be nested within Model 2.
- Added more misc. functions
<br>

### Version 2.1
- ~~~~!!!!!~~~~ WIP WIP WIP WIP WIP ~~~~!!!!!~~~~
- Idea stage, please don't take these version notes as ideas to be done
- should include without BV compatibility (maybe for another version...) for other programs
- createScan is too BV optimized, if some fields fail it should not be a catastrophic failure
- doesn't mean i shouldn't include more functionality for BV...
- paradigm input should be variable such as from a .txt file
- WORKING IN TIME AND NOT TRS!!!!!
- should start writing a documentation manual about all the options @.@

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