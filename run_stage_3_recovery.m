function output = run_stage_3_recovery(action)
    % Explicit recovery actions; never dispatch the original production runner.
    root=fileparts(mfilename('fullpath'));
    addpath(fullfile(root,'config'),fullfile(root,'src','stage_3'), ...
        fullfile(root,'analysis','stage_3'),fullfile(root,'figures','stage_3'), ...
        fullfile(root,'src','published_generator'),fullfile(root,'analysis','published_generator'), ...
        fullfile(root,'analysis','stage_2'),fullfile(root,'figures'));
    cfg=stage_3_config(root);
    switch action
        case 'enumerate', output=stage3_recover_evidence(cfg,'enumerate');
        case 'recover', output=stage3_recover_evidence(cfg,'recover');
        otherwise, error('Stage3Recovery:Action','Only explicit enumerate/recover actions are allowed.');
    end
end
