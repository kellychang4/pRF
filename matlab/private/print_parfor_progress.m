function print_parfor_progress(state, args)
% print_parfor_progress(state [, args...])

%%% name of progress file name in temporary directory
fname = fullfile(tempdir, 'parallel_progress.bin');

switch state
    case 'initialize'

        %%% if previous parfor progress file exists, delete
        if isfile(fname); delete(fname); end

        %%% create parfor progress file with counter
        fid = fopen(fname, 'w'); fclose(fid); 

    case 'delete'

        %%% print final progress display (total out of total)
        if exist('args', 'var'); fprintf(args.str, args.n, args.n); end

        %%% delete parfor progress bar
        delete(fname);

    case 'increment' % increment parfor progress bar
        
        %%% append counter to parfor progress file
        fid = fopen(fname, 'A'); fwrite(fid, 1); fclose(fid); 

        %%% read counter from parfor progress file
        fid = fopen(fname, 'r'); counter = fread(fid); fclose(fid); 

        %%% calculate current count
        counter = length(counter); 

        %%% print parfor progress
        if ~mod(counter, args.inc) % if count is muliple of incre.
            fprintf(args.str, counter, args.n); % print progress
        end
end