function output = run_stage_3_finalize(action)
    % Cache-only publication gate; cannot dispatch any simulation or selection.
    root=fileparts(mfilename('fullpath'));
    addpath(fullfile(root,'config'),fullfile(root,'analysis','stage_3'), ...
        fullfile(root,'figures','stage_3'),fullfile(root,'figures'), ...
        fullfile(root,'analysis','stage_2'),fullfile(root,'analysis','published_generator'));
    cfg=stage_3_config(root);
    audit=jsondecode(fileread(fullfile(cfg.manifestRoot,'RECOVERY_INDEPENDENT_AUDIT.json')));
    assert(strcmp(audit.status,'PASS'),'Independent recovery audit must pass first.');
    switch action
        case 'figures'
            test_stage3_flag_ingestion(cfg);
            output=stage3_figures(cfg,2:4);
        case 'report'
            assert(~isfile(fullfile(cfg.resultsRoot,'REPORT.json')),'Do not overwrite completed export.');
            output=stage3_report(cfg);
        case 'validate'
            stage3_completion_summaries(cfg);
            stage3_audit_rendered(cfg);
            names={'result_1_preparation_and_movement','result_2_preparatory_geometry', ...
                'diagnostic_1_feasible_solution_map','diagnostic_2_component_removal'};
            for j=1:4
                f=openfig(fullfile(cfg.plotsFigRoot,[names{j} '.fig']),'invisible');
                if j==2
                    legends=findall(f,'Type','legend');
                    assert(any(arrayfun(@(h)isequal(h.String,{'Intact','Block'}),legends)),'Condition legend missing.');
                end
                close(f); png=imread(fullfile(cfg.plotsPngRoot,[names{j} '.png'])); assert(size(png,2)>1000);
            end
            files=[dir(fullfile(root,'analysis','stage_3','*.m'));dir(fullfile(root,'figures','stage_3','*.m')); ...
                dir(fullfile(root,'src','stage_3','*.m'));dir(fullfile(root,'run_stage_3*.m'));dir(fullfile(root,'config','stage_3_config.m'))];
            for j=1:numel(files)
                issues=checkcode(fullfile(files(j).folder,files(j).name),'-id');
                if ~isempty(issues), disp(files(j).name); disp(struct2table(issues)); end
                assert(isempty(issues));
            end
            output=stage3_validate(cfg);
        otherwise, error('Stage3Finalization:Action','Only figures/report/validate cache-only actions allowed.');
    end
end
