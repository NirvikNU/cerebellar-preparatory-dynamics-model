function run_stage_2_kao_validation()
    % Additive cached methodological validation; never rewrites existing outputs.
    root=fileparts(mfilename('fullpath'));
    addpath(fullfile(root,'config'),fullfile(root,'analysis','stage_2'), ...
        fullfile(root,'analysis','published_generator'),fullfile(root,'figures'), ...
        fullfile(root,'figures','stage_2'));
    cfg=stage_2_config(root);
    cfg=rmfield(cfg,{'floor','floorUnits','pcCount','prepEpochMs','moveEpochMs', ...
        'fullReferenceMs','fullReferenceDefinition','bhFamilies','slopeTests'});
    cfg.task='STAGE2-KAO-ALIGNMENT-VALIDATION-01';
    cfg.resultsRoot=fullfile(cfg.resultsRoot,'kao_alignment_validation');
    cfg.nullDraws=10000;
    cfg.prepGO=-350:10:-50; cfg.moveGO=50:10:350;
    cfg.modelMO=100; cfg.prepVarianceThreshold=.8;
    cfg.normalization='Per-neuron range across both comparison epochs + 5 source units';
    cfg.nullReference='Concatenated centered soft-normalized comparison Prep and Move';
    assert(~isfolder(cfg.resultsRoot),'Refusing to overwrite completed validation.');
    out=analyze_stage2_kao_validation(cfg);
    mkdir(cfg.resultsRoot);
    save(fullfile(cfg.resultsRoot,'analysis.mat'),'out','-v7');
    writetable(out.metrics,fullfile(cfg.resultsRoot,'network_metrics.csv'));
    fid=fopen(fullfile(cfg.resultsRoot,'summary.json'),'w'); assert(fid>0);
    fprintf(fid,'%s\n',jsonencode(out.summary,PrettyPrint=true)); fclose(fid);
    create_stage2_kao_figure(out);
    f=openfig(fullfile(cfg.plotsFigRoot,'result_4_kao_prep_move_alignment.fig'),'invisible');
    assert(numel(findall(f,'Type','errorbar'))==2); drawnow; close(f);
    p=imread(fullfile(cfg.plotsPngRoot,'result_4_kao_prep_move_alignment.png'));
    assert(size(p,1)>500 && size(p,2)>500 && std(double(p(:)))>1);
    files={'run_stage_2_kao_validation.m','analysis/stage_2/analyze_stage2_kao_validation.m', ...
        'figures/stage_2/create_stage2_kao_figure.m'};
    for j=1:numel(files)
        findings=checkcode(fullfile(root,files{j}),'-id');
        if ~isempty(findings), disp(findings); end
        assert(isempty(findings),'Code Analyzer issues in %s',files{j});
    end
    out.audit.status='PASS'; out.audit.codeAnalyzerFiles=3;
    out.audit.figReopened=true; out.audit.pngReopened=true;
    fid=fopen(fullfile(cfg.resultsRoot,'validation.json'),'w'); assert(fid>0);
    fprintf(fid,'%s\n',jsonencode(out.audit,PrettyPrint=true)); fclose(fid);
    disp(out.summary); disp(out.metrics); disp(out.audit);
end
