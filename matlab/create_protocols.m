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

%% Create 'protocols' Structure

n = length(boldFiles); 
protocols = initialize_protocols(boldFiles{1}, n); 

for i = 1:n % for each bold file
    %%% load bold information
    boldFile = boldFiles{i};
    [~,boldName,boldExt] = extract_fileparts(boldFile);
    fprintf('Loading: %s\n', [boldName boldExt]);
    
    switch boldExt % bold data format
        case {'.vtc'} % BrainVoyager Volumetric
            %%% (!!!) create_brainvoyager_scan has not been checked
            scan = create_brainvoyager_scan(boldFile, roiFile);
        case {'.nii', '.nii.gz'} % NiFTi Volumetric
            %%% (!!!) create_nifti_scan has not been checked
            scan = create_nifti_scan(boldFile, roiFile);
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

%% Helper Functions

function [protocols] = initialize_protocols(boldFile, n)
    flds = {
        'roi_file', 'voxel_tal', 'voxel', 'vertex', ...
        'bold_file', 'bold_size', 'bold_dt', 'bold_t', 'bold', ...
        'stim_file', 'stim_funcof', 'stim_dt', 'stim_t', 'stim'
    };

    %%% fieldnames depend on functional data file format
    if endsWith(boldFile, '.gii') % surface = vertex
        flds = flds(~contains_regex(flds, 'voxel'));
    else % volumetric = voxel fieldnames
        flds = flds(~contains_regex(flds, 'vertex'));
    end
    
    protocols = initialize_structure(n, flds); 
end

%%% read vertices and ras coordinates from .label files
function [vertices,ras] = read_label(labelFile)
    %%% read raw text of label file
    fid = fopen(labelFile,'r');
    data = textscan(fid, '%f%f%f%f%f\n', 'HeaderLines', 2);
    fclose(fid); % close text file
    
    %%% extract vertex indices and ras coordinates from text
    vertices = data{1}; % note: zero-based indexing!
    ras = [data{2} data{3} data{4}]; % right-anterior-superior
    
    %%% return unique vertices and coordinates in 1-based indexing
    [~,uIndx] = unique(vertices);   % locate unique vertices
    vertices = vertices(uIndx) + 1; % for matlab, one-based indexing
    ras = ras(uIndx,:); % matching unique RAS coordinates
end

%%% create scan structure from brainvoyager vtc files
function [scan] = create_brainvoyager_scan(boldFile, roiFile)
    %%% read source bold data and roi indices
    bold = xff(boldFile); % read .vtc file
    roi  = xff(roiFile);  % read .roi file

    %%% extract vtc within roi
    vtc = VTCinVOI(bold, roi); % (!!!) indices might not be as indended 
    
    %%% save scan information in 'scan' output
    scan.file = filename(boldFile); % name of bold data file
    scan.size = size(bold.VTCData); % size of the vtc data
    scan.dt = bold.TR ./ 1000; % repetition time, seconds
    scan.t = (0:scan.size(1)-1) .* scan.dt; % time vector, seconds
    
    % (!!!) below this line, not checked code.
    scan.voxel_tal = cat(1, vtc.index); % voxel index (functional space)
    scan.voxel     = cat(1, vtc.id);    % voxel id number (linearized)
    scan.vtc = cat(2, vtc.vtcData); % voxel time course
end

%%% create scan structure from nifti files
function [scan] = create_nifti_scan(boldFile, roiFile)
    %%% read source bold data and roi indices
    bold = MRIread(boldFile); % load nifti file
    tc = squeeze(bold.vol);   % coerce data to shape
    tc = permute(tc, [ndims(tc) 1:(ndims(tc)-1)]); % bold time course
    tc = reshape(tc, size(tc,1), []); % flatten dimensions
    voxels = read_label(roiFile);   % read .label ROI file
    
    %%% save scan information in 'scan' output
    scan.file = filename(boldFile); % name of bold data file
    scan.size = size(tc); % size of the bold data
    scan.dt = bold.tr ./ 1000; % repetition time, seconds
    scan.t = (0:(size(tc,1)-1)) .* scan.dt; % time vector, seconds
    scan.voxel = voxels(:)'; % voxel indices
    scan.vtc = tc(:,voxels); % extract time course of vertices
end

%%% create scan structure from gifti files
function [scan] = create_gifti_scan(boldFile, roiFile, TR)
    %%% read source bold data information
    bold = gifti(boldFile); % load .gii file
    tc = permute(bold.cdata, [2 1]); % reverse dimensions to [nt nv]
    vertices = read_label(roiFile);  % read .label ROI file
    
    %%% save scan information in 'scan' output
    scan.file = filename(boldFile); % name of bold data file
    scan.size = size(tc); % size of the bold data
    scan.dt = TR; % repetition time, seconds
    scan.t = (0:(size(tc,1)-1)) .* scan.dt; % time vector, seconds
    scan.vertex = vertices(:)'; % vertex indices
    scan.vtc = tc(:,vertices);  % extract time course of vertices
end

%%% create stim struture from stimulus files
function [stim] = create_stimulus_image(stimFile, options)
    %%% read source stimulus information
    m = load(stimFile); % load .mat file
    stimImg = m.(options.stimImg); % assign stimulus image variable
    funcOf = m.(options.funcOf);   % assign function of variable

    %%% validation / error checking
    validate_funcof(stimImg, funcOf);

    %%% save stimulus information in 'stim' output
    stim.file = filename(stimFile);
    stim.funcOf = rmfield(funcOf, 't');
    stim.dt = funcOf.t(2) - funcOf.t(1);
    stim.t = funcOf.t(:);
    stim.stimImg = stimImg;
end

%%% combine scan and stimulus information into a protocol structure
function [protocol] = combine_scan_and_stim(scan, stim, roiFile)
    %%% roi information
    protocol.roi_file = filename(roiFile); 
    if isfield(scan, 'voxel')
%         protocol.voxel_tal = 0; % (!!!) need to implement
        protocol.voxel = scan.voxel(:)';
    else % vertex
        protocol.vertex = scan.vertex(:)'; 
    end

    %%% bold information
    protocol.bold_file = char(scan.file);
    protocol.bold_size = scan.size;
    protocol.bold_dt = scan.dt;
    protocol.bold_t = scan.t(:);
    protocol.bold = scan.vtc;

    %%% stimulus information
    protocol.stim_file = char(stim.file); 
    protocol.stim_funcof = stim.funcOf;
    protocol.stim_dt = stim.dt;
    protocol.stim_t = stim.t(:); 
    protocol.stim = stim.stimImg;
end