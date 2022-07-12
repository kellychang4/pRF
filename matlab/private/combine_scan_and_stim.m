function [protocol] = combine_scan_and_stim(scan, stim, roiFile)
    protocol.roi_file = filename(roiFile); 
    protocol.vertex = scan.vertex(:)'; 
    protocol.bold_file = char(scan.file);
    protocol.bold_size = scan.size;
    protocol.bold_dt = scan.dt;
    protocol.bold_t = scan.t(:);
    protocol.bold = scan.vtc;
    protocol.stim_file = char(stim.file); 
    protocol.stim_funcof = stim.funcOf;
    protocol.stim_dt = stim.dt;
    protocol.stim_t = stim.t(:); 
    protocol.stim = stim.stimImg;
end