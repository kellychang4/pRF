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

# Latest Version

### Version 2.0
- m-D pRF modeling: can fit 1D pRF model (i.e., Tonotopy), or 2D pRF models (i.e., Retinotopy), up to m-D pRF models
- Iterative HRF fitting: takes a subset of voxels past settable threshold after initial pRF parameter fitting, holds those constant, fits tau + delta HRF parameters, take median tau + delta, hold those constant, and re-fit pRF parameter(s) on subset of voxels for specified iterations

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