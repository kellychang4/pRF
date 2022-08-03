function [protocols] = create_protocols(boldFiles, stimFiles, roiFile, options)
% [protocols] = create_protocols(boldFiles, stimFiles, roiFile, options)
%
% Creates a structure 'protocols' containing information about the BOLD 
% data and stimulus presented for a given protocol. 
%
% INPUTS ------------------------------------------------------------------
%
%   boldFiles                Path(s) to all BOLD files(s), string or cell
%                            array of strings.
%
%   stimFiles                Path(s) to all stimulus files, string or cell
%                            array of strings.
%
%   roiFile                  Path to ROI file, string.
%
%   options                  Additional named argument. Could include:
%       TR                   If BOLD data are in gifti (.gii) format, the
%                            BOLD TR *must* be provided, numeric.
%
%       stimImg              Name of the variable within 'stimFiles' that
%                            contains the stimulus, string.
%                            Default is 'stimImg'.
%
%       funcOf               Name of the variable within 'stimFiles' that
%                            contain the stimulus coordinates, string.
%                            Default is 'funcOf'.
%
% OUTPUTS -----------------------------------------------------------------
%
%   protocols                A structure with length 1xN where N is the
%                            number of bold data and stimulus pairs. 
%                            Includes the following fields:
%
%       roi_file             Name of the ROI file, string.
%       <voxel/vertex>       Identifying indices of the units within the
%                            BOLD data, string.
%
%       bold_file            Name of the BOLD file, string.
%       bold_size            Size of the functional data, matrix.
%       bold_dt              Time step, or TR, of the scan data, seconds.
%       bold_t               Time vector of the scan data, seconds.
%       bold                 BOLD time course, [n_volumes n_units].
%
%       stim_file            Name of the stimulus file, string.
%       stim_funcof          A structure containing the coordinates by 
%                            dimension as fields (e.g., 'x', 'y') that
%                            describe stimulus space. The size of each 
%                            dimension should be the stimulus dimensions.
%       stim_dt              Time step of the stimulus, seconds.
%       stim_t               Time vector of the stimulus, seconds.
%       stim                 A [M x Ni x ... x Nn] matrix where M is the
%                            number of volumes of the scan and Ni through
%                            Nn is the length(scan.paradigm.<funcOf>) or
%                            the desired resolution of the stimulus image
%                            for each stimulus dimension

%% Argument Validation

arguments
    %%% required arguments
    boldFiles cell {mustBeText, validate_files(boldFiles), validate_bold_ext(boldFiles)}
    stimFiles cell {mustBeText, validate_files(stimFiles), validate_equal_size(boldFiles, stimFiles)}
    roiFile (1,:) char {mustBeFile} 
    
    %%% conditional arguments
    options.TR (1,1) double {validate_gifti_tr(boldFiles, options.TR), validate_tr(options.TR)} = NaN
    
    %%% optional arguments
    options.stimImg (1,:) char {mustBeTextScalar} = 'stimImg'
    options.funcOf  (1,:) char {mustBeTextScalar} = 'funcOf'
end

%% Create 'protocol' Structure

n = length(boldFiles);
protocols = initialize_protocol(n);

for i = 1:n % for each bold file
    
    %%% load bold information
    boldFile = boldFiles{i};
    [~,boldName,boldExt] = extract_fileparts(boldFile);
    fprintf('Loading: %s\n', [boldName boldExt]);
    
    switch boldExt % bold data format
        case {'.vtc'} % BrainVoyager Volumetric
            error('BrainVoyager Volume not yet implemented (WIP)');
            %             scan = create_brainvoyager_scan(boldFile, roiFile);
        case {'.nii', '.nii.gz'} % FreeSurfer Volumetric
            error('FreeSurfer Volume not yet implemented (WIP)');
            %             scan = create_freesurfer_scan(boldFile, roiFile);
        case {'.gii'} % GiFTi Surface
            scan = create_gifti_scan(boldFile, roiFile, options.TR);
        otherwise
            error('Unrecognized bold data file extension: %s\n', ext);
    end
    
    %%% load stimulus information
    stimFile = stimFiles{i};
    [~,stimName,stimExt] = extract_fileparts(stimFile);
    fprintf('Loading: %s\n', [stimName stimExt]);
    
    %%% create stimulus image from file
    stim = create_stimulus_image(stimFile, options);
    
    %%% save scan and stimulus information
    protocols(i) = combine_scan_and_stim(scan, stim, roiFile);
end

end