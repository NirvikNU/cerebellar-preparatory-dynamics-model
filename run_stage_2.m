function run_stage_2(mode)
    % Explicit Stage-2 entry point; no construction or Stage-1 result writes.
    if nargin<1, mode='analyze'; end
    root = fileparts(mfilename('fullpath'));
    addpath(fullfile(root,'config'),fullfile(root,'src','published_generator'), ...
        fullfile(root,'src','stage_2'),fullfile(root,'analysis','stage_2'), ...
        fullfile(root,'analysis','published_generator'),fullfile(root,'figures'), ...
        fullfile(root,'figures','stage_2'));
    cfg = stage_2_config(root);
    if strcmp(mode,'simulate')
        run_stage2_sweep(cfg);
    elseif strcmp(mode,'analyze')
        analyze_stage2_geometry(stage_2_geometry_config(root));
    elseif strcmp(mode,'figures')
        create_stage2_geometry_figures(stage_2_geometry_config(root));
    elseif strcmp(mode,'validate')
        validate_stage2_geometry(stage_2_geometry_config(root));
    elseif strcmp(mode,'test')
        disp(test_stage2(cfg));
    else
        error('Unknown mode. Use test, simulate, analyze, or figures.');
    end
end
