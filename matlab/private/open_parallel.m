function open_parallel()

parallel = get_global_parameters('parallel');

if parallel.flag 
    try % try to open parallel pool

        %%% get current pool information and shut down
        p = gcp('nocreate'); delete(p); 
        
        %%% open parallel pool based on pool type
        switch parallel.type
            case 'threads'; p = parpool(parallel.type);
            case 'local';   p = parpool(parallel.type, parallel.size); 
        end

        %%% set global parallel pool
        set_global_parameters('parallel.pool', p);  

    catch 
        fprintf(['[NOTE] Failed to open parallel pool. ', ...
            'Turning off parallel processing.']);
        set_global_parameters('parallel.flag', false);
    end
end