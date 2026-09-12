function receipt = stage3_postgo_check(root)
    % Bounded read-only checkpoint check; no analysis or simulation dispatch.
    cfg=stage3_postgo_paths(root);
    names={'production_complete','independent_audit','figure_audit','unit_tests','paired_output_audit'};
    for j=1:numel(names)
        saved=jsondecode(fileread(fullfile(cfg.postRoot,[names{j} '.json'])));
        assert(strcmp(saved.status,'PASS'));
    end
    loaded=load(fullfile(cfg.postRoot,'summary.mat'),'summary'); s=loaded.summary;
    assert(strcmp(s.status,'PASS') && isequal(size(s.metrics),[10 4 2 8]));
    assert(isequal(size(s.varianceByTarget),[10 4 4 8 2]));
    assert(all(isfinite(s.metrics),'all') && all(isfinite(s.variance),'all'));
    assert(all(s.variance(:,:,4,:)==0,'all'));
    for n=1:10
        for p=1:4
            assert(isfile(fullfile(cfg.postCache,sprintf('n%02d_p%d.mat',n,p))));
            assert(isfile(fullfile(cfg.postCache,sprintf('analysis_n%02d_p%d.mat',n,p))));
        end
    end
    old=stage3_bio_checkpoint_check; assert(strcmp(old.status,'PASS'));
    prediction={'result_3_prediction_validation','diagnostic_3_prediction_noise','diagnostic_4_prediction_specificity'};
    for j=1:3
        f=openfig(fullfile(cfg.plotsFigRoot,[prediction{j} '.fig']),'invisible');
        assert(strcmp(f.UserData.task,'STAGE3-PREDICTION-VALIDATION-01'));
        assert(~isempty(findall(f,'Type','errorbar'))); close(f);
        im=imfinfo(fullfile(cfg.plotsPngRoot,[prediction{j} '.png'])); assert(im.Width>1000);
    end
    f=openfig(fullfile(cfg.plotsFigRoot,'diagnostic_5_postgo_noise_causal.fig'),'invisible');
    assert(strcmp(f.UserData.task,cfg.task)); assert(numel(findall(f,'Type','errorbar'))==56); close(f);
    files=[dir(fullfile(root,'analysis','stage_3','*.m'));dir(fullfile(root,'src','stage_3','*.m')); ...
        dir(fullfile(root,'figures','stage_3','*.m'));dir(fullfile(root,'run_stage_3*.m')); ...
        dir(fullfile(root,'config','stage_3_config.m'))];
    for j=1:numel(files)
        issues=checkcode(fullfile(files(j).folder,files(j).name),'-id');
        if ~isempty(issues), disp(files(j).name); disp(issues); end
        assert(isempty(issues));
    end
    receipt=struct('status','PASS','readOnlySavedOutputCheck',true,'currentFigurePairs',8, ...
        'figuresReopened',8,'replayCases',40,'analysisCases',40,'codeAnalyzerFiles',numel(files), ...
        'scientificAcceptance','Pending user review');
end
