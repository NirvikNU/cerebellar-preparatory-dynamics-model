function [m,c,d,selection]=v2_definition(cfg,n)
    selection=jsondecode(fileread(fullfile(cfg.dest,'geometry_selection.json')));
    assert(strcmp(selection.status,'FROZEN') && selection.eta==0 && selection.lambda==10);
    s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
    s=load(fullfile(cfg.cacheRoot,sprintf('grid_%02d.mat',n)),'definitions'); d=s.definitions{1,selection.gridIndex};
    assert(d.alpha==selection.alpha && d.betaNormalized==selection.betaNormalized);
    s=load(fullfile(cfg.paper,'cache','alignment95',sprintf('controls_n%02d.mat',n)),'c'); c=s.c;
    assert(c.lambda==10); c.kappa0=0;
end
