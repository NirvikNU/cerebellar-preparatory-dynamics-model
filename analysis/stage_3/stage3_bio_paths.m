function cfg = stage3_bio_paths(root)
    if nargin<1, root=fileparts(fileparts(fileparts(mfilename('fullpath')))); end
    addpath(fullfile(root,'config'),fullfile(root,'src','stage_3'), ...
        fullfile(root,'analysis','stage_2'),fullfile(root,'src','published_generator'), ...
        fullfile(root,'analysis','published_generator'),fullfile(root,'figures'), ...
        fullfile(root,'figures','stage_3'));
    cfg=stage_3_config(root);
    cfg.bioRoot=fullfile(cfg.resultsRoot,'biological_revision','resume_02');
    cfg.bioCache=fullfile(cfg.cacheRoot,'biological_revision','resume_02');
    cfg.policyFlags=[1 1;1 0;0 1;0 0];
    cfg.policyNames={'Intact','Remove feedback','Remove b','Block'};
end
