function c=landscape_paths(root)
    addpath(fullfile(root,'config'),fullfile(root,'src','published_generator'), ...
        fullfile(root,'analysis','published_generator'),fullfile(root,'figures','published_generator'));
    c=stage_1_gate1_config(root);
    c.land=fullfile(c.gate1.resultsRoot,'movement_landscape_diagnostic');
    c.cache=fullfile(c.resultsRoot,'cache','movement_landscape_diagnostic');
    c.manifest=fullfile(root,'artifacts','manifests','stage1_movement_landscape');
    c.alpha=0:.1:5; c.fractions=[0 .01 .025 .05 .10 .20];
    c.bootstrapSeed=2026091500;
    c.plotsFigRoot=fullfile(c.plotsRoot,'diagnostics','movement_landscape','fig');
    c.plotsPngRoot=fullfile(c.plotsRoot,'diagnostics','movement_landscape','png');
    for path={c.land,c.cache,c.plotsFigRoot,c.plotsPngRoot}
        if ~isfolder(path{1}), mkdir(path{1}); end
    end
end
