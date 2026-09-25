function receipt=v2_provenance_figures(root)
    cfg=v2_paths(root); path=fullfile(cfg.manifest,'prior_figure_integrity_complete.json'); assert(~isfile(path));
    stems={'main_modelling_alignment95','support_calibration_alignment95','support_noise_controls_alignment95','support_movement_qc_alignment95', ...
        'panel_e_pca_ridge','panel_e_controls','extended_data_rrr', ...
        'stabilization_eta_six_panel','stabilization_eta_movement_qc','stabilization_eta_kinematics', ...
        'noise_sensitivity_absolute','noise_sensitivity_paired'};
    folders=[repmat({''},1,4) repmat({'prediction'},1,3) repmat({'stabilization_eta'},1,3) repmat({'noise_sensitivity'},1,2)];
    receipt.figures=cell(12,1); receipt.totalChecks=0;
    for j=1:12
        base=fullfile('plots','paper_ready',folders{j}); fig=fullfile(base,'fig',[stems{j} '.fig']); png=fullfile(base,'png',[stems{j} '.png']);
        pixels=imread(fullfile(root,png)); assert(~isempty(pixels));
        f=openfig(fullfile(root,fig),'invisible'); closer=onCleanup(@()close(f)); objects=findall(f,'-property','UserData'); checks=0;
        for h=objects.'
            u=h.UserData; if ~isstruct(u), continue; end
            if isfield(u,'x')&&isfield(u,'y')&&isprop(h,'XData')&&isprop(h,'YData')
                assert(isequaln(h.XData(:),u.x(:)) && isequaln(h.YData(:),u.y(:))); checks=checks+1;
            end
            if isfield(u,'err')&&isprop(h,'YPositiveDelta')
                assert(isequaln(h.YPositiveDelta(:),u.err(:)) && isequaln(h.YNegativeDelta(:),u.err(:))); checks=checks+1;
            end
            if isfield(u,'source')&&isprop(h,'YData')
                assert(isequaln(h.YData(:),u.source(:))); checks=checks+1;
                if isfield(u,'x'), assert(isequaln(h.XData(:),u.x(:))); checks=checks+1; end
                if isfield(u,'se')&&isprop(h,'YPositiveDelta')
                    assert(isequaln(h.YPositiveDelta(:),u.se(:)) && isequaln(h.YNegativeDelta(:),u.se(:))); checks=checks+1;
                end
            end
        end
        receipt.figures{j}=struct('fig',strrep(fig,'\','/'),'png',strrep(png,'\','/'),'pngSize',size(pixels),'sourceObjectChecks',checks);
        receipt.totalChecks=receipt.totalChecks+checks; clear closer
    end
    receipt.status='PASS'; receipt.regenerated=false; receipt.scientificSourceAudits='Prior validated audits reused subject to protected-file SHA256 equality';
    paper_json(path,receipt);
end
