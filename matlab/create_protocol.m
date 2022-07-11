function [protocol] = create_protocol(boldFiles, stimFiles, roiFile, varargin)
% [scans] = create_protocol(scanInfo)
%
% Creates a structure 'scans' containing information about the scan(s) given
% by the corresponding 'scanInfo.boldFiles' and 'scanInfo.roiFile' through
% one of two methods
%
% METHOD 1: PARADIGM
% Will create a 'scans' structure based on the given
% 'scanInfo.paradigm.<funcOf>' sequence(s), will create a stimulus image
% from the given paradigm sequence(s)
% 
% METHOD 2: STIMULUS IMAGE
% Will create a 'scans' structre based on pre-defined stimulus image(s)
%
% Inputs:
%   scanInfo                 A structure containing option to create the
%                            'scans' structure with fields:
%       boldFiles            Path(s) to all BOLD files(s), string
%       stimFiles            Path(s) to all stimulus/ protocol files, string
%       roiFile              Path to ROI file, string
%
% -------------------------------------------------------------------------
% METHOD 2: STIMULUS IMAGE
%       stimImg              Name of the stimulus image variable within the
%                            paradigm file(s), string; optional, specifying
%                            will use this variable as the stimulus image
%       dt                   Time step size, numeric (default:
%                            scan.dur/size(stimImg,1))
%       order                Order of the stimulus image dimensions
%                            (default: [nVolumes <opt.model's funcOf>])
%       funcOf               A structure containing the stimulus function 
%                            of dimension range as fields
%
% Output:
%   scans                    A structure with length 1xN where N is the
%                            length of 'scanInfo.boldFiles' containing the
%                            .vtc and scan's information with fields:
%       stimFile             Name of the stimulus / protocol file , string
%                            (i.e., 'Subj1_Paradigm_Set1.mat')
%       paradigm             A structure containing the paradigm sequences
%                            for each stimulus dimension given as fields:
%           <funcOf          Stimulus paradigm sequence, should be given in
%             parameters>    units that are to be estimated for each
%                            stimulus dimension, blanks should be coded as
%                            NaNs, numeric
%       k                    A structure containing the unique stimulus
%                            values for each stimulus dimension given as
%                            fields:
%           <funcOf          Unique stimulus values for each stimulus
%             parameters>    dimension, excludes NaNs
%       funcOf               A structure containing the actual function of
%                            parameters as matrices scan given the model as
%                            fields:
%           <funcOf          Full function of stimulus values for each 
%             parameters>    stimulus dimension, meshgrid applied if
%                            multiple funcOf parameters
%       boldFile             Name of the BOLD file, string
%                            (i.e., 'Subj1_Set1.<vtc/nii>')
%       boldSize             Size of the functional data
%       nVols                Number of volumes in the scan
%       dur                  Total scan duration, seconds
%       TR                   TR of the scan, seconds
%       dt                   Time step for the paradigm or stimulus image,
%                            seconds
%       t                    Time vector of the scan in TRs, seconds
%       voxID                Voxel index number
%       vtc                  Voxel time course 
%       stimImg              A M x Ni x ... x Nn matrix where M is the
%                            number of volumes of the scan and Ni through
%                            Nn is the length(scan.paradigm.<funcOf>) or
%                            the desired resolution of the stimulus image 
%                            for each stimulus dimension
%
% Note:
% - Dependencies: <a href="matlab:
% web('http://support.brainvoyager.com/available-tools/52-matlab-tools-bvxqtools/232-getting-started.html')">BVQXTools/NeuroElf</a>, <a href="matlab: web('https://github.com/vistalab/vistasoft/tree/master/external/freesurfer')">mrVista/FreeSurfer</a>

% Written by Kelly Chang - June 23, 2016
% Edited by Kelly Chang - September 1, 2017
% Edited by Kelly Chang - July 8, 2022

%% Validate Function Arguments

validate_create_protocol(boldFiles);
set_global_with_protocol_information(boldFiles);

%% Creating 'protocol' Structure

n = length(boldFiles); 
protocol = initialize_protocol(n);

for i = 1:n % for each bold file
    
    %%% load bold information
    boldFile = boldFiles{i};
    [~,boldName,boldExt] = extract_fileparts(boldFile);
    print_message('Loading: %s\n', [boldName boldExt]); 
    
    switch boldExt % bold data format
        case {'.vtc'} % BrainVoyager Volumetric
            scan = create_brainvoyager_scan(boldFile, roiFile);
        case {'.nii', '.nii.gz'} % FreeSurfer Volumetric
            % (!!!) this needs editing
            scan = create_freesurfer_scan(boldFile, roiFile);
        case {'.gii'} % GiFTi Surface
            scan = create_gifti_scan(boldFile, roiFile, TR);
        otherwise
            error('Unrecognized bold data file extension: %s\n', ext);
    end
    
    return
    %%% load stimulus information
    stimFile = stimFiles{i};
    [~,stimName,stimExt] = extract_fileparts(stimFile);
    print_message('Loading: %s\n', [stimName stimExt]);
    
    stim = create_stimulus_image(scan, boldFiles, i);
    
    %%% save scan and stimulus information
    protocol(i) = combine_scan_and_stim(scan, stim); 
end