function paper_run(root)
    % Continue only passed ordered gates. Never implements panel e or Git writes.
    addpath(fullfile(root,'analysis','paper_ready'),fullfile(root,'figures','paper_ready'));
    dest=fullfile(root,'results','paper_ready');
    s=load(fullfile(dest,'timing','timing.mat'),'result'); assert(strcmp(s.result.status,'TIMING_PASS'));
    try
        if isfile(fullfile(dest,'preflight.mat'))
            s=load(fullfile(dest,'preflight.mat'),'audit'); assert(strcmp(s.audit.status,'PASS'));
        else
            paper_preflight(root);
        end
        grid=paper_grid(root);
        if ~strcmp(grid.status,'GEOMETRY_PASS')
            fprintf('Scientific stop: no common feasible geometry. No controls/movements/prediction.\n'); return;
        end
        paper_controls(root); paper_audit(root); paper_figures(root);
    catch exception
        receipt=struct('status','STOP','identifier',exception.identifier,'message',exception.message,'stack',exception.stack, ...
            'predictionRun',false,'acceptedResultsOverwritten',false);
        paper_json(fullfile(root,'artifacts','manifests','paper_ready','STOP.json'),receipt);
        rethrow(exception);
    end
end
