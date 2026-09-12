function output = run_stage_3(action)
    % Explicit, bounded Stage-3 workflow. Never overwrites a completed cache.
    if nargin<1, action='validate'; end
    root=fileparts(mfilename('fullpath'));
    addpath(fullfile(root,'config'),fullfile(root,'src','stage_3'), ...
        fullfile(root,'analysis','stage_3'),fullfile(root,'figures','stage_3'), ...
        fullfile(root,'src','published_generator'), ...
        fullfile(root,'analysis','published_generator'), ...
        fullfile(root,'analysis','stage_2'),fullfile(root,'figures'));
    cfg=stage_3_config(root);
    current=fullfile(cfg.resultsRoot,'biological_revision','resume_02','independent_audit.json');
    assert(isfile(current),'Stage3:MissingCurrent','Current biological audit is required; historical results are not a fallback.');
    switch action
        case 'figures', output=stage3_bio_figures;
        case 'validate', output=stage3_bio_checkpoint_check;
        otherwise, error('Stage3:Historical','Historical isotropic execution is retired; current science requires explicit authorization.');
    end
end
