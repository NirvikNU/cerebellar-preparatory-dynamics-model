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
    switch action
        case 'reference', output=stage3_reference(cfg);
        case 'sweep', output=stage3_sweep(cfg);
        case 'consequences', output=stage3_consequences(cfg);
        case 'figures', output=stage3_figures(cfg);
        case 'validate', output=stage3_validate(cfg);
        otherwise, error('Stage3:Action','Unknown explicit action.');
    end
end
